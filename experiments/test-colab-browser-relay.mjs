// Real filesystem and stubbed browser fixtures. No live browser, GPU, or model.
import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {randomUUID} from 'node:crypto';
import {test} from 'node:test';
import {createExchange, createRelay} from './colab-browser-relay.mjs';

const revision = '851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a';
const settings = {prefill_chunk_size:1024, input_token_limit:12288, max_new_tokens:2048};
async function fixture(action) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'colab-browser-relay-'));
  try {
    await fs.mkdir(path.join(root, 'relay'));
    const request = {id:randomUUID(), model:'Qwen/Qwen3.5-4B', relay_protocol:3,
      expires_at:new Date(Date.now()+600000).toISOString(), ...settings,
      messages:[{role:'user', content:'Fixture with "quotes", newline\n and λ'}]};
    const raw = JSON.stringify(request);
    const file = suffix => path.join(root, 'relay', `${request.id}.${suffix}.json`);
    await fs.writeFile(file('request'), raw);
    const response = {relay_id:request.id, model:request.model, revision, ...settings,
      attention:'eager', eos_token_id:248046, choices:[], raw_generation:'unchanged λ\n'};
    await action({root, request, raw, response, file, exchange:createExchange(root,settings)});
  } finally { await fs.rm(root,{recursive:true,force:true}); }
}

test('exact request bytes and response survive exchange; timings are durable', async () => {
  await fixture(async ({root,raw,request,response,file,exchange}) => {
    assert.equal((await exchange.next()).raw,raw);
    assert.equal(await exchange.deliver(request,response),'delivered');
    assert.deepEqual(JSON.parse(await fs.readFile(file('response'),'utf8')),response);
    assert.equal(await exchange.next(),null);
    const events=(await fs.readFile(path.join(root,'browser-relay-events.jsonl'),'utf8')).trim().split('\n').map(JSON.parse);
    assert.deepEqual(events.map(x=>x.event),['request_seen','response_observed','response_written']);
    assert(events.every(x=>x.id===request.id && Number.isFinite(Date.parse(x.at))));
  });
});
test('expired generation is evidence, never a consumable response', async () => {
  await fixture(async ({request,response,file,exchange}) => {
    await exchange.next();
    await fs.writeFile(file('expired'),'{}');
    assert.equal(await exchange.deliver(request,response),'late');
    await assert.rejects(fs.access(file('response')),{code:'ENOENT'});
    assert.deepEqual(JSON.parse(await fs.readFile(file('late'),'utf8')),response);
    assert.equal(await exchange.next(),null);
  });
});
test('wall deadline blocks starting a stale request', async () => {
  await fixture(async ({request,file,exchange}) => {
    request.expires_at='2020-01-01T00:00:00Z';
    await fs.writeFile(file('request'),JSON.stringify(request));
    await assert.rejects(exchange.next(),/Request expired/);
  });
});
test('identity, runtime and budget mismatches cannot become responses', async () => {
  await fixture(async ({request,response,file,exchange}) => {
    for (const delta of [{relay_id:randomUUID()},{revision:'wrong'},
      {attention:'sdpa'},{max_new_tokens:1024}]) {
      await assert.rejects(exchange.deliver(request,{...response,...delta}));
    }
    await assert.rejects(fs.access(file('response')),{code:'ENOENT'});
  });
});
test('identity-tagged runtime errors pass through unchanged', async () => {
  await fixture(async ({request,file,exchange}) => {
    const response={relay_id:request.id,model:request.model,revision,error:{type:'RuntimeError',message:'fixture'}};
    assert.equal(await exchange.deliver(request,response),'delivered');
    assert.deepEqual(JSON.parse(await fs.readFile(file('response'),'utf8')),response);
  });
});

test('DOM text delivers complete output despite missing visible text matches; fragments wait', async () => {
  await fixture(async ({root,raw,response,file}) => {
    let output = '', cellSource;
    const region = {
      innerText: async () => output,
      getByText: () => ({first: () => ({waitFor: async () => {
        throw new Error('Playwright selector deadline exceeded');
      }})}),
    };
    const cell = {getByRole: role => role === 'textbox'
      ? {fill: async source => { cellSource = source; }} : {click: async () => {}}};
    const tab = {playwright: {
      domSnapshot: async () => '- region "Cell 0 output"',
      getByRole: (role, {name}) => role === 'button' ? {click: async () => {}}
        : name === 'Cell 0 output' ? region : cell,
    }};
    const relay = createRelay(tab,root,settings);
    assert.equal((await relay.step()).state,'started');
    assert.equal(cellSource,`colab_complete(${JSON.stringify(raw)})`);
    assert.equal((await relay.step()).state,'generating');
    output = JSON.stringify(response).slice(0,-3);
    assert.equal((await relay.step()).state,'generating');
    await assert.rejects(fs.access(file('response')),{code:'ENOENT'});
    output = 'Runtime warning\n' + JSON.stringify(response);
    assert.equal((await relay.step()).state,'delivered');
    assert.deepEqual(JSON.parse(await fs.readFile(file('response'),'utf8')),response);
  });
});

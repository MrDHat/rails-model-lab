// Import inside cua_repl with an already selected Colab tab. Browser operations
// use documented CUA APIs; this module opens no network client or endpoint.
import * as fs from 'node:fs/promises';
import path from 'node:path';

const REVISION = '851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a';

export function createExchange(runRoot, settings) {
  if (!path.isAbsolute(runRoot)) throw new Error('Use an absolute run directory');
  const directory = path.join(runRoot, 'relay');
  async function event(name, details) {
    await fs.appendFile(path.join(runRoot, 'browser-relay-events.jsonl'),
      JSON.stringify({event: name, at: new Date().toISOString(), ...details}) + '\n');
  }
  function checkSettings(data, response = false) {
    for (const key of ['prefill_chunk_size', 'input_token_limit', 'max_new_tokens']) {
      if (data[key] !== settings[key]) throw new Error(`Unexpected ${key}`);
    }
    if (response && (data.revision !== REVISION || data.attention !== 'eager' ||
        data.eos_token_id !== 248046)) throw new Error('Unexpected model runtime');
  }
  async function expired(request) {
    const files = await fs.readdir(directory);
    return Date.now() >= Date.parse(request.expires_at) ||
      files.includes(`${request.id}.expired.json`);
  }
  async function next() {
    const files = await fs.readdir(directory);
    const pending = files.filter(name => name.endsWith('.request.json') &&
      !files.includes(name.replace('.request.json', '.response.json')) &&
      !files.includes(name.replace('.request.json', '.expired.json')));
    if (!pending.length) return null;
    if (pending.length !== 1) throw new Error('Expected a single pending request');
    const raw = await fs.readFile(path.join(directory, pending[0]), 'utf8');
    const request = JSON.parse(raw);
    if (pending[0] !== `${request.id}.request.json` ||
        !/^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/.test(request.id) ||
        request.model !== 'Qwen/Qwen3.5-4B' || request.relay_protocol !== 3 ||
        !Number.isFinite(Date.parse(request.expires_at))) {
      throw new Error('Invalid request identity or deadline');
    }
    checkSettings(request);
    if (await expired(request)) throw new Error(`Request expired: ${request.id}`);
    await event('request_seen', {id: request.id});
    return {request, raw};
  }
  async function deliver(request, response) {
    if (response.relay_id !== request.id || response.revision !== REVISION ||
        response.model !== request.model) {
      throw new Error('Response identity mismatch');
    }
    if (!response.error) checkSettings(response, true);
    await event('response_observed', {id: request.id, error: response.error ?? null});
    const late = await expired(request);
    // Preserve a late generation as diagnostics, never as a consumable answer.
    const destination = path.join(directory, `${request.id}.${late ? 'late' : 'response'}.json`);
    await fs.writeFile(destination + '.tmp', JSON.stringify(response) + '\n', {flag: 'wx'});
    // Recheck after I/O to avoid promoting a response across the deadline.
    if (!late && await expired(request)) {
      await fs.rename(destination + '.tmp', path.join(directory, `${request.id}.late.json`));
      await event('response_late', {id: request.id});
      return 'late';
    }
    await fs.rename(destination + '.tmp', destination);
    await event(late ? 'response_late' : 'response_written', {id: request.id});
    return late ? 'late' : 'delivered';
  }
  return {next, deliver, event};
}

export function createRelay(tab, runRoot, settings) {
  const exchange = createExchange(runRoot, settings);
  let active = null;
  async function step() {
    if (!active) {
      const next = await exchange.next();
      if (!next) return {state: 'idle'};
      const {request, raw} = next;
      const before = await tab.getAXState({emit: false, disableDiffing: true});
      const code = before.match(/(\d+) button Code Insert code cell below/);
      if (!code) throw new Error('Add-code control unavailable');
      await tab.click(Number(code[1]));
      const state = await tab.getAXState({emit: false});
      const editor = [...state.matchAll(/(\d+) editor \(settable\)/g)].at(-1);
      const run = [...state.matchAll(/(\d+) button Description: Run cell/g)].at(-1);
      if (!editor || !run) throw new Error('New cell controls unavailable');
      await tab.paste(Number(editor[1]), `colab_complete(${JSON.stringify(raw)})`);
      await tab.click(Number(run[1]));
      await tab.getAXState({emit: false});
      const snapshot = await tab.playwright.domSnapshot();
      const output = [...snapshot.matchAll(/- region "(Cell \d+ output)"/g)].at(-1);
      if (!output) throw new Error('New cell output region unavailable');
      active = {request, region: output[1]};
      await exchange.event('cell_started', {id: request.id, region: active.region});
      return {state: 'started', id: request.id, region: active.region};
    }
    const region = tab.playwright.getByRole('region', {name: active.region, exact: true});
    try {
      await region.getByText(new RegExp(`"relay_id":\\s*"${active.request.id}"`)).first()
        .waitFor({state: 'visible', timeoutMs: 40000});
    } catch (error) {
      if (!/timeout/i.test(String(error))) throw error;
      return {state: 'generating', id: active.request.id};
    }
    const text = await region.innerText();
    const line = text.split('\n').find(value => value.trim().startsWith('{"relay_id"'));
    if (!line) throw new Error('Response JSON missing from cell output');
    const response = JSON.parse(line);
    const state = await exchange.deliver(active.request, response);
    const result = {state, id: active.request.id, error: response.error,
      usage: response.usage, seconds: response.seconds,
      finish_reason: response.choices?.[0].finish_reason};
    active = null;
    return result;
  }
  return {step};
}

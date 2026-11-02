Transfer.call(from, to, cents) debits one wallet and credits another. Crediting
a frozen wallet raises an error (that validation exists already). When that
happens the debit must not stick: both balances end as they were and the
error reaches the caller. Keep the schema unchanged.

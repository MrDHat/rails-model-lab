Staff type serials however they like: " dr-001", "Dr-001 ", "DR-001". Store
every serial with surrounding spaces stripped and in upper case, whether it
comes from the tool form or from code, so "dr-001" clashes with the existing
"DR-001" and the form shows "Serial has already been taken". Staff also need
to look a tool up by serial: `GET /tools?serial=TEXT` lists only the tool with
that serial, however TEXT is typed.

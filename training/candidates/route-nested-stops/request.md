The delivery-route form submits stops_attributes. Ignore entirely blank new
stop rows, including whitespace-only fields. Save meaningful new stops and
updates to existing stops. An existing stop with its id and _destroy set to
"1" must be deleted when the route saves; a new row marked for destruction
must not be created. Each saved stop requires a label. A new row with notes
but no label is not entirely blank: it must make the route invalid, and no
partial route or stop records may persist. Use normal nested-attributes input;
keep the schema unchanged. Authorization and controller parameter filtering
are outside this model-only example.

Add SupportCase.unassigned: cases with no agent. That includes cases whose
agent_id is null and cases whose agent_id points at an agent that was deleted
without cleaning up. It must return a relation. Keep the schema unchanged.

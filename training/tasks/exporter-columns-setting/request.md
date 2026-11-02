Exporter has a columns setting, default ["id"]. Subclasses set their own by
assigning a new list with self.columns = ..., often built from the parent's
value (columns + ["email"]), and instances read it with exporter.columns. A subclass's setting must never change the parent's
or a sibling's, and a subclass that sets nothing inherits from its parent.

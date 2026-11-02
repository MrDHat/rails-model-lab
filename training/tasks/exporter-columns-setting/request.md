Exporter has a columns setting, default ["id"]. Subclasses set their own with
self.columns = ..., often building on the parent's value, and instances read
it with exporter.columns. A subclass's setting must never change the parent's
or a sibling's, and a subclass that sets nothing inherits from its parent.

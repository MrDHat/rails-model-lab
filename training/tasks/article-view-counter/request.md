story.record_view! adds one to views. Many servers record views at once, each
holding its own (possibly stale) copy of the story, and views are being lost.
Two calls on two copies loaded at the same time must add two. Keep the
schema unchanged.

User preferences live in the settings JSON column. Let code use user.theme and
user.digest as normal attributes: readable, assignable, accepted by
User.new(theme: ..., digest: ...), and saved inside settings. Setting one
must not lose other keys already in settings (like a legacy "beta" flag).
Keep the schema unchanged.

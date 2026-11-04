Add `member.borrowed_tools`: every tool the member has ever borrowed, each
once, however many times they borrowed it. It's used like an association
elsewhere, so it has to support chaining, e.g.
`member.borrowed_tools.where(category: garden)` or
`member.borrowed_tools.in_service`. Then add a "Tools borrowed" section to the
member page listing those tools by name, alphabetically, each linking to the
tool's page.

# Prompt Library Index

## Active Prompts by Type

### Metaprompts
```dataview
TABLE title, tags, models, variables, version, last-tested
FROM "prompts"
WHERE type = "metaprompt" AND status = "active"
SORT last-tested DESC
```

### Templates
```dataview
TABLE title, tags, models, variables, version
FROM "prompts"
WHERE type = "template" AND status = "active"
SORT title ASC
```

### Prompts
```dataview
TABLE title, tags, models, version, last-tested
FROM "prompts"
WHERE type = "prompt" AND status = "active"
SORT last-tested DESC
```

### Snippets
```dataview
TABLE title, tags
FROM "prompts"
WHERE type = "snippet" AND status = "active"
SORT title ASC
```

## All Drafts
```dataview
TABLE title, type, tags
FROM "prompts"
WHERE status = "draft"
SORT file.mtime DESC
```

## Recently Updated
```dataview
TABLE title, type, version
FROM "prompts"
WHERE status = "active"
SORT file.mtime DESC
LIMIT 10
```

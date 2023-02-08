# Bulk Recursive Regex File Editor

This utility allows you to bulk recursively edit multple files. I personally use it to modify HTML in bulk.

### json-config-generate.pl

This program generates a .json which is required for the main program to work. You can chain many edits together.

```
> fill in the info below, it will be saved to: find-replace-1675816071.json
> label: edits out tags
> directory: /home/
> regex to filter file type, default = \.html$:
> find: <[^>]+?>
> replace:
> saving to: find-replace-1675816071.json
> [{"dir":"/home","filetype":"\\.html$","label":"edits out tags","replace":"","find":"<[^>]+?>"}]
> (w)rite / (r)edo / (a)dd / (q)uit:
```

### brrfe.pl

The main program. Usage:

```
brrfe.pl file.json
```


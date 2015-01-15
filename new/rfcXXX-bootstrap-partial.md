---
RFC: unassigned
Author: Ranjib Dey (ranjib@linux.com)
Status: Draft
Type: Standards Track
---

# Allow partials in bootstrap template

Allow partial templates to be passed during `knife bootstrap`

## Motivation

Chef allows knife based bootstrapping via standard templates as well
as custom templates. But theres no way to reuse the bootstrapping logic
of standard templates. For minimal distributions where tools like
wget and curl is absent, one has to roll his/her own bootstrap template,
which most often is a copy of the standard template with extra commands
to install those tools. Over the time, this becomes tech debt, as chef evolves
and with it the standard template changes, incorporating new bootstrap options.

Scope of this RFC is to offer users a mechnism to execute custom logic before
the standard bootstrapping process, instead of specifying the entire bootstrapping
logic via custom templates. This keeps their own customization separate from the
standard template.


## Specification

Allow specifying partial templates or bash script during knife bootstrap, via
`--partial` attribute.

```sh
knife bootstrap FQDN  --partial custom.sh
```

`--partial` flag can be provided multiple times to chain commands.

## Compatibility

This feature is backwards compatible.

## Copyright

This work is in the public domain. In jurisdictions that do not allow
for this, this work is available under CC0. To the extent possible
under law, the person who associated CC0 with this work has waived all
copyright and related or neighboring rights to this work.


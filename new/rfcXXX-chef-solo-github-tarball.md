---
RFC: unassigned
Author: Ranjib Dey (ranjib@linux.com)
Status: Draft
Type: Standards Track
---

# GitHub repository tarball as cookbook source for chef-client local mode

Allow chef-client to consume github repository tarballs as cookbook
source

## Motivation

chef-client in local mode can fetch cookbook tarballs from an URL. Also, GitHub already provide
repository source as tarball (both per branch as well as per release tags).
But since github release tarballs generated with a different folder structure,
chef-client can not consume theem out of the box.

Letting chef-client directly consume GitHub releases will ease the cookbook deployment by
eleminating the need of maintaining additional tooling to generate and
host cookbook tarballs.


## Specification

Introduce a `--github` CLI flag in chef-client. If this flag is supplied
along with `--recipe-url` in local mode then chef-client will do additional tarball processing
assuming its a github release.

```sh
chef-client -z -o 'recipe[test]' -r https://github.com/ranjib/chef-repo/archive/master.tar.gz --github
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the
person who associated CC0 with this work has waived all copyright and related
or neighboring rights to this work.

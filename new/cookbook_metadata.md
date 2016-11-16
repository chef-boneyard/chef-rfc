---
RFC: unassigned
Title: Cookbook Metadata Files
Author: Charles Johnson <charles@chef.io>
Author: Thom May <tmay@chef.io>
Status: Draft
Type: <Standards Track>
---

# Cookbook Metadata Files

The purpose of this RFC is to clarify the handling of cookbook metadata files by tooling in the Chef ecosystem.

## Motivation

    As a person who writes and shares cookbooks,
    I want to specify metadata without hand-editing json,
    so that I can write cookbooks without incurring the pain of hand-editing JSON.

    As a person who uploads cookbooks to a Chef Supermarket server,
    I want to be able to upload my files without worrying about the format in which the cookbook metadata file was written,
    because this detail provides me with no tangible value.

    As a person who utilizes cookbooks downloaded from a Chef Supermarket in my own recipes,
    I should be able to upload those cookbooks to my own Chef Server without worrying about the format in which the cookbook metadata file was written,
    because this detail provides me with no tangible value.

    As a person who runs a Supermarket server,
    I should be able to accept cookbook uploads without my server interpreting code as part of the uplaod process,
    so that I can more easily provide a secure cookbook sharing service.

## Guiding UX Principles
1. Machines should prefer `json` to `rb`
2. Humans must never be forced to hand-edit `json` files.

## Specification

- Supermarket, Chef server, depsolvers, et al. must only care about the metadata.json, and must ignore the metadata.rb. If no metadata.json is present, fail.
- Tooling that takes cookbooks from machines and makes them available to humans for editing must generate a metadata.rb from the metadata.json, overwiting any metadata.rb that may already exist in the cookbook.

- Tooling that takes cookbooks from humans and provides them to machines must generate a metadata.json from the metadata.rb, overwriting any metadata.json that may already exist in the cookbook.

- Processing of the metadata.rb to metadata.json must happen client-side, for security reasons.
- Processing the metadata.json to metadata.rb can happen client-side or server-side, as there's no risk here.
Add Comment


## Downstream Impact

- Knife
- Berkshelf
- Supermarket
- Stove
- Chef Server

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

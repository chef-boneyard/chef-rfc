---
RFC: unassigned
Author: Jeremy Bingham <jeremy@goiardi.gl>
Status: Draft
Type: Informational
---

# PostgreSQL Search for Chef

An information specification of goiardi's PostgreSQL backed search. 

## Motivation

    As a goiardi developer,
    I want to share the goiardi PostgreSQL search specification,
    so that anyone who's interested can read about it.

    As a chef user,
    I want different means of searching available,
    so that I don't have to deal with installing and maintaing Solr.

## Specification

### Overview

A server implementing this Postgres search MUST also implement Chef RFC 018 - Attribute Subkey Syntax. This is because ltree uses '.' as a path separator.

### Tables

There are two tables for this search: search_collections and search_items. The search_collections table has entries for each indexed type: node, role, environment, client as defaults, and any data bags. The search_items table has a row for each value in the indexed object. Each row will have keys for the parent search_collection and the organization that the object belongs to, along with a text column for the item's name, a text column for the item's value, and an ltree path column describing the full path to the item, e.g. for `node[:foo][:bar][:baz]`, the path in the search_items table would be `foo.bar.baz`.

Table indices are up to the implementers, except for the mandatory ltree index on search_items.path. A trigram index on the value column is strongly recommended.

An implementing server that has organizations MAY use a separate schema for each organization's search tables.

See Appendix 1 for the goiardi search tables and indices implementations.

### Querying

The implementing server MUST have a Solr query parser that can parse out Solr queries and build Postgres queries. The parser MUST be able to handle all common search use cases, including basic, grouped, and range queries. It SHOULD at least accept more unusual Solr queries like fuzzy searches, even if it does not do anything particularly useful with them.

An implementing server MAY short circuit certain kinds of queries. For instance, when using "*:*" as a query term, it is acceptable and recommended to directly hit that object's database table rather than using the search_items table.

In the usual case, the search query first builds a CTE clause to narrow down the number of rows in the search items table to search through. For example, to search for all nodes which have a name starting with "foobar*" in the "development" environment, it would start with a clause like:

```
WITH found_items AS (SELECT item_name, path, value FROM goiardi.search_items si WHERE si.organization_id = $1 AND si.search_collection_id = (SELECT id FROM goiardi.search_collections WHERE name = $2) AND path OPERATOR(goiardi.?) ARRAY[ $3, $4 ]::goiardi.lquery[]), items AS (SELECT name AS item_name FROM goiardi.nodes WHERE organization_id = $1)
```

Here, $1 is of course the organization id number, $2 is the type of object being searched for (in this example "node"), and $3 and $4 are the fields being searched ("name" and "chef_environment"). The `found_items` clause describes all rows that belong to nodes that have `name` and `chef_environment` as their paths, while `items` is a list of all node names. It's drawn directly from the nodes table instead of from `found_items` because it turned out to be far more performant that way.

The SELECT statement that follows varies depending on how many search terms are used. If only one term, like "name:foo*" is used, then the SELECT statement will be like `SELECT COALESCE(ARRAY_AGG(DISTINCT item_name), '{}'::text[]) FROM found_items f0 WHERE (f0.path OPERATOR(goiardi.~) $4 AND f0.value LIKE $5)`. When searching for a distinct name, the WHERE clause would be like `WHERE (f0.path OPERATOR(goiardi.~) $4 AND f0.value = $5)`, while "name:*" will be like "WHERE (f0.path ~ $4)".

With more than one term it becomes a little more complicated.

## Appendix 1: The Goiardi Search Tables and Indices

```
BEGIN;
CREATE EXTENSION ltree SCHEMA goiardi;
CREATE EXTENSION pg_trgm SCHEMA goiardi;

CREATE TABLE goiardi.search_collections (
	id bigserial,
	organization_id bigint not null default 1,
	name text,
	PRIMARY KEY(id),
	UNIQUE(organization_id, name)
);

CREATE TABLE goiardi.search_items (
	id bigserial,
	organization_id bigint not null default 1,
	search_collection_id bigint not null,
	item_name text,
	value text,
	path goiardi.ltree,
	PRIMARY KEY(id),
	FOREIGN KEY (search_collection_id)
		REFERENCES goiardi.search_collections(id)
		ON DELETE RESTRICT
);


CREATE INDEX search_col_name ON goiardi.search_collections(name);
CREATE INDEX search_org_id ON goiardi.search_items(organization_id);
CREATE INDEX search_org_col ON goiardi.search_items(organization_id, search_collection_id);
CREATE INDEX search_gist_idx ON goiardi.search_items USING gist (path);
CREATE INDEX search_btree_idx ON goiardi.search_items USING btree(path);
CREATE INDEX search_org_col_name ON goiardi.search_items(organization_id, search_collection_id, item_name);
CREATE INDEX search_item_val_trgm ON goiardi.search_items USING gist (value goiardi.gist_trgm_ops);
CREATE INDEX search_multi_gist_idx ON goiardi.search_items USING gist (path, value goiardi.gist_trgm_ops);
CREATE INDEX search_val ON goiardi.search_items(value);

COMMIT;
```

## Appendix 2: Sample Search Queries

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

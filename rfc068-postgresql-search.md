---
RFC: 68
Author: Jeremy Bingham <jeremy@goiardi.gl>
Status: Accepted
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

Table indices are up to the implementers, except for the mandatory ltree index on search_items.path. A trigram index on the value column, or at least a GiST index on (path, value) using trigrams for the value, speeds up many of these queries considerably. However, these indexes do take up a lot of space on disk and require maintenance (see below).

An implementing server that has organizations may use a separate schema for each organization's search tables.

See Appendix 1 for the goiardi search tables and indices implementations.

### Querying

The implementing server must have a Solr query parser that can parse out Solr queries and build Postgres queries. The parser must be able to handle all common search use cases, including basic, grouped, and range queries. It should at least accept more unusual Solr queries like fuzzy searches, even if it does not do anything particularly useful with them.

An implementing server may short circuit certain kinds of queries. For instance, when using "\*:\*" as a query term, it is acceptable and recommended to directly hit that object's database table rather than using the search_items table.

In the usual case, the search query first builds a CTE clause to narrow down the number of rows in the search items table to search through. For example, to search for all nodes which have a name starting with "foobar*" in the "development" environment, it would start with a clause like:

```
WITH found_items AS (SELECT item_name, path, value FROM goiardi.search_items si WHERE si.organization_id = $1 AND si.search_collection_id = (SELECT id FROM goiardi.search_collections WHERE name = $2) AND path OPERATOR(goiardi.?) ARRAY[ $3, $4 ]::goiardi.lquery[]), items AS (SELECT name AS item_name FROM goiardi.nodes WHERE organization_id = $1)
```

Here, $1 is of course the organization id number, $2 is the type of object being searched for (in this example "node"), and $3 and $4 are the fields being searched ("name" and "chef_environment"). The `found_items` clause describes all rows that belong to nodes that have `name` and `chef_environment` as their paths, while `items` is a list of all node names. It's drawn directly from the nodes table instead of from `found_items` because it turned out to be far more performant that way.

The SELECT statement that follows varies depending on how many search terms are used. If only one term, like "name:foo\*" is used, then the SELECT statement will be like `SELECT COALESCE(ARRAY_AGG(DISTINCT item_name), '{}'::text[]) FROM found_items f0 WHERE (f0.path OPERATOR(goiardi.~) $4 AND f0.value LIKE $5)`. When searching for a distinct name, the WHERE clause would be like `WHERE (f0.path OPERATOR(goiardi.~) $4 AND f0.value = $5)`, while "name:\*" will be like "WHERE (f0.path ~ $4)".

With more than one term it becomes a little more complicated. Each term gets an INNER JOIN on found_items added to the select query and a statement added to the WHERE clause, like so:

```
SELECT COALESCE(ARRAY_AGG(i.item_name), '{}'::text[]) FROM items i INNER JOIN found_items AS f0 ON i.item_name = f0.item_name INNER JOIN found_items AS f1 ON i.item_name = f1.item_name WHERE (f0.path OPERATOR(goiardi.~) 'name' AND f0.value = 'pedant_node_test')  OR (f1.path OPERATOR(goiardi.~) 'name' AND f1.value LIKE 'pedant\_multiple\_node\_1444142041-409998000-28025%')
```

Range and grouped queries work as well. They're converted into SQL statements in a straightforward fashion, but aside from being ranged or grouped queries they're just like the basic queries above.

Finally, `%` and `_` in the query terms must be escaped, and `*` and `?` must be converted to `%` and `_` respectively.

### Processing Results

These search queries do, of course, just return the names of the objects, not the objects themselves. An implementation will need to get the requested objects from the database and return them.

These tables also do not, in themselves, provide a good way to order and limit returned results. That needs to be taken care of when the objects are fetched from the database and returned.

### Populating

After an object has been expanded in the usual Chef fashion, each item is added to the search items table. If a data bag is being added, and it's not already in, it will also be added to the search collections table. Otherwise it will be assigned to an existing search collection. For example, if you had a node named "foobar" with a value inside it somewhere at `['baz']['buz']['glop'] = 'beep'`, that would go into the search_items table with the node search_collection_id (whatever that happens to be), an item_name of "foobar", a path of "baz.buz.glop", and a value of "beep". This would be repeated for all of the different values in the object.

One limitation of ltree is that it only accepts alphanumeric characters and underscores in the paths. It will accept *some*, but not all, Unicode characters. Cyrillic letters are fine, but Ethiopic, cuneiform, and Linear B have all been tested and found not to work. The side effect of this is that when the paths are set up on indexing, and when querying, any non-alphanumeric characters need to be removed and replaced with underscores (and then duplicate underscores need to be removed as well). This should not generally be a problem, but if for some strange reason you had keys named both "/dev/xvda1" and "dev_xvda1" in something being indexed you might get unexpected results.

### Maintenance

An active `search_items` table will start eating up disk space surprisingly quickly; therefore, regular table maintenance is essential to keeping disk usage reasonable. All that needs to be done is run `REINDEX TABLE goiardi.search_items; VACUUM;` as a Postgres user that has access to the goiardi database.

### Other possibilities

There's absolutely no reason that this couldn't be used to build a search that isn't backwards compatible with Solr that could take full advantage of the ltree syntax and operators. Allowing raw SQL in the queries is probably not a great idea, but some minimal processing of the query into a full SQL query opens up some interesting possibilities.

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

The indexes, particularly, are subject to change.

## Appendix 2: Sample Search Queries

```
WITH found_items AS (SELECT item_name, path, value FROM goiardi.search_items si WHERE si.organization_id = 1 AND si.search_collection_id = (SELECT id FROM goiardi.search_collections WHERE name = 'environment') AND path OPERATOR(goiardi.?) ARRAY[ 'name' ]::goiardi.lquery[]), items AS (SELECT name AS item_name FROM goiardi.environments WHERE organization_id = 1) SELECT COALESCE(ARRAY_AGG(DISTINCT item_name), '{}'::text[]) FROM found_items f0 WHERE (f0.path OPERATOR(goiardi.~) 'name' AND f0.value = 'pedant_testing_environment');
```

```
WITH found_items AS (SELECT item_name, path, value FROM goiardi.search_items si WHERE si.organization_id = 1 AND si.search_collection_id = (SELECT id FROM goiardi.search_collections WHERE name = 'node') AND path OPERATOR(goiardi.?) ARRAY[ 'name' ]::goiardi.lquery[]), items AS (SELECT name AS item_name FROM goiardi.nodes WHERE organization_id = $1) SELECT COALESCE(ARRAY_AGG(DISTINCT item_name), '{}'::text[]) FROM found_items f0 WHERE (f0.path OPERATOR(goiardi.~) 'name' AND f0.value = 'pedant_node_test');
```

```
WITH found_items AS (SELECT item_name, path, value FROM goiardi.search_items si WHERE si.organization_id = 1 AND si.search_collection_id = (SELECT id FROM goiardi.search_collections WHERE name = 'node') AND path OPERATOR(goiardi.?) ARRAY[ 'name', 'name' ]::goiardi.lquery[]), items AS (SELECT name AS item_name FROM goiardi.nodes WHERE organization_id = 1) SELECT COALESCE(ARRAY_AGG(i.item_name), '{}'::text[]) FROM items i INNER JOIN found_items AS f0 ON i.item_name = f0.item_name INNER JOIN found_items AS f1 ON i.item_name = f1.item_name WHERE (f0.path OPERATOR(goiardi.~) 'name' AND f0.value = 'pedant_node_test')  OR (f1.path OPERATOR(goiardi.~) 'name' AND f1.value LIKE 'pedant\_multiple\_node\_1444142041-409998000-28025%');
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

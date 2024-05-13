# Think Big, Act Localhost

This repository provides a handful of small examples to complement a presentation of the same name at the 2024 code4lib conference.

## Reserialize

Given a set of MARC records, reserialize those records as "merge candidates" as described in the presentation. A merge candidate record consists of the format:

```
{HASHED_MERGE_KEY} {TAB_DELIMITER_CHAR} {JSON_OBJECT}
```

## Cluster

The clustering example provides a demonstration of converting reserialized merge candidate records into finalized record clusters. 

```
$ head data/merge_candidates.tsv 
000000670195b57a802f06cebc7a0f6af8e4d4aa	{"id":"1", "mergeIds":["isbn:123"],             "marc": "MARC_BINARY_1", "type":"Electronic"}
000000670195b57a802f06cebc7a0f6af8e4d4aa	{"id":"2", "mergeIds":["isbn:456"],             "marc": "MARC_BINARY_2", "type":"Electronic"}
000000670195b57a802f06cebc7a0f6af8e4d4aa	{"id":"3", "mergeIds":["isbn:123", "isbn:456"], "marc": "MARC_BINARY_3", "type":"Print"}
000000670195b57a802f06cebc7a0f6af8e4d4aa	{"id":"4", "mergeIds":["isbn:789"],             "marc": "MARC_BINARY_4", "type":"Electronic"}
000000670195b57a802f06cebc7a0f6af8e4d4aa	{"id":"5", "mergeIds":["isbn:123"],             "marc": "MARC_BINARY_5", "type":"Microform"}
ee95d64ee7ffaf709dc4fe772ce081938f5bef6a	{"id":"6", "mergeIds":[],                       "marc": "MARC_BINARY_6", "type":"Print"}
ee95d64ee7ffaf709dc4fe772ce081938f5bef6a	{"id":"7", "mergeIds":["issn:987"],             "marc": "MARC_BINARY_7", "type":"Electronic"}
$ ruby main.rb 
$ head data/record-clusters.jsonl 
[{"id":"1","mergeIds":["isbn:123"],"marc":"MARC_BINARY_1","type":"Electronic"},{"id":"3","mergeIds":["isbn:123","isbn:456"],"marc":"MARC_BINARY_3","type":"Print"},{"id":"5","mergeIds":["isbn:123"],"marc":"MARC_BINARY_5","type":"Microform"},{"id":"2","mergeIds":["isbn:456"],"marc":"MARC_BINARY_2","type":"Electronic"}]
[{"id":"4","mergeIds":["isbn:789"],"marc":"MARC_BINARY_4","type":"Electronic"}]
[{"id":"6","mergeIds":[],"marc":"MARC_BINARY_6","type":"Print"}]
[{"id":"7","mergeIds":["issn:987"],"marc":"MARC_BINARY_7","type":"Electronic"}]
```

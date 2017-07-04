#!/bin/sh

curl -s -XGET 'localhost:9200/_cat/indices?v' | sort -k 3

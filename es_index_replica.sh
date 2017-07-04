#!/bin/sh

curl -s -XGET 'localhost:9200/_cat/indices' | grep yellow | sort -k 3 | awk '{print $3}' | while read index
do
curl -XPUT localhost:9200/${index}/_settings -d '{"index":{"number_of_replicas":0}}'
done

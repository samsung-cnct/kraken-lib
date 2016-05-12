#!/bin/sh

for d in ci release; do
  for l in latest stable; do
    for v in "" -1 -1.0 -1.1 -1.2 -1.3; do
      uri=gs://kubernetes-release/$d/$l$v.txt;
      if gsutil -q stat $uri; then
        echo $uri
        gsutil cat $uri
      fi
    done
  done
done

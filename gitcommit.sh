#!/bin/bash

THEDATE=$(date '+%Y-%m-%d %H:%M:%S')

cd /home/vuuno/userbouquets
git commit -am "$THEDATE" && git push

cd /home/vuuno/vuplus
git commit -am "$THEDATE" && git push
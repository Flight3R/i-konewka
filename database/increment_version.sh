#!/bin/bash

NEW_VERSION=$(cat version | awk -F. -v OFS=. '{++$NF; print}')

echo $NEW_VERSION > version

echo -n $NEW_VERSION

#!/bin/bash

## Getting the tag
TAG=$(git tag --sort=committerdate -l | tail -1)
# echo "main TAG: $TAG"
MAJOR=$(echo $TAG | cut -d . -f 1)
MINOR=$(echo $TAG | cut -d . -f 2)
PATCH=$(echo $TAG | cut -d . -f 3)


#### Checking if patch is empty
re='^[0-9]+$'
if ! [[ $PATCH =~ $re && ! -z "$PATCH"  ]] ; then
    PATCH=0
elif  [[ $PATCH -ge 0 ]]; then
    PATCH=$((1+$PATCH))  
fi 

#### PUSH TAG

##
echo "$MAJOR.$MINOR.$PATCH"
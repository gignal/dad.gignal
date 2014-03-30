#!/bin/bash

# Change branches
git checkout gh-pages

# get stuff from master
git checkout master -- index.html
git checkout master -- test.html
git checkout master -- gignal
git commit -m "Updates from master"

# Push 
git push origin gh-pages

# Checkout master
git checkout master

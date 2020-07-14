#!/bin/bash
#script to pull & update submodules

git pull
git submodule init
git submodule update
git submodule foreach git pull origin master

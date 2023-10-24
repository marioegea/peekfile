#!/bin/bash
input_file=$1
numberofrows=$2
head -n $2 $input_file
echo "..."
tail -n $2 $input_file

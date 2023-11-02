#!/bin/bash
input_file=$1
numberofrows=$2
if [[ -z $numberofrows ]]; then numberofrows=3 ; fi

if [[ $(wc -l < $1) -le $((2 * numberofrows)) ]] ; then cat $input_file ; fi

if [[ $(wc -l < $1) -gt $((2 * numberofrows)) ]] ; then echo WARNING ; head -n $numberofrows $input_file ; echo "..." ; tail -n $numberofrows $input_file ; fi

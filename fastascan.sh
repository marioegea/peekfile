#!/bin/bash

current_folder=${1:-"."}
N_numberoflines=${2:-"0"}

echo "--> FASTASCAN Results <--"

echo "There are a total of $(find $current_folder -type f -name "*.fa" -or -name "*.fasta" | wc -l) .fasta and .fa files in the scanned folder."

echo "The amount of unique Fasta IDs in the .fasta and .fa files is:"
awk '$1~/>/{print $1}' $(find $current_folder -type f -name "*.fa" -or -name "*.fasta") | sort | uniq | wc -l

echo " "
echo "Let's see the files individually:"
for i in $(find "$current_folder" -type f -name "*.fa" -or -name "*.fasta")
do echo " "
if [[ ! -r $i ]]; then echo "---- '$i' is not readable, it will be skipped."
else echo "---- For file "$i" :"
if [[ -h "$i" ]]; then echo " > Is a symlink."; else echo " > Is a file."; fi;

if grep -q "[^ATCGN]" < <(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g') ; then echo " > It contains $(grep ">" -c "$i") sequences, and those have a total length of $(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g'| wc -m) aminoacids."; else echo " > It contains $(grep ">" -c "$i") sequences, and those have a total length of $(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g'| wc -m) nucleotides."
fi

if [[ $N_numberoflines -eq 0 ]]; then continue
elif [[ $(wc -l < "$i") -le $((2*$N_numberoflines)) ]]; then echo "--> Total content:"; cat "$i"
else echo "--> Content:"
head -n $N_numberoflines "$i"
echo "..."
tail -n $N_numberoflines "$i"
fi
fi
done


 #CURRENT VERSION: NOV 20

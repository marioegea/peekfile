#!/bin/bash

current_folder=${1:-"."}
N_numberoflines=${2:-"0"}
#this {number:-"value"} syntax means that the arguments are 1 and 2 respectively and allows us to define a default value with ":-__".
#In this case, the default values are the current folder (".") and 0 lines.

echo "--> FASTASCAN Results <--"

echo "There are a total of $(find $current_folder -type f,l -name "*.fa" -or -type f,l -name "*.fasta" | wc -l) .fasta and .fa files in the scanned folder."
#The find construct looks for files or links ending in .fa or .fasta in the folder defined by the user (or the current folder if that argument is not specified).
#this will give out an error (in awk) if it finds unreadable files, but I've considered it's good for the user to know if there are unreadable files - if the user is then interested in changing the permits,
#it's up to him/her. 

echo "The amount of unique Fasta IDs in the .fasta and .fa files is:"
awk '$1~/>/{print $1}' $(find $current_folder -type f,l -name "*.fa" -or -type f,l -name "*.fasta") | sort | uniq | wc -l
#It count the unique 1st words if they contain ">" (from the same find construct as before) - this is like counting unique IDs.
echo " "
#this is just to add some separation.
echo "Let's see the files individually:"
for i in $(find "$current_folder" -type f,l -name "*.fa" -or -type f,l -name "*.fasta") #iteration bucle over the files found by our construct.
do echo " " 
if [[ ! -r $i ]]; then echo "---- '$i' is not readable, it will be skipped."
#A construct in the very beginning of the "for" loop that skips a useless analysis if the file iterating is not readable (! -r means not readable).
else echo "---- For file "$i" :"
if [[ -h "$i" ]]; then echo " > It is a symlink."; else echo " > It is a file."; fi;
#this simple condition allows us to differentiate between files and symlinks (which are -h).

if grep -qi "[^ATCGNU]" < <(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g') ; then echo " > It contains $(grep ">" -c "$i") sequences, and those have a total length of $(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g'| wc -m) aminoacids."; else echo " > It contains $(grep ">" -c "$i") sequences, and those have a total length of $(awk '$1!~/>/{print $0}' "$i" | tr '\n' ' ' | sed 's/ //g' | sed 's/-//g'| wc -m) nucleotides."
fi
#Okay this construct is meant to give us an analysis of the file. It's divided in two possible outcomes, aminoacids (if the first "if" turns out TRUE) or nucleotides.
#The first "IF" construct, the one that differentiates aminoacids from nucleotides, looks for letters that aren't ATCGNU (with [^ATCGNU]) in the lines that don't contain ">" (as we want to perform
#this search in the sequences, not in the FASTA headers) with grep. Grep will give a positive result (not print it, due to -q) if something else than ATCGNU (or atcgnu, as specified with -i) is found
#(ACTG for DNA, N for unspecified, U for uracil for possible RNA sequences), meaning that the sequences are aminoacidic.
#Else, it will print the same output but with nucleotides as the last word instead of aminoacids. "< <" is used to give grep a command as an argument.
#The search will be performed in all the lines that don't contain >, replacing the new lines to spaces, and then deleting both spaces and "-".
#To count the amount of sequences, we use grep ">" -c $i (-c prints the amount of occurences), and the length of those is computed with the same construct as before adding wc -m at the end,
#which counts characters but previously deleting spaces, new lines and "-".
 

if [[ $N_numberoflines -eq 0 ]]; then continue #stops this iteration and doesn't show the content of the files as no lines were specified by the user, or 0 lines were specified.
elif [[ $(wc -l < "$i") -le $((2*$N_numberoflines)) ]]; then echo "--> Total content:"; cat "$i" #if the file has 2N lines or fewer (specified with -le), we display its full content,
#as we say with "--> Total content" and then cat. If that's not the case, I've just printed "--> Content" to differentiate and head + ... + tail the amount of lines requested by the user with $2.

else echo "--> Content:"
head -n $N_numberoflines "$i"
echo "..."
tail -n $N_numberoflines "$i"
fi
fi
done


 #CURRENT VERSION: NOV 21

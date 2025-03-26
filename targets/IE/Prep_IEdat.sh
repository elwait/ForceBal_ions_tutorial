#!/bin/bash

ion="La"                                # atomic symbol for current ion
echo ${ion}
ligand="water"                          # current ligand (water, acetate, water)
echo ${ligand}

touch IE.dat
while IFS= read -r line; do
# for each distance listed in the file
    echo ${line}
    name=$(echo ${line} | awk '{ print $1 }' | tr -d ' ' )
    energy=$(echo ${line} | awk '{ print $3 }' | tr -d ' ' )
    weight=$(echo ${line} | awk '{ print $4 }' | tr -d ' ' )
    xyz="${ion}_${ligand}_${name}.xyz"
    echo "${xyz}   ${energy}    ${weight}" >> IE.dat
done < name_letter_energy_weight.txt


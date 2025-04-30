#!/bin/bash

ion="Gd"                                # atomic symbol for current ion
#echo ${ion}
ion_xyz="${ion}_t.xyz"
ligand="water"                          # current ligand (water, acetate, amide)
#echo ${ligand}
ligand_xyz="${ligand}_t.xyz"

echo '$global' >> interactions.txt
echo 'keyfile interactions.key' >> interactions.txt
echo 'energy_unit kilocalories_per_mole'  >> interactions.txt
echo '$end' >> interactions.txt
echo ' ' >> interactions.txt

echo '$system' >> interactions.txt
echo "name ${ligand}" >> interactions.txt
echo "geometry ${ligand_xyz}" >> interactions.txt
echo '$end' >> interactions.txt
echo ' ' >> interactions.txt

echo '$system' >> interactions.txt
echo "name ${ion}" >> interactions.txt
echo "geometry ${ion_xyz}" >> interactions.txt
echo '$end' >> interactions.txt
echo ' ' >> interactions.txt


while IFS= read -r line; do
# for each distance listed in the file
    #echo ${line}
    name=$(echo ${line} | awk '{ print $1 }' | tr -d ' ' )
    #echo $name
    letter=$(echo ${line} | awk '{ print $2 }' | tr -d ' ' )
    #echo $letter
    energy=$(echo ${line} | awk '{ print $3 }' | tr -d ' ' )
    #echo $energy
    weight=$(echo ${line} | awk '{ print $4 }' | tr -d ' ' )
    #echo $weight
    echo '$system' >> interactions.txt
    echo "name a${letter}" >> interactions.txt
    echo "geometry ${ion}_${ligand}_${name}_t.xyz" >> interactions.txt
    echo '$end' >> interactions.txt
    echo ' ' >> interactions.txt
done < ${ion}_${ligand}_name_letter_energy_weight_dist.txt


while IFS= read -r line; do
# for each distance listed in the file
    #echo ${line}
    name=$(echo ${line} | awk '{ print $1 }' | tr -d ' ' )
    #echo $name
    letter=$(echo ${line} | awk '{ print $2 }' | tr -d ' ' )
    #echo $letter
    energy=$(echo ${line} | awk '{ print $3 }' | tr -d ' ' )
    #echo $energy
    weight=$(echo ${line} | awk '{ print $4 }' | tr -d ' ' )
    #echo $weight
    echo '$interaction' >> interactions.txt
    echo "name BE_a${letter}" >> interactions.txt
    echo "equation a${letter} - ${ligand} - ${ion}" >> interactions.txt
    echo "energy ${energy}" >> interactions.txt 
    echo "weight ${weight}" >> interactions.txt
    echo '$end' >> interactions.txt
    echo ' ' >> interactions.txt
done < ${ion}_${ligand}_name_letter_energy_weight_dist.txt



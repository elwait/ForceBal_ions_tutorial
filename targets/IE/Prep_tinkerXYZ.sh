#!/bin/bash

ion="Gd"
ligand="water"
DIR="/work/eew947/sandia/La_params_03-26-25/all_data_input/Lu_water"

xyz_template="${ion}_${ligand}_template_t.xyz"

x_to_replace="2.184896" # ion x coord from template, only works if number not anywhere else
# also has to be used with coordinates that have been translated so changion ion X 
# moves it that much further or closer along the x axis

### Setting up input files ###
while IFS= read -r line; do
    echo $line
    name=$(echo ${line} | awk '{ print $1 }' )
    #echo $name
    dist=$(echo ${line} | awk '{ print $5 }' )
    #echo $dist
    x_coord=$(echo ${line} | awk '{ print $5 }' )
    #echo $x_coord
    ##########################################
    ############     Prep XYZ    #############
    ##########################################
    # replace La and x coord with new
    # this is mostly for visualization and reference
    # coords for calculations modified from template inputs
    cp ${DIR}/${xyz_template} ${DIR}/${ion}_${ligand}_${name}_t.xyz
    sed -i "s+${x_to_replace}+${x_coord}+g" ${DIR}/${ion}_${ligand}_${name}_t.xyz
    sed -i "s+name+${name}+g" ${DIR}/${ion}_${ligand}_${name}_t.xyz
done < ${ion}_${ligand}_name_letter_energy_weight_dist.txt


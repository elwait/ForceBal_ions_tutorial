# Install ForceBalance
I installed ForceBalance from the instructions at:
https://github.com/leeping/forcebalance

This involves setting up a conda environment (`forcebal`),
which will be something like:

`conda install --strict-channel-priority -c conda-forge forcebalance`

# Change ForceBalance to work with Tinker pairwise parameters
If you want to optimize `POLPAIR`, `VDWPAIR`, or `VDWPR` , you have to edit `tinkerio.py`

In my case, 
ForceBalance is located here: `/home/eew947/anaconda3/envs/forcebal/bin/ForceBalance.py`

and `tinkerio.py` is located at:
`/home/eew947/anaconda3/envs/forcebal/lib/python3.12/site-packages/forcebalance/tinkerio.py`

I had to add the following lines to `pdict` (which was after line 93 of `tinkerio.py`)

```
         'VDWPR'        : {'Atom':[1,2], 3:'R',4:'E'},     # Van der Waals pair parameters
         'VDWPAIR'      : {'Atom':[1,2], 3:'R',4:'E'},     # Van der Waals pair parameters
         'POLPAIR'      : {'Atom':[1,2], 3:'D'},           # Pair damping factor
```




# Setting up
The directory I am working in is `/work/eew947/sandia/REM_params`

Inside the working directory, you need to prepare a few things.
The overall structure at the end will be:

```
working_dir                    # /work/eew947/sandia/REM_params in my case
  |- opt_1.in                  # input file, has to end in .in
  |- opt_1..out                # output file showing progress and final params
  +- bin                       # contains Tinker cpu executables
  |   |- alchemy
  |   |- analyze
  |   |- anneal
  |   |- <etc>                 # rest of Tinker executables
  +- forcefield_1
  |   |- amoeba09_la.prm       # starting forcefield, params being optimized have comments
  +- targets                   # data ForceBal is matching to goes here
  |   |- IE                    # Interaction Energies, structures, and related files
  |   |   |- amoeba09_la.prm   # starting forcefield, params being optimized have comments
  |   |   |- interactions.key  # has some simulation info and points to amoeba09_la.prm
  |   |   |- interactions.txt  # info about the interactions, structures, energies, and weights
  |   |   |- IE.dat            # lists the structures, energies, and weights for each point
  |   |   |- La.xyz            # ion in Tinker format (with atom types and classes)
  |   |   |- water.xyz         # ligand structure in Tinker format (with atom types and classes)
  |   |   |- La_water_1-0.xyz  # complex *.xyz at 1st point, which has separation of ~1 A
  |   |   |- La_water_1-1.xyz  # complex *.xyz at 2nd point, which has separation of ~1.1 A
  |   |   |- <etc>             # complex .xyz for each point
  +- result
  |   |- opt_1 
  |   |   |- amoeba09_la.prm # optimized force field, generated on completion
```

## bin (Tinker)
I put my Tinker cpu executables in `/work/eew947/sandia/REM_params/bin`

If you have copied all of my files, they should all be there already.

Otherwise, make sure you know where your Tinker is. You will have to add the path to the input files later.


## targets (Target Data) / IE (Interaction Energies)
First, you need a folder (`targets`) with the data that ForceBalance will try to match to.
Inside this folder, each type of data being used will have its own folder.
In my case, I only have one subfolder, `IE` , which contains interactions energies.


If you are starting from my files:
```
cd targets/IE
```


If you are doing this from scratch:
```
mkdir targets
cd targets
mkdir IE
cd IE
```

In the IE folder, you need:
```
amoeba09_la.prm   # can probably have it elsewhere and put the path but this was fine
interactions.key
interactions.txt  # see next section about script
IE.dat            # see section after next about script
```


I  wrote scripts to prepare some of the files, so if you are using those, you need to:
1. copy `amoeba09_la.prm` to targets/IE
2. prepare `interactions.key`
3. prepare `name_letter_energy_weight.txt`
4. edit and run `Prep_InteractionsTXT.sh`  # now you have `interactions.txt`
5. edit and run `Prep_IEdat.sh`            # now you have `IE.dat`


### 1. copy `amoeba09_la.prm` to `targets/IE` and edit


If you are starting from my files:
`amoeba09_la.prm` should already be in `targets/IE`

Check that the end of that file has a section with the parameters you are working on.
It will be directly after the `polarize` section.

In the case of La3+ with water, the section looks like this:


```
# for La3+


atom         501   501    La3+   "Lanthanum Ion La+3"          57    138.91    0
multipole    501   0    0               3.00000
                                        0.00000    0.00000    0.00000
                                        0.00000
                                        0.00000    0.00000
                                        0.00000    0.00000    0.00000


polarize     501          1.764  0.14                        # PRM 3
vdw          501          3.92  0.940                        # PRM 2 3

```


The 'atom' line lists the `atom_type` , `atom_class` symbol, name, atomic number, mass, and honestly I can't find what the last one is.
For La3+ with water, we will get the default polarization and vdw parameters. We will then use those when working on acetate and acetamide.

#### Polarization
The `polarize` line starts with the atom type.
The atomic polarization is `1.764` in this example. That was taken directly from QM.

*Make sure that the polarization has been updated to reflect the current QM method.*

The next number is the starting value for the polarization damping parameter. The `# PRM 3` at the end of the line indicates to ForceBalance that the third parameter in this line is being optimized.

#### vdW
The `vdw` line starts with the atom class. In this case, they are the same number. It is not always like that, as each different atom has a type but several atoms may be part of the same class.
The vdW parameters also include the well depth and the radius. Both of these parameters will be included in the optimization, which is why the line ends with `# PRM 2 3` .

If you are starting from scratch:

Copy `amoeba09_la.prm` to the directory.
Then, add the section at the bottom. Polarization should come from QM.
For the others, you can use the parameters from a similar ion as a starting point. Not sure that it matters too much.
For lanthanides, you can start with La3+.
Make sure that you choose a new atom type number (and that this number is consistent in all your Tinker files).

### Prepare `interactions.txt` and `IE.dat`
I have scripts for preparing these files.
This section will include instructions using those scripts.
If you are doing it another way, check the example files to get an idea of what they should be like.


### 2. Prepare `interactions.key` with information used by `interactions.txt`
An example of an `interactions.key` file is printed below:

```
parameters       amoeba09_la.prm
digits 10
openmp-threads   1

POLARIZATION MUTUAL
polar-eps 0.00001
```

### 3. Make `name_letter_energy_weight.txt`
First, you need to prepare `name_letter_energy_weight.txt` (example included in folder).
This file includes columns for the name I used to represent the structure, letter for use as an index with ForceBalance, the QM energy of that structure, and the weight you want ForceBalance to place on matching at that point.
Typically, structures/points closer to the energetic minimum are given more weight (`100.0`).
Points further away are given a weight of `1.0`.
You can play around with different intermediate weights and higher weight on different parts of the interaction energy curve.
I dislike this aspect because it feels like more of an art than a science, and I'd like to find a better way eventually.
I have used a Boltzmann distribution to determine the weights before but it basically made only the equilibrium have weight `100.0` and everything else was `1.0`.


### 4. Edit and run `Prep_InteractionsTXT.sh`

`Prep_InteractionsTXT.sh` is for preparing `interactions.txt`:

Edit this script so that the variables `ion` and `ligand` are correct.
Check that `ion_xyz` and `ligand_xyz` fit your file names (or change them).
`nohup bash Prep_InteractionsTXT.sh > Prep_InteractionsTXT.out &`

Check that `interactions.txt` was created:
`ls -ltr interactions.txt`

Take a look at it.
There should be a section of global parameters at the top:
```
$global
keyfile interactions.key
energy_unit kilocalories_per_mole
$end
```

After that, there should be many sets of 4 lines.
Each group of `$system` lines corresponds to a structure.
Example:
```
$system
name water
geometry water.xyz
$end

$system
name La
geometry La.xyz
$end

$system
name aa
geometry La_water_1-0.xyz
$end
```

Next, there will be groups of `$interaction` lines.
They include information about the ineraction.
For example:
```
$interaction
name BE_aa
equation aa - water - La
energy 1533.33
weight 1.0
$end
```

`BE_aa` refers to the binding energy for the geometry called aa.
Here, that is the La3+ - water complex with a separation of about 1 A (`La_water_1-0.xyz`)

`Energy(bind) = Energy(complex) - Energy(ligand) - Energy(ion)`

So the La3+ - water binding energy at that geometry = `E(La_water_1-0.xyz) - E(water.xyz) - E(La.xyz)`

or:
`equation aa - water - La`

Then, the binding energy is listed (in kcal/mol, according to the `$global` setting `energy_unit kilocalories_per_mole` in the beginning of the file:
`energy 1533.33`

This is followed by the weight, which is 1.0 here, as we are around the repulsive wall rather than near the stable equilibrium geometry.
`weight 1.0`

### 4. Edit and run `Prep_IEdat.sh`
`Prep_IEdat.sh` is for preparing `IE.dat`:

Edit this script so that the variables `ion` and `ligand` are correct.
Once again, check that `ion_xyz` and `ligand_xyz` fit your file names.
`nohup bash Prep_IEdat.sh > Prep_IEdat.out &`

Check that `IE.dat` was created:
`ls -ltr IE.dat`

Take a look at it.
There should be three columns: `structure` `energy` `weight`
It should look something like this:
```
La_water_1-0.xyz   1533.33    1.0
La_water_1-1.xyz   958.08    1.0
La_water_1-2.xyz   600.83    1.0
La_water_1-3.xyz   371.47    1.0
La_water_1-4.xyz   217.69    1.0
La_water_1-5.xyz   110.87    1.0
La_water_1-6.xyz   35.74    1.0
La_water_1-7.xyz   -16.56    1.0
La_water_1-8.xyz   -51.97    1.0
La_water_1-9.xyz   -74.92    1.0
La_water_2-0.xyz   -88.84    1.0
La_water_2-1.xyz   -96.34    50.0
La_water_2-2.xyz   -99.38    100.0
La_water_2-3.xyz   -99.38    100.0
La_water_2-4.xyz   -97.41    50.0
La_water_2-5.xyz   -94.19    10.0
La_water_2-6.xyz   -90.25    1.0
La_water_2-7.xyz   -85.97    1.0
La_water_2-8.xyz   -81.61    1.0
La_water_2-9.xyz   -77.37    1.0
La_water_3-0.xyz   -73.42    1.0
La_water_3-1.xyz   -69.85    1.0
La_water_3-2.xyz   -66.71    1.0
La_water_3-3.xyz   -64.02    1.0
La_water_3-4.xyz   -61.75    1.0
La_water_3-5.xyz   -59.88    1.0
```


Now you are all done with setting up `targets`.

`cd ../../` to return to the main working directory.


## opt_1.in (Input File)

Now you must prepare the input file.
I have called this `opt_1.in` and it is included as an example.
I got it from Dr. Chengwen Liu and updated/inserted the following lines:

```
# (string) Directory containing force fields, relative to project directory
ffdir forcefield_1
```

```
# Path to TINKER
tinkerpath /work/eew947/sandia/REM_params/bin
```

```
priors
   VDWPRR                                 : 0.2
   VDWPRE                                 : 0.2
   POLPAIRD                               : 0.2
/priors
$end
```


## forcefield_1 (starting forcefield)
We already prepared the parameter file, so we just need to copy it over.

`cp ${your_dir}/REM_params/targets/IE/ameoba_09.prm ${your_dir}/REM_params/forcefield_1/.`


## Run ForceBalance
Now we are set up and can run ForceBalance!

```
cd ${your_dir}/REM_params # if you aren't there already
conda activate forcebal
nohup ForceBalance.py opt_1.in > opt_1.out &
```


## opt_1.out (Generated Output File)
ForceBalance will generate `opt_1.out` in the working directory with updated progress and finally, the optimized parameters.
When ForceBalance is finished, the end of the `*.out` file will look something like this:


```
#========================================================#
#|              Final physical parameters:              |#
#========================================================#
   0 [  1.5830e-01 ] : POLARIZET/501
   1 [  4.1900e+00 ] : VDWS/501
   2 [  6.8965e-02 ] : VDWT/501
----------------------------------------------------------
#==============================================================================#
#|  The force field has been written to the result/opt_1 directory.  |#
#|    Input file with optimization parameters saved to opt_1.sav.    |#
#==============================================================================#
Wall time since calculation start: 1203.6 seconds
#========================================================#
#|                Calculation Finished.                 |#
#|      ---==(  May the Force be with you!  )==---      |#
#========================================================#
```


The optimized forcefield will also be saved to `/result/opt_1/amoeba09_la.prm`


The energies from Tinker `analyze` for each point using the optimized parameters are also in the output file.
For example, it may look something like this:

```
#=====================================================================#
#| ^[[92m    Interaction Energies (kcal/mol), Objective =  2.23540e+05    ^[[0m |#
#| ^[[92m  Interaction              Calc.      Ref.     Delta        Term ^[[0m |#
#=====================================================================#
BE_aa                      1721.030  1533.330   187.700  35231.12220
BE_ab                       953.643   958.080    -4.437     19.68362
BE_ac                       522.140   600.830   -78.690   6192.04449
BE_ad                       272.136   371.470   -99.334   9867.27694
BE_ae                       123.963   217.690   -93.727   8784.68813
BE_af                        34.811   110.870   -76.059  57849.12733
BE_ag                       -19.156    35.740   -54.896  30136.09139
BE_ah                       -51.631   -16.560   -35.071  12299.99991
BE_ai                       -70.698   -51.970   -18.728   3507.46298
BE_aj                       -81.251   -74.920    -6.331    400.78363
BE_ak                       -86.320   -88.840     2.520     63.52064
BE_al                       -87.823   -96.340     8.517   3626.87391
BE_am                       -87.001   -99.380    12.379  15323.31805
BE_an                       -84.674   -99.380    14.706  21628.05075
BE_ao                       -81.393   -97.410    16.017  12827.06623
BE_ap                       -77.541   -94.190    16.649   2771.81532
BE_aq                       -73.385   -90.250    16.865    284.41862
BE_ar                       -69.115   -85.970    16.855    284.09716
BE_as                       -64.864   -81.610    16.746    280.41530
BE_at                       -60.728   -77.370    16.642    276.94626
BE_au                       -56.770   -73.420    16.650    277.20905
BE_av                       -53.031   -69.850    16.819    282.87173
BE_aw                       -49.533   -66.710    17.177    295.04338
BE_ax                       -46.285   -64.020    17.735    314.52878
BE_ay                       -43.285   -61.750    18.465    340.93963
BE_az                       -40.526   -59.880    19.354    374.57908
-----------------------------------------------------------------------
```

The first column `Interaction` has the titles for each geometry used in `interactions.txt` .

The `Calc.` column is the interaction energy calculated using the optimized parameters.

The `Ref.` column contains the QM interaction energies.

The `Delta` column is the difference between the calculated and reference energies.

The `Term` column is related to the gradient I think. I can't find anything in the docs or GitHub issues. Couldn't find the values anywhere else in the output either.


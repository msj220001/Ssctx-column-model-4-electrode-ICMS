# Ssctx-column-model-4-electrode-ICMS

This model is based on the somatosensory cortex column model mentioned in:
K. Kumaravelu, J. Sombeck, L. E. Miller, S. J. Bensmaia and W. M. Grill (2022) 
Stoney vs. Histed: Quantifying the spatial effects of intracortical microstimulation. 
Brain stimulation 

https://github.com/ModelDBRepository/267691

Please see the original GitHub repository to install the entire model.
Only the files that were modified to enable multi-electrode stimulation are in this repository.

1. NEURON will need to be installed from source on a high-performance computing cluster to allow parallel processing
2. Pull the repository for the original model
   - For example:  git clone https://github.com/modelDBRepository/267691
3. Replace the default model files with the modified files that enable multi-electrode stimulation

The files that need to be replaced are:
run_model.q (located in the main directory)
init_icms.hoc (located in the main directory)
xtra.mod (located in the "mechanisms" directory)
"cells" directory




== About the "cells" directory: ==
"cells"
    |> 25 directories, each about a single cell *type*
       |> "synapses" // contains the NEURON model mechanisms for synapse behavior

It was specifically the synapses.hoc file for each cell type that was modified to account for additional electrodes.
However, for the sake of convenience, simply replacing the entire "cells" directory is faster.




== About run_model.q: ==
This file will need to be modified to fit your high-performance computing cluster setup, based on what SLURM/SBATCH commands it accepts.
The example I have included in this repository shows how the SBATCH calls are different from the default run_model.q in the original model.
You can modify run_model.q using a text editor.

The partition label is the specific name of the HPC cluster for my university.
Nodes are the number of CPUs to use per array.
Array numbers are also tied to the cell ID, in that array 3 would run cell type 3.
There are 25 cell types. I often ran arrays in groups of 5, such as 1-5, 6-10, 11-15, 16-20, 21-25.
This is because these groupings of cell types have different numbers of cell counts to run in parallel.
For example. Cell types 1-5 have 90 cells each, so it finishes processing in parallel faster than cell types 21-25 which have 345 cells each.
ntasks is how many cores of each CPU to use.
For my HPC's specifications, there were up to 16 cores per CPU, so ntasks could be set up to 16,
but I noticed some errors with the parallel processing when it was set to ntasks = 16, so I usually did 14 or 15.

It may be possible that your HPC user instruction guide uses the terms "CPU" or "cores" differently.
Either way, the basic premise is that the array IDs are also used to call and initialize specific cell types based on numbers 1-25.

But once you have modified run_model.q to work for your set up, you then use the HPC terminal/command line and do:
sbatch run_model.q
^^ This runs the script

I do not guarantee that either the default run_model.q or my modified run_model.q will work for your HPC setup.
I used ChatGPT + trial and error to figure out what set of SLURM/SBATCH commands worked for my setup.




== After running the model: ==
There will be many .dat files, which are something like: "vm_soma_celltype#_cellcountID#.dat" or "vm_axon_celltype#_cellcountID#.dat"

You will need to offload these onto your local computer to visualize the data in MATLAB.

What I noticed for any vm_axon_....dat files is that the last column of data for the last cell_countIDs were corrupted in that they were missing a line/column. 
In addition, the number of cell_countIDs that were corrupted was related to the number of parallel tasks (ntasks).
For example, cell type 1 has 90 cells. Then if ntask=14, then vm_axon_1_76.dat through vm_axon_1_90.dat would have one line of data missing.

That is what the python files in the "dat corrections" directory are for.
They would delete the corrupted lines and then copy the previous time steps' data. This made sure the matrix was the proper size for later steps of data analysis in MATLAB. For our study, we were not interested in that later time point anyway, so deleting that data was irrelevant. But perhaps if you do a different study, then that is something to consider.

check_file_lines.py and check_vm_axon.sh check which files are missing lines of data.
autofix_files.py fixes them en masse, expecting either 1 line to be missing or 2. However, sometimes the data is corrupted in a way that the autofix_files.py doesn't expect, so the single_fix.py is used to manually fix those .dat files that are uniquely corrupted.




== Running extract_spike_times.m ==
Place "extract_spike_times.m" in the same folder that has all .dat files.
Once it is done running, it will produce data_axon_#.mat and data_soma_#.mat files

Create a copy of the "data_analysis" directory and move all the .mat files into the "data_analysis" directory.
Copy and paste "axon_analysis_TJS.m" into your "data_analysis" directory and run it in MATLAB.
The specific lines that may need to be modified are the amplitude and electrode coordinates.
Once axon_analysis_TJS.m is done running, it will produce a MATLAB figure with the column model. Save this .fig file.


== Additional Analyses ==
GetEllipsoidDataOnly.m
- Modify the center to define the centroid of all 4 electrodes
- capturePercentages array can be set to be multiple different percentage values, such as [50, 75, 80, 100]
- Run the script. A pop-up will let you select a .fig file to run this analysis on.
- This script will output values for the total number of activated neurons, the ellipsoid radii length for each axis (x, y, z), the number of captured neurons inside the ellipsoid, and the volume of the ellipsoid in micrometers

GetMatrixEllipsoidData.m
- Modify the center to define the centroid of all 4 electrodes
- capturePercentages accepts only a single value
- Run the script. A pop-up will let you select a .fig file to run this analysis on.
- This script will output values for the ellipsoid as well as produce a .fig with the ellipsoid of specified capture percentage and the activated neurons will be red for inside the ellipsoid and black for outside the ellipsoid.

At the same time, any of the above files should have produced matrix files (.mat) in the "Extracted Matrices" folder.

plotRedDotsMatrix.m
- Run the script. Pop-ups will appear twice. Each time, select a matrix file (.mat) for the corresponding ICMS pattern you would like to compare.
- This script will produce 4 figures. Figures 1 and 2 show each ICMS pattern's activated neurons. Figure 3 shows which neurons were activated by both patterns.
- Figure 4 will produce another pop-up, asking you to input the centroids of each ICMS pattern and the corresponding ellipsoid axes or radii dimensions. Once you input these, Figure 4 will show the overlapping ellipsoids and activated neuronal populations together.

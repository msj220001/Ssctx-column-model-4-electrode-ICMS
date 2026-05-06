#!/bin/bash

#SBATCH --partition=128s
#SBATCH --nodes=1
#SBATCH --array=1-3
#SBATCH --ntasks=2

mpirun -np $SLURM_NTASKS ./mechanisms/x86_64/special -NSTACK 100000 -NFRAME 20000 -Py_NoSiteFlag -nobanner -c -mpi "cell_id=$SLURM_ARRAY_TASK_ID" init_icms.hoc

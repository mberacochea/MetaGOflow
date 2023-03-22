#!/bin/bash

#SBATCH --partition=fat
#SBATCH --nodes=1
#SBATCH --nodelist=
#SBATCH --ntasks-per-node=40
#SBATCH --mem=
#SBATCH --mail-user=haris.zafr@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --job-name="taxInv"
#SBATCH --output=tax_invent_fat_water.output

# Load module
module load python/3.7.8
module load singularity/3.7.1 

# Run the wf
./run_wf.sh -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz -n dev_dataset -d DEV_DATASET -s

# ./run_wf.sh -e ERR855786 -d TEST_SIMPLIFIED_PFAM -n ERR855786 -s

# Disable the module
module purge

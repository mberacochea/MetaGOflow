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
#./run_wf.sh -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz -n wgs-SRR1620013 -d MOTUS -s
./run_wf.sh -f test_input/DBB_AABVOSDA_1_1_HMNJKDSX3.UDI256_clean.fastq.gz -r test_input/DBB_AABVOSDA_1_2_HMNJKDSX3.UDI256_clean.fastq.gz -n water-sample-DBB_AABVOSDA_1_2_HMNJKDSX3.UDI256 -d WATER_SAMPLE_TAX_FAT -s

# ./run_wf.sh -e ERR855786 -d TEST_SIMPLIFIED_PFAM -n ERR855786 -s

# Disable the module
module purge

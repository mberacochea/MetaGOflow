#!/bin/bash

#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --nodelist=
#SBATCH --ntasks-per-node=20
#SBATCH --mem=
# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="eosc-test"
#SBATCH --output=public_pfam.output
#SBATCH --mail-user=haris.zafr@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --requeue


# load miniconda
module load miniconda3/default

# activate the conda env for our wf
conda activate EOSC-CWL

# load the Singularity module 
module load singularity/3.7.1

# run the wf
./run_wf.sh -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz -n SRR1620013 -d TEST_FILES_CGC1 -s
# ./run_wf.sh -f test_input/SRR1620013_1.fastq.gz -r test_input/SRR1620013_2.fastq.gz -n SRR1620013 -d TEST_FULL_FILES_CGC1 -s
# ./run_wf.sh -e ERR855786 -d TEST_SIMPLIFIED_PFAM -n ERR855786 -s


# disable the 
module purge


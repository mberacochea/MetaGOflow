# metaGOflow: A workflow for marine Genomic Observatories data analysis
## An EOSC-Life project



[![Build Status](https://travis-ci.org/EBI-Metagenomics/pipeline-v5.svg?branch=master)](https://travis-ci.com/EBI-Metagenomics/pipeline-v5)

The workflows developed in the framework of this project are based on `pipeline-v5` of the MGnify resource. 

> This branch is a child of the [`pipeline_5.1`](https://github.com/hariszaf/pipeline-v5/tree/pipeline_5.1) branch 
that contains all CWL descriptions of the MGnify pipeline version 5.1.

The following comes from the initial repo and describes how to get the databases required.

---

# pipeline-v5

This repository contains all CWL descriptions of the MGnify pipeline version 5.0.

## Documentation

For a thorough read-the-docs, click [here](https://emg-docs.readthedocs.io/en/latest/analysis.html#overview). 

---

We kindly recommend use the [MGnify resource](https://www.ebi.ac.uk/metagenomics/) for data processing.

If you want to run pipeline locally, we recommend you use our pre-build docker containers. 

## Requirements to run pipeline 

- python3 [v 3.6+]
- docker [v 19.+] or singularity
- cwltool [v 3.+] or toil [v 4.2+]

- hdd for databases ~133G

### Docker

All the tools are containerized. 

Unfortunately, antiSMASH and InterProScan containers are very big. We provide two options:
1. Pre-install these tools. The instructions on how to setup the environment are [here](environment/README.md).

2. Use containers. First of all you need to uncomment *hints* in **InterProScan-v5.cwl** and **antismash_v4.cwl**.
Pre-pull containers from https://hub.docker.com/u/microbiomeinformatics
```bash
docker pull microbiomeinformatics/pipeline-v5.interproscan:v5.36-75.0
docker pull microbiomeinformatics/pipeline-v5.antismash:v4.2.0
```


## Installation


### Create `conda` environment 



### Get the EOSC-Life marine GOs workflow

```bash
git clone https://github.com/EBI-Metagenomics/pipeline-v5.git 
cd pipeline-v5
```

#### Download necessary dbs

You can download databases for the EOSC-Life GOs workflow by running the
`download_dbs.sh` script.
If you have one or more already in your system, then create a symbolic link pointing 
at the `ref-dbs` folder. 






## How to run


- activate the conda env 

- edit the `gos_wf.yml` file to set the parameter values of your choice

- In case you are working in a HPC with Singularity, enable Singularity

- run 

```
./run_wf.sh -n false -n osd-short -d short-test-case -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz
```

> In case you are using Docker, it is strongly recommended to **avoid** installing it through `snap`


`RuntimeError`: slurm currently does not support shared caching, because it does not support cleaning up a worker after the last job finishes. 
Set the `--disableCaching` flag if you want to use this batch system.

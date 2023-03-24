# metaGOflow: A workflow for marine Genomic Observatories' data analysis

## An EOSC-Life project

[![Build Status](https://travis-ci.org/EBI-Metagenomics/pipeline-v5.svg?branch=master)](https://travis-ci.com/EBI-Metagenomics/pipeline-v5)

The workflows developed in the framework of this project are based on `pipeline-v5` of the MGnify resource.

> This branch is a child of the [`pipeline_5.1`](https://github.com/hariszaf/pipeline-v5/tree/pipeline_5.1) branch
> that contains all CWL descriptions of the MGnify pipeline version 5.1.

## Dependencies

- python3 [v 3.8+]
- [Docker](https://www.docker.com) [v 19.+] or [Singularity](https://apptainer.org)
- [cwltool](https://github.com/common-workflow-language/cwltool) [v 3.+]

Depending on the analysis you are about to run, disk requirements vary.
Indicatively, you may have a look at the metaGOflow publication for computing resources used in various cases.

### Get the EOSC-Life marine GOs workflow

```bash
git clone https://github.com/emo-bon/MetaGOflow
cd MetaGOflow
```

### Download necessary databases

You can download databases for the EOSC-Life GOs workflow by running the
`download_dbs.sh` script under the `Installation` folder.

If you have one or more already in your system, then create a symbolic link pointing
at the `ref-dbs` folder.

## How to run

### Set up the environment

#### Run once - Setup environment

[Setup Environment](/DEPENDENCIES.md#during-development)

#### Run every time

```bash
conda activate EOSC-CWL
``` 

### Run the workflow

- Edit the `config.yml` file to set the parameter values of your choice.

#### Using Singularity

##### Standalone
- run:
   ```bash
   ./run_wf.sh -s -n osd-short -d short-test-case -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz
   ``

##### Using a cluster

- Create a job file (e.g., SBATCH file)

- Enable Singularity, e.g. module load Singularity

- Add the run line to the job file


#### Using Docker

##### Standalone
- run:
    ``` bash
    ./run_wf.sh -n osd-short -d short-test-case -f test_input/wgs-paired-SRR1620013_1.fastq.gz -r test_input/wgs-paired-SRR1620013_2.fastq.gz
  ```
  HINT: If you are using Docker, you may need to run the above command with remove `-s' flag.

## Hints and tips

1. In case you are using Docker, it is strongly recommended to **avoid** installing it through `snap`.

2. `RuntimeError`: slurm currently does not support shared caching, because it does not support cleaning up a worker
   after the last job finishes.
   Set the `--disableCaching` flag if you want to use this batch system.

3. In case you are having errors like:

```
cwltool.errors.WorkflowException: Singularity is not available for this tool
```

You may run the following command:

```
singularity pull --force --name debian:stable-slim.sif docker://debian:stable-sli
```

## Contribution

To make contribution to the project a bit easier, all the MGnify `conditionals` and `subworkflows` under
the `workflows/` directory that are not used in the metaGOflow framework, have been removed.   
However, all the MGnify `tools/` and `utils/` are available in this repo, even if they are not invoked in the current
version of metaGOflow.
This way, we hope we encourage people to implement their own `conditionals` and/or `subworkflows` by exploiting the
currently supported `tools` and `utils` as well as by developing new `tools` and/or `utils`.


<!-- cwltool --print-dot my-wf.cwl | dot -Tsvg > my-wf.svg -->

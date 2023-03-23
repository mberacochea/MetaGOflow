# Dependencies 

## During development

Clone our GitHub repo

Set a conda environment with `Python 3.7`

```
conda create -n EOSC-CWL python=3.7
```

Get `cwl` 

```
pip install cwlref-runner
pip install cwltool
```

Get `cwltest`

```
pip install cwltest
```

Get `biopython`


    pip install biopython


The `tabix` package is also required. To get it please run:

    sudo apt-get update -y
    sudo apt-get install -y tabix



## To run our workflows

The simplest way to run the pipeline, if we want to start with the analysis of raw reads, is:

``` 
cd pipeline-v5/workflows
cwltool raw-reads-wf--v.5-cond.cwl ymls/raw-reads--v.5-cond.yml
```


## Testing samples

We use 2 partial samples from the Human Metagenome Project ([SRR1620013](https://www.ebi.ac.uk/ena/browser/view/SRR1620013) and [SRR1620014](https://www.ebi.ac.uk/ena/browser/view/SRR1620014))
They are partial as only a small part of their sequences have been kept, in terms for the pipeline to test in a fast way. 





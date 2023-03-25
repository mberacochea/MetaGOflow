# Dependencies 

## To run workflow

- Clone our GitHub repo

- ```bash
  conda create -n EOSC-CWL python=3.8
  ```

- ```bash
  conda activate EOSC-CWL
  ```

- ```bash
  pip install cwlref-runner cwltool[all]

  ```
 
### To create the ro-crates

- ```bash
  pip install rocrate
  ```

- The `tabix` package is also required. To get it please run:

    ###### DEBIAN/UBUNTU
   
    ```bash
    sudo apt-get update -y
    sudo apt-get install -y tabix
    ```

    ###### CENTOS
    @FIXME: missing

## During development

Clone our GitHub repo

Set a conda environment with `Python 3.8`

``` bash
conda create -n EOSC-CWL python=3.8
```

Get `cwl`, `cwltest` and `biopython`

``` bash
pip install cwlref-runner cwltool cwltest biopython
```

The `tabix` package is also required. To get it please run:

##### DEBIAN/UBUNTU
```bash
sudo apt-get update -y
sudo apt-get install -y tabix
```
##### CENTOS
@FIXME: missing


## Testing samples
The samples are available in the `test_input` folder.

We use ? @FIXME partial samples from the Human Metagenome Project ([SRR1620013](https://www.ebi.ac.uk/ena/browser/view/SRR1620013) and [SRR1620014](https://www.ebi.ac.uk/ena/browser/view/SRR1620014))
They are partial as only a small part of their sequences have been kept, in terms for the pipeline to test in a fast way. 


.. _installation:

Installation
=====

.. autosummary::
   :toctree: generated


Dependencies
------------

To run metaGOflow you need to make sure you have the following set on your computing environment first:

- python3 [v 3.8+]
- `Docker <https://www.docker.com>` [v 19.+] or `Singularity <https://apptainer.org>` [v 3.7.+] / `Apptainer <https://apptainer.org>` [v 1.+]
- `cwltool <https://github.com/common-workflow-language/cwltool>` [v 3.+]
- `rdflib <https://rdflib.readthedocs.io/en/stable/>` [v 6.+]
- `rdflib-jsonld <https://pypi.org/project/rdflib-jsonld/>` [v 0.6.2]
- `ro-crate-py <https://github.com/ResearchObject/ro-crate-py>` [v 0.7.0]
- `pyyaml <https://pypi.org/project/PyYAML/>` [v 6.0]
- `Node.js <https://nodejs.org/>` [v 10.24.0+]
- Available storage ~160GB for databases

You may either ensure you have those locally or you may use a conda environment we have built including them (.. autofunction:: conda_environment.yml). 

On top of those, disk requirements need to be considered and depending on the analysis you are about to run they vary.
Indicatively, you may have a look at the metaGOflow publication for computing resources used in various cases.




Installation
------------

Get source code:


.. code-block:: bash 
  git clone https://github.com/emo-bon/MetaGOflow.git



Setup environment:

Get dependencies to run metaGOflow:

.. code-block:: bash 
  conda env create -f conda_environment.yml


This will create a ``conda`` environment called ``metagoflow``.
By running `:bash: conda env list` you will see your new environment.
In case `conda` is not already installed on your computing system, you may follow 
the instructions to get it `here <https://conda.io/projects/conda/en/latest/user-guide/install/index.html>`.




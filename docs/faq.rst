
.. _faq:


Frequently asked questions
----------------------------


Can I use ``metaGOflow`` with host-associated data?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In case of host-associated data, the user needs to make sure the host sequences have been removed before start using ``metaGOflow``.



Does my PCR protocol affect the ``metaGOflow`` performance?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


What is an RO-Crate and how it benefits?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



Docker or Singularity?
~~~~~~~~~~~~~~~~~~~~~~

metaGOflow supports both Docker (default) and Singularity container technologies. 
By default, metaGOflow will use Docker; therefore, in this case Docker is a dependency for the workflow to run. 
However, in most HPC systems Singularity is preferred.

To enable Singularity, you need to add the `-s` argument when calling metaGOflow.
In case Singularity runs fail with an error message mentioning that a `.sif` file is missing, 
you need to force-pull the images to be used from metaGOflow. 
To make things easier, we have built the [get_singularity_images.sh](https://github.com/emo-bon/pipeline-v5/blob/develop/Installation/get_singularity_images.sh) to do so.

.. code-bloc:: bash
    cd Installation
    bash get_singularity_images.sh

Now, you are ready to run metaGOflow with Singularity!

.. hint:: In case you are using Docker, it is strongly recommended to avoid installing it through `snap`.


What can I do with the ``metaGOflow`` data products?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




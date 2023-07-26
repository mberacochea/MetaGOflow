.. _data_products:

Description of ``metaGOflow``'s data products
=============================================


Quality filtering step
-----------------------

- ```*.fastq.trimmed.fasta`` **files** 
Filtered .fasta files of the forward (R1) and reverse (R2) reads. Its content strongly depends on the 
``fastp``-related `:doc:/args_and_params` parameters. 
A record in a .fasta file consists of 2 parts: a *header* that always starts with a ``>``` and describes
the sequence (experiment id, coordinates etc.) and the sequence. 
Example:

.. code-block:: bash

    >SRR1620013.60-C038EACXX:5:1101:06662:02714-1
    GAATGGAATGGAATGGAATGGAACCTGTCTCTTATACACATCTCTGAGCGGGCTGGCAAG
    GCAGACCGATCACGATCTCGTATGCCGTCCTCTGCTTGACA

- ``.fastq.trimmed.qc_summary`` **files**
A report for the number of sequences removed after each trimming/filtering task
for the forward and the reverse reads.
Example:

.. code-block:: bash

    Submitted nucleotide sequences	100000
    Nucleotide sequences after format-specific filtering	3495
    Nucleotide sequences after length filtering	3477
    Nucleotide sequences after undetermined bases filtering	3477

- ``.merged.fasta`` **file**
A ``.fasta`` file with the filtered, merged reads; the forward and reverse reads merge into one. 

.. code-block:: bash

    >SRR1620013.10-C038EACXX:5:1101:04403:02479-1-merged-101-9
    GGGTGGGACTGCAAGCTTTCCAAACTACAGAAAATGCCAGGACGACTATTTTAAAATATT
    TTTAAAATCTGTAAAATAATTGGAATGAACAATACACATATTCCTGTCTC


- ``*.merged.qc_summary`` **file**
Like the ``.fastq.trimmed.qc_summary`` file but for the case of the merged reads.


- ``fastp.html`` **file**
An .html file with visual contents of the quality of both the forward and the reverse 
and the merged reads. 
For a thorough description of this file, the reader may watch this `video <https://youtu.be/VrIW4EcHly4?t=510>`_.


- ``*merged.unfiltered_fasta`` **file** 
Often, problematic characters in headers of .fasta and/or .fastq files may appear. 
In this file, the merged .fastq file has been edited so such characters have been replaced with dashes.


.. code-block:: bash

    @V1:1:HWLTKDRXY:1:2202:19524:21151-1-merged-108-0
    GCAAAGAGTACGCTGTCGTAGTTTCTCAAGTCTTTGCCGTGCCCCAATGCCTGATTCGCCGCAAAGGTGTCTAACCCTTGTTCTCGTTGCAGGGAGTAGACCTTCACC
    +
    FFFFFFFF:FFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFF:FF:F:FFFF:FFFFFFFFFFFFFFF:FFFF


This file is necessary for running the `mOTUs package <https://github.com/motu-tool/mOTUs>`_.

















.. _usage:


Raw data
----------------

``metaGOflow`` takes as input shotgun sequences in ``.fastq`` format without any particual dependency on their production.

The sequences file can be provided to ``metaGOflow`` directly or an ENA accession id of the run of intereste can be provided and 
``metaGOflow`` will fetch the data automatically. 



Arguments
----------

``metaGOflow`` has 2 levels where the user sets arguments. 
Inline, a few technical arguments are provided as described below:

.. code-block:: bash
   -f                  Forward reads fasta file path (mandatory if and olny if -e not used).
   -r                  Reverse reads fasta file path (mandatory if and olny if -e not used).
   -e                  ENA run accession number. Its raw data will be fetched and then analysed (if used, -f and -r should not me set). 
   -d                  Output directory name (mandatory).
   -n                  Name of run and prefix to output files (mandatory).
   -s                  Run workflow using Singularity (Docker is the by default container technology). Works as a flag, i.e. by adding -s in your command, Singularity is going to be used.
   -u                  ENA username in case of private data. 
   -k                  ENA password in case of private data.
   -b                  Keep tmp folder. Works as flag. 

One may have the raw data to be used either already locally or fetch them from ENA.
In the first case, the ``-f`` and ``-r`` arguments are used to provide the forward and the reverse reads correspondingly.
In the latter, ``-f`` and ``-r`` are not to be used and the user may provide the accession id using the ``-e`` argument. 
If and only if private data from ENA are to be used, the used needs to provide his/her credentials to the corresponding ENA account 
through the ``-u`` and ``-k`` arguments.

``metaGOflow`` builds a great number of intermediate files that usually require a significant disk space, based on the sample and the steps to be performed.
By default it removes all the intermediate files once it's completed. 
The user may keep them by using the ``-b`` flag.


Parameters tuning
------------------

The steps to be performed in a ``metaGOflow`` run and the parameters of the software to be invoked 
are provded through the  ``config.yml``  file [`url <https://github.com/emo-bon/MetaGOflow/blob/eosc-life-gos/config.yml>`_].


``metaGOflow`` does not need to perform all its steps at once; one may run the first 
.. math:: n  steps
On top of that, it can use the output of previous steps to run the next ones without the need of re-running the first ones. 

The steps to be performed are selected by setting ``True`` or ``False`` the following parameters in the ``config.yml`` file.




+---------------------------------+----------------------------------------------------------------------------------------------------------+
|**Parameter**                    |**Description**                                                                                           |
+---------------------------------+----------------------------------------------------------------------------------------------------------+
|``qc_and_merge_step``            | Performs a quality control of the raw reads, filters and merges them                                     |
+---------------------------------+----------------------------------------------------------------------------------------------------------+
|``taxonomic_inventory``          |  Using the filtered and merged sequences, it returns a taxonomic inventory                               |
+---------------------------------+----------------------------------------------------------------------------------------------------------+
|``cgc_step``                     |  Exports coding sequences                                                                                |
+---------------------------------+----------------------------------------------------------------------------------------------------------+
|``reads_functional_annotation``  |  Performs functionall annotation on the coding genes found using a list of resources: InterPro, KEGG     |
+---------------------------------+----------------------------------------------------------------------------------------------------------+
|``assemble``                     |  Assembles the filtered and merged sequences to contigs                                                  |
+---------------------------------+----------------------------------------------------------------------------------------------------------+









.. code:: yaml

   # Global
   threads: 40

   # As a rule of thumb keep that as floor(threads/8) where threads the previous parameter
   interproscan_threads: 5

   # fastp parameters
   detect_adapter_for_pe: false
   overrepresentation_analysis: false
   min_length_required: 108
   force_polyg_tail_trimming: 
   base_correction: false
   qualified_phred_quality: 
   unqualified_percent_limit: 
   disable_trim_poly_g:
   overlap_len_require: 
   cut_right: false
   correction: false

   # Assembly
   memory: 0.9
   min-contig-len: 500

   # Combined Gene Caller // the size is in MB
   cgc_chunk_size: 200

   # # Taxonomic inference using Diamond and the contigs
   # diamond_maxTargetSeqs: 1

   # Functional annotation
   protein_chunk_size_IPS: 1000000 # 20000000
   protein_chunk_size_eggnog: 4000000
   protein_chunk_size_hmm: 4000000





.. code:: yaml

   # -----------------
   # Run wf partially
   # -----------------

   # The following variables should be considered only in case 
   # the user has already ran some of the first steps and wants to 
   # run the following parts of the workflow. 
   # For example, you have ran the quality contron and the rna prediction steps
   # and you would like to go just for the assembly step. 

   # Currently, because of CWL-limitations (see https://github.com/common-workflow-language/cwl-v1.3/issues/3)
   # you need to provide values to some of the following variables even if it is not to be used.
   # To that end, we provide pseudo-files under the /test_input folder you may use 

   # ATTENTION! 
   # Give full path of your files, NOT relative !

   # Mandatory for running any step; merged pre-processed reads (*.merged.fasta)
   processed_reads: {
   class: File, 
   format: "edam:format_1929",
   path:  results/ERR599171.merged.fasta
   }

   # Mandatory for running the taxonomy inventory step
   input_for_motus: {
   class: File, 
   path:  workflows/pseudo_files/pseudo.merged.unfiltered.fasta
   }


   # Mandatory for running the functional annotation steps
   # If produced previously from metaGOflow, will have a suffix like: .cmsearch.all.tblout.deoverlapped 
   maskfile: {
   class: File, 
   path:  results/ERR599171.merged.cmsearch.all.tblout.deoverlapped
   }

   # Mandatory for the functional annotation step 
   # Give the number of the sequences included in the predicted_faa_from_previous_run file 
   # You may get this by running:
   # grep -c ">" <*..merged_CDS.faa>
   count_faa_from_previous_run: 18934897

   # Mandatory for the functional annotation step
   predicted_faa_from_previous_run: {
   class: File, 
   format: "edam:format_1929",
   path:  results/ERR599171.merged_CDS.faa
   }

   # Mandatory for running the assembly step 
   processed_read_files: 
   - class: File
      path:  workflows/pseudo_files/pseudo_1_clean.fastq.trimmed.fasta
   - class: File
      path:  workflows/pseudo_files/pseudo_2_clean.fastq.trimmed.fasta





.. Attention:: The intermediate files produced in a complete run of ``metaGOflow`` depending 
   on the sample size, may reach 1 TB of storage.






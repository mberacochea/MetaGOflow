#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

doc: |
  This workflow will run a QC on the reads and then ti will
  do the RNA annotation of them.

inputs:

  # Global
  forward_reads: File?
  reverse_reads: File?


  # QC-rna-predict
  run_qc_rna_predict: 
    type: boolean
  qc_min_length: int

  # RNA prediction 
  ssu_db: {type: File, secondaryFiles: [.mscluster] }
  lsu_db: {type: File, secondaryFiles: [.mscluster] }
  ssu_tax: [string, File]
  lsu_tax: [string, File]
  ssu_otus: [string, File]
  lsu_otus: [string, File]
  rfam_models:
    type:
      - type: array
        items: [string, File]
  rfam_model_clans: [string, File]
  other_ncRNA_models: string[]
  ssu_label: string
  lsu_label: string
  5s_pattern: string
  5.8s_pattern: string


  # for assembly step 
  min-contig-len: int
  assembly: 
    type: boolean
  memory: int





steps:

  qc-rna-predict:

    doc: 
      The rna prediction step is based on pre-processed and merged reads. 
      This step aims at the pre-processing and merging the raw reads so its output can be used 
      for the rna prediction step. 

    when: 
      $(inputs.run_qc_rna_predict == true)

    run: 
      conditionals/raw-reads-1-qc-cond.cwl

    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      run_qc: run_qc_rna_predict

    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - filtered_fasta
      - input_files_hashsum_paired
      - input_files_hashsum_single
      - fastp_filtering_json

  rna-prediction:

    run: 
      conditionals/raw-reads-2-rna-only.cwl

    when: 
      $(inputs.run_qc_rna_predict == true)

    in:
      filtered_fasta: qc-rna-predict/filtered_fasta
      ssu_db: ssu_db
      lsu_db: lsu_db
      ssu_tax: ssu_tax
      lsu_tax: lsu_tax
      ssu_otus: ssu_otus
      lsu_otus: lsu_otus
      rfam_models: rfam_models
      rfam_model_clans: rfam_model_clans
      other_ncRNA_models: other_ncRNA_models
      ssu_label: ssu_label
      lsu_label: lsu_label
      5s_pattern: 5s_pattern
      5.8s_pattern: 5.8s_pattern

    out:
      - sequence_categorisation_folder
      - taxonomy-summary_folder
      - rna-count
      - compressed_files
      - chunking_nucleotides
      - optional_tax_file_flag

  qc-paired:

    run: 
      conditionals/qc-paired.cwl

    # when: 
    #   $(inputs.assembly == true)

    in: 
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length

    out: 
      - trimmed_fr
      - trimmed_rr
      - trimmed_seqs

  assembly: 

    run: 
      conditionals/megahit_paired.cwl

    # when: 
    #   $(inputs.assembly == true)
    
    in: 
      min-contig-len: min-contig-len
      memory: memory
      forward_reads: qc-paired/trimmed_fr
      reverse_reads: qc-paired/trimmed_rr

    out: 
      - contigs



  # contigs_functional_annotation: 

  #   run: 
  #   when: 
  #      $(inputs.assembly == true)

  #   in: 







outputs:
  # pre-qc step output
  qc-statistics:
    type: Directory?
    outputSource: qc-rna-predict/qc-statistics
  qc_summary:
    type: File?
    outputSource: qc-rna-predict/qc_summary
  qc-status:
    type: File?
    outputSource: qc-rna-predict/qc-status
  hashsum_paired:
    type: File[]?
    outputSource: qc-rna-predict/input_files_hashsum_paired
  hashsum_single:
    type: File?
    outputSource: qc-rna-predict/input_files_hashsum_single
  fastp_filtering_json_report:
    type: File?
    outputSource: qc-rna-predict/fastp_filtering_json
  filtered_fasta:
    type: File[]?
    outputSource: qc-rna-predict/filtered_fasta

  # rna-prediction step output
  sequence-categorisation_folder:
    type: Directory?
    outputSource: rna-prediction/sequence_categorisation_folder
  taxonomy-summary_folder:
    type: Directory?
    outputSource: rna-prediction/taxonomy-summary_folder
  rna-count:
    type: File?
    outputSource: rna-prediction/rna-count

  chunking_nucleotides:
    type: File[]?
    outputSource: rna-prediction/chunking_nucleotides

  no_tax_flag_file:
    type: File?
    outputSource: rna-prediction/optional_tax_file_flag

  # paired-end qc
  paired-trimmed-files:
    type: File[]
    outputSource: qc-paired/trimmed_seqs


  # ASSEMBLY OUTPUT
  contigs: 
    type: File
    outputSource: assembly/contigs




$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

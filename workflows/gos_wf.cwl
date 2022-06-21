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
  run_qc: 
    type: boolean
    default: true

  # RNA prediction 
  run_qc_rna_predict: int
  qc_min_length: int

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

  # Assembly step 
  min-contig-len: int
  assembly: int
  memory: int


steps:

  rna-prediction:

    doc: 
      The rna prediction step is based on pre-processed and merged reads. 
      This step aims at the pre-processing and merging the raw reads so its output can be used 
      for the rna prediction step. 

    run: conditionals/raw-reads-1-qc-cond.cwl
    when: $(inputs.run_qc_rna_predict != 0)

    in:
      run_qc_rna_predict: run_qc_rna_predict
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      run_qc: run_qc
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
      - qc-statistics
      - qc_summary
      - qc-status
      - filtered_fasta
      - input_files_hashsum_paired
      - fastp_filtering_json
      # - sequence-categorisation_folder
      # - taxonomy-summary_folder
      # - rna-count
      # - compressed_files
      # - chunking_nucleotides
      # - no_tax_flag_file


  qc-paired:

    run: conditionals/qc-paired.cwl

    when: $(inputs.assembly != 0)

    in: 
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      assembly: assembly

    out: 
      - trimmed_fr
      - trimmed_rr
      - trimmed_seqs
      - qc-statistics

  # assembly: 

  #   run: conditionals/megahit_paired.cwl

  #   when: $(inputs.assembly != false)
    
  #   in: 
  #     min-contig-len: min-contig-len
  #     memory: memory
  #     forward_reads: qc-paired/trimmed_fr
  #     reverse_reads: qc-paired/trimmed_rr

  #   out: 
  #     - contigs



  # contigs_functional_annotation: 

  #   run: 
  #   when: $(inputs.assembly == true)

  #   in: 




outputs:

  # A/ RNA PREDICTION 
  # ------------------

  # pre-qc step output
  qc-statistics:
    type: Directory?
    outputSource: rna-prediction/qc-statistics
    pickValue: all_non_null

  qc_summary:
    type: File?
    outputSource: rna-prediction/qc_summary
    pickValue: all_non_null

  hashsum_paired:
    type: File[]?
    outputSource: rna-prediction/input_files_hashsum_paired
    pickValue: all_non_null

  fastp_filtering_json_report:
    type: File?
    outputSource: rna-prediction/fastp_filtering_json
    pickValue: all_non_null

  filtered_fasta:
    type: File[]?
    outputSource: rna-prediction/filtered_fasta
    pickValue: all_non_null

  # # rna-prediction step output
  # sequence-categorisation_folder:
  #   type: Directory?
  #   outputSource: rna-prediction/sequence-categorisation_folder

  # taxonomy-summary_folder:
  #   type: Directory?
  #   outputSource: rna-prediction/taxonomy-summary_folder

  # rna-count:
  #   type: File?
  #   outputSource: rna-prediction/rna-count

  # chunking_nucleotides:
  #   type: File[]?
  #   outputSource: rna-prediction/chunking_nucleotides

  # no_tax_flag_file:
  #   type: File?
  #   outputSource: rna-prediction/no_tax_flag_file


  # ASSEMBLY
  # ---------

  # paired-end qc
  paired-trimmed-files:
    type: File[]?
    outputSource: qc-paired/trimmed_seqs
    pickValue: all_non_null

  paired-stats:
    type: Directory[]?
    outputSource: qc-paired/qc-statistics


  # # ASSEMBLY OUTPUT
  # contigs: 
  #   type: File?
  #   outputSource: assembly/contigs




$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

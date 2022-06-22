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
  run_qc_rna_predict: boolean
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
  assembly: boolean
  memory: int

  # CGC
  CGC_config: [string?, File?]
  CGC_postfixes: string[]
  cgc_chunk_size: int



steps:

  # QC FOR RNA PREDICTION
  qc-rna-prediction:

    doc: 
      The rna prediction step is based on pre-processed and merged reads. 
      This step aims at the pre-processing and merging the raw reads so its output can be used 
      for the rna prediction step. 

    run: conditionals/raw-reads-1-qc-cond.cwl
    when: $(inputs.run_qc_rna_predict != false)

    in:
      run_qc_rna_predict: run_qc_rna_predict
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      run_qc: run_qc

    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - input_files_hashsum_paired
      - fastp_filtering_json
      - filtered_fasta        # output for next step


  # RNA PREDICTION STEP 
  rna-prediction:

    run: conditionals/raw-reads-2-rna-only.cwl

    when: $(inputs.run_qc_rna_predict != false)

    in:
      run_qc_rna_predict: run_qc_rna_predict
      filtered_fasta: qc-rna-prediction/filtered_fasta
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
      - ncRNA

  # QC FOR ASSEMBLY CASE
  qc-assembly:

    run: conditionals/qc-paired.cwl

    when: $(inputs.assembly != false)

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

  # ASSEMBLY USING MEGAHIT
  assembly: 

    run: conditionals/megahit_paired.cwl

    when: $(inputs.assembly != false)
    
    in: 
      assembly: assembly
      min-contig-len: min-contig-len
      memory: memory
      forward_reads: qc-assembly/trimmed_fr
      reverse_reads: qc-assembly/trimmed_rr

    out: 
      - contigs
      - options

  # COMBINED GENE CALLER
  cgc:

    when: $(inputs.assembly != false && inputs.run_qc_rna_predict != false)

    in:
      run_qc_rna_predict: run_qc_rna_predict
      assembly: assembly
      input_fasta: qc-rna-prediction/filtered_fasta
      maskfile: rna-prediction/ncRNA
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ predicted_proteins, predicted_seq, count_faa ]
    run: subworkflows/assembly/cgc/CGC-subwf.cwl





  # functional_annotation:
  # run: ../../subworkflows/assembly/Func_ann_and_post_proccessing-subwf.cwl
  #   in:
  #      check_value: cgc/count_faa

  #      filtered_fasta: filtered_fasta
  #      rna_prediction_ncRNA: rna_prediction/ncRNA
  #      cgc_results_faa: cgc/predicted_faa
  #      protein_chunk_size_hmm: protein_chunk_size_hmm
  #      protein_chunk_size_IPS: protein_chunk_size_IPS

  #      func_ann_names_ips: func_ann_names_ips
  #      InterProScan_databases: InterProScan_databases
  #      InterProScan_applications: InterProScan_applications
  #      InterProScan_outputFormat: InterProScan_outputFormat
  #      ips_header: ips_header

  #      func_ann_names_hmmer: func_ann_names_hmmer
  #      HMM_gathering_bit_score: HMM_gathering_bit_score
  #      HMM_omit_alignment: HMM_omit_alignment
  #      HMM_database: HMM_database
  #      HMM_database_dir: HMM_database_dir
  #      hmmsearch_header: hmmsearch_header

  #      go_config: go_config
  #      ko_file: ko_file
  #      type_analysis: { default: 'Reads' }
  #   out:
  #     - functional_annotation_folder
  #     - stats



outputs:

  # A/ RNA PREDICTION 
  # ------------------

  # pre-qc step output
  qc-statistics:
    type: Directory?
    outputSource: qc-rna-prediction/qc-statistics
    pickValue: all_non_null

  qc_summary:
    type: File?
    outputSource: qc-rna-prediction/qc_summary
    pickValue: all_non_null

  hashsum_paired:
    type: File[]?
    outputSource: qc-rna-prediction/input_files_hashsum_paired
    pickValue: all_non_null

  fastp_filtering_json_report:
    type: File?
    outputSource: qc-rna-prediction/fastp_filtering_json
    pickValue: all_non_null

  filtered_fasta:
    type: File
    outputSource: qc-rna-prediction/filtered_fasta
    pickValue: all_non_null

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

  # ASSEMBLY
  # ---------

  # paired-end qc
  paired-trimmed-files:
    type: File[]?
    outputSource: qc-assembly/trimmed_seqs
    pickValue: all_non_null

  paired-stats:
    type: Directory[]?
    outputSource: qc-assembly/qc-statistics

  # ASSEMBLY OUTPUT
  contigs: 
    type: File?
    outputSource: assembly/contigs


  # FUNCTIONAL ANNOTATION
  # ----------------------

  # CGC 
  predicted_faa:
    type: File
    format: edam:format_1929
    outputSource: cgc/predicted_proteins
  predicted_ffn:
    type: File
    format: edam:format_1929
    outputSource: cgc/predicted_seq
  count_faa:
    type: int
    outputSource: cgc/count_faa





$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: ""
s:author: "Haris Zafeiropoulos"

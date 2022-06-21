#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

    forward_reads: File?
    reverse_reads: File?

    qc_min_length: int
    run_qc: 
      type: boolean
      default: true

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


outputs:

  # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null

  fastp_filtering_json:
    type: File?
    outputSource: overlap_reads/fastp_report

  qc-statistics:
    type: Directory?
    outputSource: qc_stats/output_dir

  qc_summary:
    type: File?
    outputSource: length_filter/stats_summary_file

  qc-status:
    type: File?
    outputSource: QC-FLAG/qc-flag

  filtered_fasta:
    type: File
    outputSource:
      - length_filter/filtered_file
      - convert_trimmed_reads_to_fasta/fasta
    pickValue: first_non_null

  # RNA PREDICTION
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

  compressed_files:
    type: File[]
    outputSource: rna-prediction/compressed_files

steps:

  # << calculate hashsum >>
  hashsum_paired:
    run: ../../utils/generate_checksum/generate_checksum.cwl
    scatter: input_file
    in:
      input_file:
        - forward_reads
        - reverse_reads
    out: [ hashsum ]

  # << SeqPrep (only for paired reads) + gunzip for paired and single>>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../subworkflows/seqprep-qc-cond-subwf.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      paired_reads_length_filter: { default: 70 }
      qc: run_qc
    out: [ unzipped_single_reads, count_forward_submitted_reads, fastp_report ]

  # << Trim and Reformat >>
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: overlap_reads/unzipped_single_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
    out: [reads1_trimmed]

  #fastq
  clean_fasta_headers:
    run: ../../utils/clean_fasta_headers.cwl
    in:
      sequences: trim_quality_control/reads1_trimmed
    out: [ sequences_with_cleaned_headers ]

  #fasta
  convert_trimmed_reads_to_fasta:
    run: ../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    in:
      fastq: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ fasta ]

  # << QC filtering >>
  length_filter:
    run: ../../tools/qc-filtering/qc-filtering.cwl
    in:
      seq_file: convert_trimmed_reads_to_fasta/fasta
      submitted_seq_count: overlap_reads/count_forward_submitted_reads
      stats_file_name: {default: 'qc_summary'}
      min_length: qc_min_length
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]

  count_processed_reads:
    run: ../../utils/count_fasta.cwl
    in:
      sequences: length_filter/filtered_file
      number: { default: 1 }
    out: [ count ]

  # << QC FLAG >>
  QC-FLAG:
    run: ../../utils/qc-flag.cwl
    in:
      qc_count: count_processed_reads/count
    out: [ qc-flag ]

  # << QC >>
  qc_stats:
    run: ../../tools/qc-stats/qc-stats.cwl
    in:
      QCed_reads: length_filter/filtered_file
      sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]

  # RNA PREDICTION STEP 
  rna-prediction:

    run: raw-reads-2-rna-only.cwl

    in:
      filtered_fasta: length_filter/filtered_file
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

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

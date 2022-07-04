#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
    forward_reads: File?
    reverse_reads: File?
    threads: int
    min_length_required: int
    force_polyg_tail_trimming: boolean
    overlap_min_len: int
    qualified_phred_quality: int
    unqualified_phred_quality: int
    disable_trim_poly_g: boolean
    qc_stats_folders:
      type: string[]
      default: [ "forward_qc", "reverse_qc" ]
    # qc_min_length: 
    #   type: int
    #   default: 100


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

  # << SeqPrep + gunzip >>
  fastp_trim_and_overlap: 
    label: Paired-end overlapping reads are merged
    run: ../subworkflows/seqprep-subwf.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      min_length_required: paired_reads_length_filter
      disable_trim_poly_g: disable_trim_poly_g
      force_polyg_tail_trimming: force_polyg_tail_trimming
      threads: threads
      overlap_min_len: overlap_min_len
      unqualified_phred_quality: unqualified_phred_quality
      qualified_phred_quality: qualified_phred_quality
    out: [ out_fastq1, out_fastq2, merged_fastq, count_forward_submitted_reads, fastp_report, both_paired ]


# -----------> trimommatic step output
    # out: [ reads1_trimmed_paired, reads2_trimmed_paired, both_paired ]

  #fastq
  clean_fasta_headers:
    run: ../../utils/clean_fasta_headers.cwl
    scatter: sequences
    in:
      sequences: fastp_trim_and_overlap/both_paired
    out: [ sequences_with_cleaned_headers ]

  #fasta - output called *.unclean
  convert_trimmed_reads_to_fasta:
    run: ../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    scatter: fastq
    in:
      fastq: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ fasta ]

  # << QC filtering >>
  pe_length_filter:
    run: ../../tools/qc-filtering/qc-filtering.cwl
    scatter: seq_file
    in:
      seq_file: convert_trimmed_reads_to_fasta/fasta
      submitted_seq_count: fastp_trim_and_overlap/count_forward_submitted_reads
      stats_file_name: {default: 'qc_summary' }
      min_length: min_length_required 
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]


  count_processed_reads:
    run: ../../utils/count_fasta.cwl
    scatter: sequences
    in:
      sequences: pe_length_filter/filtered_file
      number: { default: 1 }
    out: [ count ]

  # << QC FLAG >>
  QC-FLAG:
    run: ../../utils/qc-flag.cwl
    scatter: qc_count
    in:
        qc_count: count_processed_reads/count
    out: [ qc-flag ]

  # << QC >>
  qc_stats:

    scatter: [ QCed_reads, sequence_count, out_dir_name ]
    scatterMethod: dotproduct
    run: ../../tools/qc-stats/qc-stats.cwl
    in:
        QCed_reads: pe_length_filter/filtered_file
        sequence_count: count_processed_reads/count
        out_dir_name: qc_stats_folders
          # valueFrom: $(inputs.QCed_reads.basename)   # why is this not working ?
    out: [ output_dir, summary_out ]

outputs:

  # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null

  fastp_filtering_json:
    type: File?
    outputSource: fastp_trim_and_overlap/fastp_report

  trimmed_fr: 
    type: File?
    outputSource: fastp_trim_and_overlap/out_fastq1

  trimmed_rr: 
    type: File?
    outputSource: fastp_trim_and_overlap/out_fastq2

  trimmed_seqs: 
    type: File[]?
    outputSource: fastp_trim_and_overlap/both_paired

  trimmed_fasta_seqs: 
    type: File[]?
    outputSource: convert_trimmed_reads_to_fasta/fasta

  qc-statistics:
    type: Directory[]
    outputSource: qc_stats/output_dir

  qc_summary:
    type: File[]
    outputSource: pe_length_filter/stats_summary_file

  filtered_fasta:
    type: File[]?
    outputSource: pe_length_filter/filtered_file

  motus_input:
    type: File[]?
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers

  merged: 
    type: File? 
    outputSource: fastp_trim_and_overlap/merged_fastq


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"

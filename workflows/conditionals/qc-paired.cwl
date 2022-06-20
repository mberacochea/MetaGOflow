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
    qc_min_length: 
      type: int
      default: 100

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
    run: ../subworkflows/seqprep-subwf.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      paired_reads_length_filter: { default: 70 }
    out: [ count_forward_submitted_reads, fastp_report ]

  # << Trim and Reformat >>
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../tools/Trimmomatic/Trimmomatic-v0.36-PE.cwl
    in:
      reads1: forward_reads
      reads2: reverse_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: PE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
    out: [ reads1_trimmed_paired, reads2_trimmed_paired, both_paired ]

  #fastq
  clean_fasta_headers:
    run: ../../utils/clean_fasta_headers.cwl
    scatter: sequences
    in:
      sequences: trim_quality_control/both_paired
    out: [ sequences_with_cleaned_headers ]

  #fasta - output called *.unclean
  convert_trimmed_reads_to_fasta:
    run: ../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    scatter: fastq
    in:
      fastq: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ fasta ]

  # << QC filtering >>
  length_filter:
    run: ../../tools/qc-filtering/qc-filtering.cwl
    scatter: seq_file
    in:
      seq_file: convert_trimmed_reads_to_fasta/fasta
      submitted_seq_count: overlap_reads/count_forward_submitted_reads
      stats_file_name: {default: 'qc_summary' }
      min_length: qc_min_length 
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]  
       

  count_processed_reads:
    run: ../../utils/count_fasta.cwl
    scatter: sequences
    in:
      sequences: length_filter/filtered_file
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
    run: ../../tools/qc-stats/qc-stats.cwl
    scatter: [QCed_reads, sequence_count, out_dir_name]
    scatterMethod: dotproduct
    in:
        QCed_reads: length_filter/filtered_file
        sequence_count: count_processed_reads/count
        out_dir_name:
          valueFrom: $(inputs.QCed_reads.basename)
    out: [ output_dir, summary_out ]




outputs:

  # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null

  fastp_filtering_json:
    type: File?
    outputSource: overlap_reads/fastp_report

  trimmed_fr: 
    type: File?
    outputSource: trim_quality_control/reads1_trimmed_paired

  trimmed_rr: 
    type: File?
    outputSource: trim_quality_control/reads2_trimmed_paired

  trimmed_seqs: 
    type: File[]?
    outputSource: trim_quality_control/both_paired

  trimmed_fasta_seqs: 
    type: File[]?
    outputSource: convert_trimmed_reads_to_fasta/fasta

  qc-statistics:
    type: Directory[]
    outputSource: qc_stats/output_dir

  qc_summary:
    type: File[]
    outputSource: length_filter/stats_summary_file

  filtered_fasta:
    type: File[]?
    outputSource: length_filter/filtered_file

  motus_input:
    type: File[]?
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers



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

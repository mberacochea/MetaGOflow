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
    min_length_required: int
    force_polyg_tail_trimming: boolean
    overlap_min_len: int
    qualified_phred_quality: int
    unqualified_phred_quality: int
    disable_trim_poly_g: boolean
    threads: int
    base_correction: boolean

outputs:

  count_forward_submitted_reads:
    type: int
    outputSource:
      - count_submitted_reads/count
    pickValue: first_non_null

  fastp_report:
    type: File?
    outputSource: fastp_paired/json_report

  out_fastq1:
    type: File
    outputSource: fastp_paired/out_fastq1

  out_fastq2:
    type: File?
    format: $(inputs.fastq2.format)
    outputSource: fastp_paired/out_fastq2

  merged_fastq: 
    type: File? 
    format: $(inputs.fastq1.format)
    outputSource: fastp_paired/merged_fastq

  html_report:
    type: File
    outputSource: fastp_paired/html_report

  json_report:
    type: File
    outputSource: fastp_paired/json_report

  both_paired: 
    type: File[]?
    format: edam:format_1930
    outputSource: fastp_paired/both_paired

steps:

  # << unzipping paired reads >>
  count_submitted_reads:
    run: ../../utils/count_lines/count_lines.cwl
    in:
      sequences: forward_reads
      number: { default: 4 }
    out: [ count ]

  # filter paired-end reads
  fastp_paired:
    run: ../../tools/fastp/fastp.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      merge: {default: true}
      min_length_required: min_length_required
      disable_trim_poly_g: disable_trim_poly_g
      force_polyg_tail_trimming: force_polyg_tail_trimming
      threads: threads
      overlap_min_len: overlap_min_len
      unqualified_phred_quality: unqualified_phred_quality
      qualified_phred_quality: qualified_phred_quality
      base_correction: base_correction

    out: [ out_fastq1, out_fastq2, both_paired, merged_fastq, html_report, json_report ]  # unzipped


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
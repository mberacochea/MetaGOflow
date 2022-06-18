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
    paired_reads_length_filter: int

outputs:

  count_forward_submitted_reads:
    type: int
    outputSource:
      - count_submitted_reads/count
    pickValue: first_non_null

  fastp_report:
    type: File?
    outputSource: filter_paired/json_report

steps:

  # << unzipping paired reads >>
  count_submitted_reads:
    run: ../../utils/count_lines/count_lines.cwl
    in:
      sequences: forward_reads
      number: { default: 4 }
    out: [ count ]

  # filter paired-end reads (for single do nothing)
  filter_paired:
    run: ../../utils/fastp/fastp.cwl
    in:
      fastq1: forward_reads
      fastq2: reverse_reads
      min_length_required: paired_reads_length_filter
      base_correction: { default: false }
      disable_trim_poly_g: { default: false }
      force_polyg_tail_trimming: { default: false }
      threads: {default: 8}
    out: [ out_fastq1, out_fastq2, json_report ]  # unzipped




$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
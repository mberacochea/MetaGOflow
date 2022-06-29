#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Modified from https://github.com/common-workflow-library/bio-cwl-tools/blob/release/fastp/fastp.cwl
requirements:
    InlineJavascriptRequirement: {}

hints:
    DockerRequirement:
        dockerPull: microbiomeinformatics/pipeline-v5.fastp:0.20.0

baseCommand: [ fastp ]

arguments: [
        --detect_adapter_for_pe,
        --overrepresentation_analysis,
        $(inputs.merge),
        $(inputs.merged_out),
        --correction, 
        --cut_right, 
        $(inputs.force_polyg_tail_trimming),
        $(inputs.overlap_min_len),
        --length_required=$(inputs.min_length_required),
        --thread=$(inputs.threads),
        --html, "fastp.html", 
        --json, "fastp.json",
        --qualified_quality_phred=$(inputs.qualified_phred_quality),
        --unqualified_percent_limit=$(inputs.unqualified_phred_quality),
        $(inputs.disable_trim_poly_g),
        -i, $(inputs.fastq1),
        -I, $(inputs.fastq2),
        -o, $(inputs.fastq1.nameroot).fastp.fastq,
        -O, $(inputs.fastq2.nameroot).fastp.fastq
]

inputs:

    merge: 
      type: boolean
      default: true
      inputBinding: 
        valueFrom: 
          ${
            if (inputs.merge != false){
              return '--merge';
            } else {
              return '';
            }
          }

    merged_out: 
      type: boolean?
      default: true
      inputBinding: 
        prefix: --merged_out
        valueFrom: 
          ${
            if (inputs.merge != false){
              return inputs.fastq1.nameroot.split(/_(.*)/s)[0] + '.merged.fastq';
            } else {
              return '';
            }
          }

    fastq1:
      type: File
      format:
        - edam:format_1930 # FASTA
        - edam:format_1929 # FASTQ
    fastq2:
      format:
        - edam:format_1930 # FASTA
        - edam:format_1929 # FASTQ
      type: File?

    threads:
      type: int?
      default: 1

    qualified_phred_quality:
      type: int?
      default: 15

    unqualified_phred_quality:
      type: int?
      default: 40

    min_length_required:
      type: int?
      default: 50

    force_polyg_tail_trimming:
      type: boolean?
      default: false
      inputBinding:
        valueFrom: 
          ${
            if (inputs.force_polyg_tail_trimming != false){
              return '--trim_poly_g';
            } else {
              return '';
            }
          }

    disable_trim_poly_g:
      type: boolean?
      default: false
      inputBinding:
        valueFrom: 
          ${
            if (inputs.disable_trim_poly_g == true){
              return '--disable_trim_poly_g';
            } else {
              return '';
            }
          }

    base_correction:
      type: boolean?
      inputBinding:
        valueFrom: 
          ${
            if (inputs.merge == true){
              return '--correction';
            } else {
              return '';
            }
          }

    overlap_min_len: 
      type: int
      default: 30
      inputBinding:
        valueFrom:
          ${
            if (inputs.merge == true){
              return '--overlap_len_require='+inputs.overlap_min_len;
            } else {
              return '';
            }
          }

#  overlap_diff_limit (default 5) and overlap_diff_limit_percent (default 20%). 
#  Please note that the reads should meet these three conditions simultaneously.

outputs:
    out_fastq1:
       type: File
       format: $(inputs.fastq1.format)
       outputBinding:
          glob: $(inputs.fastq1.nameroot).fastp.fastq
    out_fastq2:
       type: File?
       format: $(inputs.fastq2.format)
       outputBinding:
          glob: $(inputs.fastq2.nameroot).fastp.fastq
    merged_fastq: 
      type: File? 
      format: $(inputs.fastq1.format)
      outputBinding:
          glob: '*.merged.fastq'
    html_report:
      type: File
      outputBinding:
          glob: fastp.html
    json_report:
      type: File
      outputBinding:
          glob: fastp.json

$namespaces:
  edam: http://edamontology.org/
  s: http://schema.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
  - https://schema.org/version/latest/schemaorg-current-http.rdf
s:author: "Haris Zafeiropoulos"

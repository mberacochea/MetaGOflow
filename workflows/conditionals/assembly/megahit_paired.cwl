#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

# For Megahit version 1.2.9
label: "megahit: metagenomics assembler"

hints:
  DockerRequirement:
    dockerPull: "quay.io/biocontainers/megahit:1.2.9--h2e03b76_1"
    
requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ megahit ]

arguments:

  - valueFrom: $(runtime.tmpdir)
    prefix: --tmp-dir

  - valueFrom: $(runtime.cores)
    prefix: --num-cpu-threads

inputs:

  memory:
    type: int?
    label: memory to run assembly
    inputBinding:
        prefix: -m

  min-contig-len:
    type: int?
    default: 500
    inputBinding:
      prefix: "--min-contig-len"

  forward_reads:
    type:
      - File?
      - type: array
        items: File
    inputBinding:
      prefix: "-1"
      itemSeparator: ","

  reverse_reads:
    type:
      - File?
      - type: array
        items: File
    inputBinding:
      prefix: "-2"
      itemSeparator: ","

outputs:
  contigs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: megahit_out/final.contigs.fa
  log:
    type: File
    format: iana:text/plain
    outputBinding:
      glob: megahit_out/log

  options:
    type: File
    outputBinding:
      glob: megahit_out/options.json


$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

doc : |
  https://github.com/voutcn/megahit/wiki

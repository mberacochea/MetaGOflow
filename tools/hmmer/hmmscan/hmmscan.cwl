#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Biosequence analysis using profile hidden Markov models"

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.hmmer:v3.2.1

requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    ramMin: 6000
    coresMin: 4
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}

baseCommand: ["hmmscan"]

arguments:
  - valueFrom: '> /dev/null'
    shellQuote: false
    position: 10
  - valueFrom: '2> /dev/null'
    shellQuote: false
    position: 11
  - prefix: --domtblout
    valueFrom: $(inputs.seqfile.nameroot)_hmmscan.tbl
    position: 2
  - prefix: --cpu
    valueFrom: '4'
  - prefix: -o
    valueFrom: '/dev/null'

inputs:

  omit_alignment:
    type: boolean?
    inputBinding:
      position: 1
      prefix: "--noali"

  filter_e_value:
    type: float?
    inputBinding:
      position: 3
      prefix: "-E"

  gathering_bit_score:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--cut_ga"

  name_database:
    type: string

  data:
    type: Directory
    inputBinding:
      valueFrom: $(self.path)/$(inputs.name_database)
      position: 5

  seqfile:
    format: edam:format_1929  # FASTA
    type: File
    inputBinding:
      position: 6
      separate: true

stdout: stdout.txt
stderr: stderr.txt

outputs:
  output_table:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: "*hmmscan.tbl"

$schemas:
 - https://raw.githubusercontent.com/edamontology/edamontology/main/releases/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
 
s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"

#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "generate all functional stats and orf stats"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 8000  # just a default, could be lowered

inputs:

  interproscan:
    type: File
    inputBinding:
        prefix: -i




baseCommand: [functional_stats.py]

outputs:
  stats:
    type: Directory
    outputBinding:
        glob: "functional-annotation"


hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1


$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://raw.githubusercontent.com/edamontology/edamontology/main/releases/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"


 -clean
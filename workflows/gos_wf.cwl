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
  assemble: { type: boolean, default: false }
  taxon_infer_contigs_level: { type: boolean, default: false }
  funct_annot: { type: boolean, default: false }
  threads: {type: int, default: 2}
  run_qc: 
    type: boolean
    default: true

  # Pre-process
  phred: { type: string, default: '33' }
  leading: { type: int, default: 3 }
  trailing: { type: int, default: 3 }
  end_mode: { type: string, default: PE }
  minlen: { type: int, default: 100 }
  slidingwindow: { type: string, default: '4:15' }


  # RNA prediction input vars
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
  memory: int

  # CGC
  CGC_postfixes: string[]
  cgc_chunk_size: int

  # Functional annotation input vars
  protein_chunk_size_eggnog:  int
  EggNOG_db: [string?, File?]
  EggNOG_diamond_db: [string?, File?]
  EggNOG_data_dir: [string, Directory]

  protein_chunk_size_hmm: int
  func_ann_names_hmmer: string
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  HMM_database_dir: [string, Directory?]
  hmmsearch_header: string

  protein_chunk_size_IPS: int
  func_ann_names_ips: string
  InterProScan_databases: [string, Directory]
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]
  ips_header: string


  antismash_geneclusters_txt: File?
  go_config: [string, File]

  ko_file: [string, File]
  graphs: [string, File]
  pathways_names: [string, File]
  pathways_classes: [string, File]

  gp_flatfiles_path: [string?, Directory?]

  # diamond
  outputFormat:  {type: string, default: '6'}
  strand: {type: string, default: 'both'}
  filename: {type: string, default: 'diamond-subwf-test'}

  diamond_maxTargetSeqs: int
  diamond_databaseFile: [string, File]
  Uniref90_db_txt: [string, File]
  diamond_header: string


steps:

  # QC FOR RNA PREDICTION
  qc-rna-prediction:

    doc: 
      The rna prediction step is based on pre-processed and merged reads. 
      This step aims at the pre-processing and merging the raw reads so its output can be used 
      for the rna prediction step. 

    run: conditionals/raw-reads-1-qc-cond.cwl

    when: $(inputs.run_qc != false)

    in:
      run_qc: run_qc
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length

    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - input_files_hashsum_paired
      - fastp_filtering_json
      - filtered_fasta        # output for next step


  # RNA PREDICTION STEP 
  rna-prediction:

    doc: 
      Returns taxonomic profile of the sample based on the prediction of rna reads
      and their assignment

    run: conditionals/raw-reads-2-rna-only.cwl

    when: $(inputs.run_qc != false)

    in:
      run_qc: run_qc
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

    when: $(inputs.assemble != false)

    in: 

      assemble: assemble
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      phred: phred
      leading: leading
      trailing: trailing
      end_mode: end_mode
      minlen: minlen
      slidingwindow: slidingwindow

    out: 
      - trimmed_fr
      - trimmed_rr
      - trimmed_seqs
      - qc-statistics

  # ASSEMBLY USING MEGAHIT
  assembly:

    run: conditionals/megahit_paired.cwl

    when: $(inputs.assemble != false)

    in: 
      assemble: assemble
      min-contig-len: min-contig-len
      memory: memory
      forward_reads: qc-assembly/trimmed_fr
      reverse_reads: qc-assembly/trimmed_rr

    out: 
      - contigs
      - options

  # COMBINED GENE CALLER
  cgc:

    when: $(inputs.assemble != false && inputs.taxon_infer_contigs_level != false)

    run: subworkflows/assembly/cgc/CGC-subwf.cwl

    in:
      assemble: assemble
      funct_annot: funct_annot
      input_fasta: assembly/contigs
      maskfile: rna-prediction/ncRNA
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size

    out: [ predicted_proteins, predicted_seq, count_faa ] # pred prot -> .faa // pred seq --> .ffn  

  # taxonomic inference based on contigs
  diamond-taxonomic-prediction: 

    run: subworkflows/assembly/diamond/diamond-subwf.cwl 

    when: $(inputs.assemble != false && inputs.diamond != false)

    in: 
      assemble: assemble
      diamond: taxon_infer_contigs_level

      queryInputFile: cgc/predicted_proteins
      outputFormat: outputFormat
      maxTargetSeqs: diamond_maxTargetSeqs
      strand: strand
      databaseFile: EggNOG_diamond_db
      threads: threads
      Uniref90_db_txt: Uniref90_db_txt
      filename: {default: 'diamond-subwf-test'}

    out: [ diamond_output, post-processing_output]



  # functional_annotation: 

  #   when: $(inputs.assembly != false && inputs.funct_annot != false)

  #   run: subworkflows/assembly/Func_ann_and_post_processing-subwf.cwl

  #   in: 
  #     assembly: assembly


  #     filtered_fasta: qc-rna-prediction/filtered_fasta

  #     cgc_results_faa: accessioning_and_prediction/predicted_proteins
  #     rna_prediction_ncRNA: rna_prediction/ncRNA

  #     protein_chunk_size_eggnog: protein_chunk_size_eggnog
  #     EggNOG_db: EggNOG_db
  #     EggNOG_diamond_db: EggNOG_diamond_db
  #     EggNOG_data_dir: EggNOG_data_dir

  #     protein_chunk_size_hmm: protein_chunk_size_hmm
  #     func_ann_names_hmmer: func_ann_names_hmmer
  #     HMM_gathering_bit_score: HMM_gathering_bit_score
  #     HMM_omit_alignment: HMM_omit_alignment
  #     HMM_database: HMM_database
  #     HMM_database_dir: HMM_database_dir
  #     hmmsearch_header: hmmsearch_header

  #     protein_chunk_size_IPS: protein_chunk_size_IPS
  #     func_ann_names_ips: func_ann_names_ips
  #     InterProScan_databases: InterProScan_databases
  #     InterProScan_applications: InterProScan_applications
  #     InterProScan_outputFormat: InterProScan_outputFormat
  #     ips_header: ips_header

  #     diamond_maxTargetSeqs: diamond_maxTargetSeqs
  #     diamond_databaseFile: diamond_databaseFile
  #     Uniref90_db_txt: Uniref90_db_txt
  #     diamond_header: diamond_header

  #     antismash_geneclusters_txt: antismash/antismash_clusters
  #     go_config: go_config

  #     ko_file: ko_file
  #     graphs: graphs
  #     pathways_names: pathways_names
  #     pathways_classes: pathways_classes

  #     gp_flatfiles_path: gp_flatfiles_path

  # out: [ functional_annotation_folder ]




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

  # RNA-prediction step output
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

  # Diamond taxonomic inference
  diamond_output:
    type: File
    outputSource: diamond-taxonomic-prediction/diamond_output
  post-processing_output:
    type: File
    outputSource: diamond-taxonomic-prediction/post-processing_output

  # Functional annotation




$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "European Marine Biological Resource Centre"
s:author: "Haris Zafeiropoulos"


# always to remember: 
# .ffn	> FASTA nucleotide of gene regions	> Contains coding regions for a genome.
# .faa	> FASTA amino acid	> Contains amino acid sequences. A multiple protein fasta file can have the more specific extension mpfa.

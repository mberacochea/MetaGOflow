#!/bin/bash

# default values #
SCRIPT_PATH=$(realpath "$0")
PIPELINE_DIR=$(dirname "${SCRIPT_PATH}")
MEMORY=10G
NUM_CORES=1
LIMIT_QUEUE=100
YML="${PIPELINE_DIR}/Installation/templates/default.yml"
DB_DIR="${PIPELINE_DIR}/ref-dbs/"

_usage() {
  echo "
Run MGnify pipeline.
Script arguments.
  Resources:
  -m                  Memory to use to with toil --defaultMemory. (optional, default ${MEMORY})
  -c                  Number of cpus to use with toil --defaultCores. (optional, default ${NUM_CORES})
  -l                  Limit number of jobs to schedule. (optional, default ${LIMIT_QUEUE})

  Pipeline parameters:
  -y                  template yml file. (optional, default ../templates/rna_prediction_template.yml})
  -f                  Forward reads fasta file path.
  -r                  Reverse reads fasta file path.
  -s                  Single reads fasta file path.
  -q                  Run qc ('true' or 'false').
  -n                  Name of run and prefix to output files.
  -d                  Path to run directory.
  -p                  Path to database directory. (optional, default ../ref-dbs)
"
}

while getopts :y:f:r:s:q:c:d:m:n:l:p:h option; do
  case "${option}" in
  y) YML=${OPTARG} ;;
  f)
    echo "presented paired-end forward path"
    FORWARD_READS=${OPTARG}
    ;;
  r)
    echo "presented paired-end reverse path"
    REVERSE_READS=${OPTARG}
    ;;
  s)
    echo "presented single-end path"
    SINGLE=${OPTARG}
    ;;
  q) QC=${OPTARG} ;;
  c) NUM_CORES=${OPTARG} ;;
  d) RUN_DIR=${OPTARG} ;;
  m) MEMORY=${OPTARG} ;;
  n) NAME=${OPTARG} ;;
  l) LIMIT_QUEUE=${OPTARG} ;;
  p) DB_DIR=${OPTARG} ;;
  h)
    _usage
    exit 0
    ;;
  :)
    usage
    exit 1
    ;;
  \?)
    echo ""
    echo "Invalid option -${OPTARG}" >&2
    usage
    exit 1
    ;;
  esac
done

# ----------------------------- sanity check arguments ----------------------------- #

_check_mandatory() {
  # Check if the argument is empty or null
  # $1 variable
  # $2 name to show
  if [ -z "$1" ]; then
    echo "Error." >&2
    echo "Option ${2} is mandatory " >&2
    echo "type -h to get help"
    exit 1
  fi
}

_check_reads() {
  #check forward and reverse reads both present
  #check if single reads then no other readsgiven
  if [ -z "$3" ]; then
    if [ -z "$1" ] || [ -z "$2" ]; then
      echo "Error"
      echo "Only provide one format: paired or single reads"
      exit 1
    fi
  fi

  if [ -z "$1" ] && [ -n "$2" ]; then
    echo "Error"
    echo "only reverse reads given, provide forward with -f"
    exit 1
  fi

  if [ -n "$1" ] && [ -z "$2" ]; then
    echo "Error"
    echo "only forward reads given, provide reverse with -r"
    exit 1
  fi

}

_check_mandatory "$QC" "-q"
_check_mandatory "$NAME" "-n"
_check_mandatory "$RUN_DIR" "-d"
_check_reads "$FORWARD_READS" "$REVERSE_READS" "$SINGLE"

#get format from input
if [ -n "$SINGLE" ]; then
  TYPE="single"
else
  TYPE="paired"
fi

# ----------------------------- environment & variables ----------------------------- #

# load required environments and packages before running

export TOIL_SLURM_ARGS="--array=1-${LIMIT_QUEUE}%20" #schedule 100 jobs 20 running at one time

export CWL="${PIPELINE_DIR}/workflows/gos_wf.cwl"

# work dir
export WORK_DIR=${RUN_DIR}/work-dir
export JOB_TOIL_FOLDER=${WORK_DIR}/job-store-wf
export TMPDIR=${RUN_DIR}/tmp

# result dir
export OUT_DIR=${RUN_DIR}
export LOG_DIR=${OUT_DIR}/log-dir/${NAME}
export OUT_DIR_FINAL=${OUT_DIR}/results/${NAME}

mkdir -p "${LOG_DIR}" "${OUT_DIR_FINAL}" "${JOB_TOIL_FOLDER}" "${TMPDIR}"

export RENAMED_YML=${RUN_DIR}/"${NAME}".yml

# ----------------------------- prepare yml file ----------------------------- #

echo "Writing yaml file"


echo "${YML}" 
echo "${RENAMED_YML}" 
echo "${TYPE}" 
echo "${SINGLE}"  
echo "${FORWARD_READS}" 
echo "${REVERSE_READS}" 
echo "${DB_DIR}"



python3 create_yml.py \
  -y "${YML}" \
  -o "${RENAMED_YML}" \
  -a "raw-reads" \
  -t "${TYPE}" \
  -s "${SINGLE}" \
  -f "${PIPELINE_DIR}/${FORWARD_READS}" \
  -r "${PIPELINE_DIR}/${REVERSE_READS}" \
  -d "${DB_DIR}"

echo "run_qc: ${QC}" >>"${RENAMED_YML}"

# ----------------------------- running pipeline ----------------------------- #

# IMPORTANT! 
# To work with slurm, add "--batchSystem slurm" and "--disableChaining" in the TOIL_PARMS object
# Remember to have the `--singularity` flag. 
TOIL_PARAMS+=(
  --preserve-entire-environment
  --logFile "${LOG_DIR}/${NAME}.log"
  --jobStore "${JOB_TOIL_FOLDER}/${NAME}"
  --outdir "${OUT_DIR_FINAL}"
  --disableCaching
  --defaultMemory "${MEMORY}"
  --defaultCores "${NUM_CORES}"
  --retryCount 0
  --logDebug
  "$CWL"
  "$RENAMED_YML"
)

# Toir parameters documentation 
# --disableChaining                Disables  chaining  of jobs (chaining uses one job's resource allocation for its successor job if possible).
# --preserve-entire-environment    Need to propagate the env vars for Singularity, etc., into the HPC jobs
# --disableProgress                Disables the progress bar shown when standard error is a terminal.
# --retryCount                     Number of times to retry a failing job before giving up and labeling job failed. default=1
# --disableCaching                 Disables caching in the file store. This flag must be set to use a batch  system that does not support caching such as Grid Engine, Parasol, LSF, or Slurm.



echo "toil-cwl-runner" "${TOIL_PARAMS[@]}"

# toil-cwl-runner --singularity --preserve-entire-environment --logFile RUN_DIRECTORY3//log-dir/TEST/TEST.log 
#  --jobStore RUN_DIRECTORY3//work-dir/job-store-wf/TEST --outdir RUN_DIRECTORY3//results/TEST --disableProgress --disableCaching 
#  --defaultMemory 10G --defaultCores 2 --retryCount 0 --logDebug /home/haris/Documents/coding/github_repos/eosc_life_go/pipeline-v5/workflows/gos_wf.cwl 
# RUN_DIRECTORY3//TEST.yml

toil-cwl-runner "${TOIL_PARAMS[@]}"

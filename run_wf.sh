#!/bin/bash

# ----------------------------- running pipeline ----------------------------- #

TOIL_PARAMS+=(
  --preserve-entire-environment
  --logFile "${LOG_DIR}/${NAME}.log"
  --jobStore "${JOB_TOIL_FOLDER}/${NAME}"
  --outdir "${OUT_DIR_FINAL}"
  --disableChaining
  --disableProgress
  --disableCaching
  --defaultMemory "${MEMORY}"
  --defaultCores "${NUM_CORES}"
  --batchSystem slurm
  --retryCount 0
  "$CWL"
  "$RENAMED_YML"
)

echo "toil-cwl-runner" "${TOIL_PARAMS[@]}"

toil-cwl-runner "${TOIL_PARAMS[@]}"

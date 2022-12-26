#!/bin/bash

n_jobs=1
export NPY_MKL_FORCE_INTEL=1
export MKL_THREADING_LAYER=GNU
snakemake -j $n_jobs

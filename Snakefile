import pandas as pd
import os

tasks = pd.read_table("tasks.tsv")

output_dir = "../../output_2022"

outcome_column = tasks.outcome_column.values

#R_LIBS = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/somatic_was/scripts/somaticWas/renv/library/R-3.6/x86_64-pc-linux-gnu/"
R_LIBS = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/somatic_was/scripts/somaticWas/renv/library/R-4.1/x86_64-pc-linux-gnu/"
slurm_template = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/somatic_was/scripts/somaticWas/batchtools.slurm.tmpl"

n_job_array = 110

rule all:
    input:
        expand(os.path.join(output_dir, "{outcome}", "association_statistics.feather"), outcome = outcome_column)

rule somatic_was:
    output:
        os.path.join(output_dir, "{outcome}", "association_statistics.feather")
    params:
        sample_ped_path = lambda wildcards: tasks[tasks.outcome_column == wildcards.outcome].sample_ped_path.values[0],
        covariates = lambda wildcards: tasks[tasks.outcome_column == wildcards.outcome].covariate_columns.values[0],
        output_prefix = lambda wildcards: tasks[tasks.outcome_column == wildcards.outcome].output_prefix.values[0],
        analysis_type = lambda wildcards: tasks[tasks.outcome_column == wildcards.outcome].analysis_type.values[0],
        region_size = lambda wildcards: tasks[tasks.outcome_column == wildcards.outcome].region_size.values[0]
    log:
        stdout = os.path.join(output_dir, "{outcome}", "stdout.log"),
        stderr = os.path.join(output_dir, "{outcome}", "stderr.log")
    shell:
        """
        export R_LIBS={R_LIBS}
        export MKL_THREADING_LAYER=GNU
        export NPY_MKL_FORCE_INTEL=1
        Rscript runner.R {params.sample_ped_path} {wildcards.outcome} {params.covariates} {params.output_prefix} {n_job_array} {slurm_template} {params.analysis_type} {params.region_size} 1>{log.stdout} 2>{log.stderr}
        """

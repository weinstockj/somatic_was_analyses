devtools::load_all("../../scripts/somaticWas/R")

futile.logger::flog.info("printing R library path")
futile.logger::flog.info(.libPaths())

options = commandArgs(trailingOnly = TRUE)
futile.logger::flog.info("printing command line arguments")
print(options)

sample_ped_path = options[[1]]
outcome_column = options[[2]]
covariate_columns = options[[3]]
output_prefix = options[[4]]
n_workers = as.numeric(options[[5]])
slurm_template = options[[6]]
analysis_type = options[[7]]
region_size = as.numeric(options[[8]])

result = high_level_helper(
    sample_ped_path = sample_ped_path,
    outcome_column = outcome_column,
    covariate_columns = covariate_columns,
    output_prefix = output_prefix,
    n_workers = n_workers,
    slurm_template = slurm_template,
    analysis_type = analysis_type,
    region_size = region_size
)


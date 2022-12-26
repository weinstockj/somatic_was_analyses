
futile.logger::flog.info("printing R library path")
futile.logger::flog.info(.libPaths())

SOMATIC_WAS_DIR = "../somaticWas"

renv::load(SOMATIC_WAS_DIR)
installed.packages()
devtools::load_all(SOMATIC_WAS_DIR)
# library(somaticWas)

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

vaf_path = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/mappability_analysis/output/rnmsm_vaf_mat_2022_07_04.npz"
variant_meta_location = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/mappability_analysis/output/rnmsm_variant_meta_2022_07_04.tsv"
sample_meta_location = "/net/topmed2/working/jweinstk/count_singletons/new_drivers/output/output_sample_statistics_glmnet_2022_07_04.tsv"

result = high_level_helper(
    vaf_path = vaf_path,
    variant_meta_path = variant_meta_location,
    sample_meta_path = sample_meta_location,
    sample_ped_path = sample_ped_path,
    outcome_column = outcome_column,
    covariate_columns = covariate_columns,
    output_prefix = output_prefix,
    n_workers = n_workers,
    slurm_template = slurm_template,
    analysis_type = analysis_type,
    region_size = region_size,
    run_locally = TRUE
)


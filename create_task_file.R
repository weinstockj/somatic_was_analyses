renv::load("../somaticWas")

library("tibble")
library("dplyr")
library("purrr")
library("glue")

create_pcs_vector = function(n) glue::glue("PC{1:n}")
create_spcs_vector = function(n) glue::glue("sPC{1:n}")
create_age_vector = function() c("AgeAtBloodDraw")
create_sex_vector = function() c("INFERRED_SEX")
create_study_vector = function() c("STUDY")
create_sample_qc_vector = function() c("VB_DEPTH", "FREEMIX")
create_driver_vaf_vector = function() c("driver_vaf")
create_covariate_probability_vector = function() c("covariate_probability")
create_demographics_vector = function() c(create_age_vector(), create_sex_vector())
create_pheno_covariate_vector = function(n_pcs = 10, n_spcs = 10) {
    c(
        create_demographics_vector(), 
        create_study_vector(), 
        create_pcs_vector(n_pcs), 
        create_spcs_vector(n_spcs), 
        create_sample_qc_vector()
    )
}

convert_to_string = function(vec) paste(vec, collapse = ",")

blood_predictors = c(
        "hemoglobin_mcnc_bld",
        "hematocrit_vfr_bld",
        "rbc_ncnc_bld",
        "wbc_ncnc_bld",
        "basophil_ncnc_bld",
        "eosinophil_ncnc_bld",
        "neutrophil_ncnc_bld",
        "lymphocyte_ncnc_bld",
        "monocyte_ncnc_bld",
        "platelet_ncnc_bld",
        "mch_entmass_rbc",
        "mchc_mcnc_rbc",
        "mcv_entvol_rbc",
        "pmv_entvol_bld",
        "rdw_ratio_rbc"
)


inflam_predictors = c(
        "cd40",
        "crp",
        "eselectin",
        "icam1",
        "il1_beta",
        "il6",
        "il10",
        "il18",
        "isoprostane_8_epi_pgf2a",
        "lppla2_act",
        "lppla2_mass",
        "mcp1",
        "mmp9",
        "mpo",
        "opg",
        "pselectin",
        "tnfa",
        "tnfa_r1",
        "tnfr2"
)


date = "2022_07_14"
blood_ped = normalizePath(glue::glue("../prepare_ped_files/blood_phenotypes_{date}.ped"))
inflam_ped = normalizePath(glue::glue("../prepare_ped_files/inflam_phenotypes_{date}.ped"))
age_ped = normalizePath(glue::glue("../prepare_ped_files/age_{date}.ped"))
clonal_expansion_ped = normalizePath(glue::glue("../prepare_ped_files/clonal_expansion_{date}.ped"))
chip_ped = normalizePath(glue::glue("../prepare_ped_files/chip_{date}.ped"))
stroke_ped = normalizePath(glue::glue("../prepare_ped_files/stroke_{date}.ped"))

output_dir = normalizePath("../../output_2022")

tasks = tibble::tibble(
        outcome_column = c(
            blood_predictors,
            inflam_predictors,
            "AgeAtBloodDraw",
            "passenger_counts",
            "stroke",
            "haschip"
        ),
        sample_ped_path = c(
            rep(blood_ped, length(blood_predictors)), 
            rep(inflam_ped, length(inflam_predictors)), 
            age_ped, 
            clonal_expansion_ped,
            stroke_ped,
            chip_ped
        ),
        covariate_columns = c(
            rep(convert_to_string(create_pheno_covariate_vector()), length(blood_predictors)),
            rep(convert_to_string(create_pheno_covariate_vector()), length(inflam_predictors)),
            convert_to_string(create_study_vector()),
            convert_to_string(c(create_pheno_covariate_vector(), create_driver_vaf_vector())),
            convert_to_string(setdiff(c(create_pheno_covariate_vector(), create_covariate_probability_vector()), c(create_study_vector(), create_age_vector(), create_sex_vector()))), # stroke
            convert_to_string(setdiff(c(create_pheno_covariate_vector(), create_covariate_probability_vector()), c(create_study_vector(), create_age_vector(), create_sex_vector()))) # CHIP
        ),
        region_size = c(
            rep(1e7, length(blood_predictors) + length(inflam_predictors) + 1 + 1),
            7e6, #stroke
            7e6
        ),
        analysis_type = c(
            rep("quantitative", length(blood_predictors) + length(inflam_predictors) + 1 + 1),
            "binary", #stroke
            "binary"
        )
    ) %>%
    dplyr::mutate(
        output_prefix = file.path(output_dir, outcome_column),
        target_file = file.path(output_prefix, "association_statistics.feather")
    )

readr::write_tsv(tasks, "tasks.tsv")

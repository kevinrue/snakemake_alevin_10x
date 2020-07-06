# An example collection of Snakemake rules imported in the main Snakefile.

rule renv:
    output:
        "renv/activate.R"
    conda:
        "../envs/r.yaml"
    script:
        "../scripts/renv.R"

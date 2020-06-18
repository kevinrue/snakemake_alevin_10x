import glob


rule alevin:
    input:
        unpack(get_gex_fastq)
    output:
        "results/alevin/{sample}/alevin/quants_mat.gz"
    params:
        output_folder=lambda wildcards, output: output[0].replace("alevin/quants_mat.gz", ""),
        index=config['alevin']['sa_index'],
        tgmap=config['alevin']['tgmap'],
        cells_option=get_cells_option,
        threads=config['alevin']['threads']
    conda:
        "../envs/alevin.yaml"
    threads: config['alevin']['threads']
    resources:
        mem_free_gb=f"{config['alevin']['memory_per_cpu']}"
    log: stderr="results/logs/alevin/{sample}.log"
    shell:
        """
        salmon alevin -l ISR -i {params.index} \
        -1 {input.fastq1} -2 {input.fastq2} \
        -o {params.output_folder} -p {params.threads} --tgMap {params.tgmap} \
        --chromium --dumpFeatures \
        {params.cells_option} \
        2> {log.stderr}
        """


rule barcode_rank:
    input:
        quants="results/alevin/{sample}/alevin/quants_mat.gz"
    output:
        report("results/plots/{sample}/barcode_rank.svg", caption="../report/barcode_rank.rst", category="Barcode rank plot")
    conda:
        "../envs/bioc_3_11.yaml"
    log: script="results/logs/barcode_rank/{sample}.log"
    script:
        "../scripts/barcode_rank.R"

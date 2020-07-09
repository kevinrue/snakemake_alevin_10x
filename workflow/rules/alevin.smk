import glob


rule alevin:
    input:
        unpack(get_gex_fastq),
        index="resources/salmon_index",
        tgmap="resources/txp2gene.tsv"
    output:
        "results/alevin/{sample}/alevin/quants_mat.gz"
    params:
        cells_option=get_cells_option,
        threads=config['alevin']['threads']
    conda:
        "../envs/salmon.yaml"
    threads: config['alevin']['threads']
    resources:
        mem_free_gb=f"{config['alevin']['memory_per_cpu']}"
    log: stderr="results/logs/alevin/{sample}.log"
    shell:
        """
        rm -rf results/alevin/{wildcards.sample} &&
        salmon alevin -l ISR -i {input.index} \
        -1 {input.fastq1} -2 {input.fastq2} \
        -o results/alevin/{wildcards.sample} -p {params.threads} --tgMap {input.tgmap} \
        --chromium --dumpFeatures \
        {params.cells_option} \
        2> {log.stderr}
        """


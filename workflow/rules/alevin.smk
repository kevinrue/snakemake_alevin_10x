import glob

def get_gex_fastq(wildcards):
    '''
    wildcards
    - sample: name of the sample to process.
    '''
    fastq1 = glob.glob(f"data/{wildcards.sample}_fastqs/{wildcards.sample}_*_R1_001.fastq.gz")
    fastq2 = [file.replace("_R1_001.fastq.gz", "_R2_001.fastq.gz") for file in fastq1]
    return {'fastq1' : fastq1, 'fastq2' : fastq2 }


def get_cells_option(wildcards):
    '''
    wildcards
    - sample: name of the sample to process.
    '''
    expect_cells = samples['expect_cells'][wildcards.sample]
    option_str = f"--expectCells {expect_cells}"
    return option_str


rule alevin_rna:
    input:
        unpack(get_gex_fastq)
    output:
        "results/alevin/{sample}/rna/alevin/quants_mat.gz"
    params:
        output_folder=lambda wildcards, output: output[0].replace("/alevin/quants_mat.gz", ""),
        index=config['alevin']['sa_index'],
        tgmap=config['alevin']['tgmap'],
        cells_option=get_cells_option,
        threads=config['alevin']['threads']
    threads: config['alevin']['threads']
    resources:
        mem_free=config['alevin']['memory_per_cpu']
    log: stderr="logs/alevin/{sample}/rna.log"
    shell:
        """
        salmon alevin -l ISR -i {params.index} \
        -1 {input.fastq1} -2 {input.fastq2} \
        -o {params.output_folder} -p {params.threads} --tgMap {params.tgmap} \
        --chromium --dumpFeatures \
        {params.cells_option} \
        2> {log.stderr}
        """

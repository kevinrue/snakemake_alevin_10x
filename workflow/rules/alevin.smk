import glob


def get_gex_fastq(wildcards):
    '''
    wildcards
    - sample: name of the sample to process.
    '''
    fastq1_pattern = f"data/{wildcards.sample}_fastqs/*_R1_001.fastq.gz"
    fastq1 = glob.glob(fastq1_pattern)
    
    if len(fastq1) == 0:
        raise OSError(f"No file matched pattern: {fastq1_pattern}")
    
    fastq2 = [file.replace("_R1_001.fastq.gz", "_R2_001.fastq.gz") for file in fastq1]
    for file in fastq2:
        if not os.path.exists(file):
            raise OSError(f"Paired file not found: {file}")
    
    return {'fastq1' : fastq1, 'fastq2' : fastq2 }


def get_cells_option(wildcards):
    '''
    wildcards
    - sample: name of the sample to process.
    
    Note that users should supply only one of 'expect_cells' or 'force_cells'.
    The other one should be set to 0, to be ignored.
    '''
    option_str = ""
    
    expect_cells = samples['expect_cells'][wildcards.sample]
    force_cells = samples['force_cells'][wildcards.sample]

    if expect_cells > 0:
        option_str += f" --expectCells {expect_cells}"
    
    if force_cells > 0:
        option_str += f" --forceCells {force_cells}"
    
    return option_str


rule alevin:
    input:
        unpack(get_gex_fastq)
    output:
        "results/{sample}/salmon/alevin/quants_mat.gz"
    params:
        output_folder=lambda wildcards, output: output[0].replace("/alevin/quants_mat.gz", ""),
        index=config['alevin']['sa_index'],
        tgmap=config['alevin']['tgmap'],
        cells_option=get_cells_option,
        threads=config['alevin']['threads']
#     conda:
#         "../envs/alevin.yaml" # until next release, use binary on PATH
    threads: config['alevin']['threads']
    resources:
        mem_free=f"{config['alevin']['memory_per_cpu']}"
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


rule barcode_rank:
    input:
        quants="results/{sample}/salmon/alevin/quants_mat.gz"
    output:
        report("results/{sample}/figures/barcode_rank.svg", caption="../report/barcode_rank.rst", category="Barcode rank plot")
    conda:
        "../envs/bioc_3_11.yaml"
    script:
        "../scripts/barcode_rank.R"

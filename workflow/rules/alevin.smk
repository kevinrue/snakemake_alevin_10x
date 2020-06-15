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
        "results/{sample}/alevin/quants_mat.gz"
    params:
        output_folder=lambda wildcards, output: output[0].replace("/alevin/quants_mat.gz", ""),
        index=config['alevin']['sa_index'],
        tgmap=config['alevin']['tgmap'],
        cells_option=get_cells_option,
        threads=config['alevin']['threads']
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
        quants="results/{sample}/alevin/quants_mat.gz"
    output:
        report("results/{sample}/barcode_rank.svg", caption="report/barcode_rank.{sample}.rst", category="Barcode-rank")
    conda:
        "envs/bioc_3_11.yaml"
    log:
        # optional path to the processed notebook
        notebook="logs/notebooks/barcode_rank.{sample}.ipynb"
    notebook:
        "barcode_rank.r.ipynb"

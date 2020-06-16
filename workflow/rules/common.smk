from snakemake.utils import validate
import pandas as pd

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
samples.index.names = ["sample_id"]
validate(samples, schema="../schemas/samples.schema.yaml")

##### helper functions #####

def get_gex_fastq(wildcards):
    '''
    Identify pairs of FASTQ files from the sample sheet.
    
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
    Build an string of command line options from the sample sheet.
    
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
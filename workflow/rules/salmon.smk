from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()

rule download_genome:
    input:
        FTP.remote(config['salmon']['genome'])
    output:
        "resources/genome.fa.gz"
    run:
        shell("mv {input} {output}")


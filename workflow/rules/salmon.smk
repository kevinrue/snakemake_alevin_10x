from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()


rule genome:
    input:
        FTP.remote(config['salmon']['genome'])
    output:
        'resources/genome.fa.gz'
    run:
        shell('mv {input} {output}')


rule transcriptome:
    input:
        FTP.remote(config['salmon']['transcriptome'])
    output:
        'resources/transcriptome.fa.gz'
    run:
        shell('mv {input} {output}')


rule decoys:
    input:
        'resources/genome.fa.gz'
    output:
        'resources/decoys.txt'
    shell:
        '''
        grep "^>" <(gunzip -c {input}) |
        cut -d " " -f 1 |
        sed -e 's/>//g' > {output}
        '''


rule concatenate_genome_transcriptome:
    input:
        genome='resources/genome.fa.gz',
        transcriptome='resources/transcriptome.fa.gz'
    output:
        'resources/gentrome.fa.gz'
    shell:
        '''
        cat {input.transcriptome} {input.genome} > {output}
        '''
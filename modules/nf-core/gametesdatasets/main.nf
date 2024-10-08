process GAMETESDATASETS {
    tag "$meta.id"
    label 'process_single'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0':
        'biocontainers/gametes:2.1--py310h7cba7a3_0' }"
    input:

    tuple val(meta), path(input_file)
    //path input_file

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("${prefix}_EDM-*"), emit: scores
    path "versions.yml"           , emit: versions

    //path "${prefix}_EDM-*"

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # crea prefix

    prefix=\$(echo ${input_file} | awk -F'_Models.txt' '{print \$1}')

    gametes -i ${input_file} -D "-n ${params.alleleFrequencyMin} -x ${params.alleleFrequencyMax} -a ${params.totalAttributeCount} -s ${params.caseCount} -w ${params.controlCount} -r ${params.replicateCount} -o \${prefix}"

    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametesdatasets: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametesdatasets: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}

process GAMETESDATASETS {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gametes:2.1--py310h7cba7a3_0' :
        'biocontainers/gametes:2.1--py310h7cba7a3_0'}"

    input:
    tuple val(meta), path(model)

    output:
    tuple val(meta), path("${prefix}_EDM-*"), emit: edmresults
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '2.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    prefix=\$(echo ${model} | awk -F'_Models.txt' '{print \$1}')

    gametes -i ${model} -D "-n ${params.alleleFrequencyMin} -x ${params.alleleFrequencyMax} -a ${params.totalAttributeCount} -s ${params.caseCount} -w ${params.controlCount} -r ${params.replicateCount} -o \${prefix}"
    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gametes: $VERSION
    END_VERSIONS
}

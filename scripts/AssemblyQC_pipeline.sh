#!/bin/bash
# ------------------------------------------------------------------
# Author:       A.Sendell-Price
# Date:         April 2023
# Title:        pathsafeQC_pipeline.sh
# Description:  Performs genome assembly from Salmonella reads
#               using different assemblers and compares results
#               with quast.
# Dependencies: Requires singularity containers "pathsafeQC_"

# ------------------------------------------------------------------

# -- USER DEFINED PARAMS --------
# Set path to directory containing read files, nextflow executable, pathogenwatch directory, 
# and the two singularity container sandboxes "pathsafeQC_container1" and "pathsafeQC_container2"
NEXTFLOW="/home/u2271009/pathsafe_QC/nextflow"
PATHOGENWATCH_DIR="/home/u2271009/pathsafe_QC/pathogenwatch_assembly"
SINGULARITY_CONTAINER1="/home/u2271009/pathsafe_QC/pathsafeQC_container1"
SINGULARITY_CONTAINER2="/home/u2271009/pathsafe_QC/pathsafeQC_container2"
SCRIPT_DIR="/home/u2271009/pathsafe_QC/scripts"
DIR_PATH="/home/u2271009/mnt/Shared259/bioinformaticsRTP/EnteroBase/Assembly_QC/refReads/readFiles1"
# ------------------------------

# Get current working directory
WORKING_DIRECTORY=$(pwd)

for ROW in $(seq 1 2)
do
    ACCESSION=$(head -n $ROW accessions.txt | tail -n 1)

    # Set read pair paths
    FORWARD_READS=${DIR_PATH}/${ACCESSION}_1.fastq.gz
    REVERSE_READS=${DIR_PATH}/${ACCESSION}_2.fastq.gz

    # Create directories
    mkdir ${ACCESSION}
    mkdir ${ACCESSION}/input_files
    mkdir ${ACCESSION}/assembly_fastas
    mkdir ${ACCESSION}/temp

    # Move into the acession directory
    cd ${ACCESSION}/temp

    # Create symbolic links to input files
    ln -s $FORWARD_READS ../input_files/raw_forward.fastq.gz
    ln -s $REVERSE_READS ../input_files/raw_reverse.fastq.gz

    # Assemble genome using assembler set 1 scipt:
    # - EToKi Spades (filtered reads)
    # - EToKi Megahit (filtered reads)
    # - EToKi Spades (unfiltered reads)
    # - EToKi Megahit (unfiltered reads)
    # - Spades
    # - Megahit
    # - Unicylcer
    # - idba
    # - abyss
    # - velvet
    singularity exec $SINGULARITY_CONTAINER1 /bin/sh ${SCRIPT_DIR}/pathsafeQC_assembler_set1.sh

    # Assemble genome using assembler set 2 scipt:
    # - skesa
    # - masurca
    singularity exec $SINGULARITY_CONTAINER2 /bin/sh ${SCRIPT_DIR}/pathsafeQC_assembler_set2.sh

    # Build assembly using the pathogen watch assembler via docker image
    $NEXTFLOW run ${PATHOGENWATCH_DIR}/assembly.nf \
    --input_dir ../input_files --output_dir pathogenwatch_assembler \
    --fastq_pattern "raw_{forward,reverse}.fastq.gz" \
    --adapter_file ${PATHOGENWATCH_DIR}/adapters.fas \
    -with-docker bioinformant/ghru-assembly:latest
    mv pathogenwatch_assembler/assemblies/raw.fasta ../assembly_fastas/pathogenwatch.fasta
  
    # Compare assemblies via QUAST
    cd ${WORKING_DIRECTORY}/${ACCESSION}
    singularity exec $SINGULARITY_CONTAINER1 /bin/sh ${SCRIPT_DIR}/pathsafeQC_assembler_quast.sh

    #Remove temp directory
    rm -r temp

    #Move back to original working directory
    cd $WORKING_DIRECTORY

done

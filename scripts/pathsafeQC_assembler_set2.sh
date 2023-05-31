#!/bin/bash
# ------------------------------------------------------------------
# Author:       A.Sendell-Price
# Date:         April 2023
# Title:        pathsafeQC_assembler_set2.sh
# Description:  Performs genome assembly from Salmonella reads
#               using the following assemblers:
#                   - skesa
#                   - masurca (filtered reads)
#                   - abyss
# Dependencies: Requires singularity container "pathsafeQC_container2"
# ------------------------------------------------------------------

#Fixing locale failed in Debian and Ubuntu error
export LC_ALL=C

#Get working directory
WORKING_DIR=$(pwd)

# Build assembly using SKESA
/bin/SKESA/skesa --reads ../input_files/raw_forward.fastq.gz,../input_files/raw_reverse.fastq.gz > ../assembly_fastas/skesa.fasta

# Build assembly using MaSuRCA 
mkdir masurca
cd masurca
masurca -i ../EToKi_prepare_L1_R1.fastq.gz,../EToKi_prepare_L1_R2.fastq.gz
mv CA/primary.genome.scf.fasta ../../assembly_fastas/masurca.fasta
cd $WORKING_DIR


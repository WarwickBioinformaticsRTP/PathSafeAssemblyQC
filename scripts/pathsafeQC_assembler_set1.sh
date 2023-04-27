#!/bin/bash
# ------------------------------------------------------------------
# Author:       A.Sendell-Price
# Date:         April 2023
# Title:        pathsafeQC_assembler_set1.sh
# Description:  Performs genome assembly from Salmonella reads
#               using the following assemblers:
#                   - EToKi Spades (filtered reads)
#                   - Spades
#                   - Megahit
#                   - Unicylcer
#                   - idba
#                   - velvet
# Dependencies: Requires singularity container "pathsafeQC_container1"
# ------------------------------------------------------------------

#Fixing locale failed in Debian and Ubuntu error
export LC_ALL=C

#Get working directory
WORKING_DIR=$(pwd)

# Filter reads (via EToKi)
# This replicates what is happening in crobot, note EToKi prepare has
# default quality and coverage filters
EToKi.py prepare --pe ../input_files/raw_forward.fastq.gz,../input_files/raw_reverse.fastq.gz -b 600000000

# Build assembly using SPADES (via EToKi)
if [ -f EToKi_prepare_L1_SE.fastq.gz ]
then
        EToKi.py assemble --pe EToKi_prepare_L1_R1.fastq.gz,EToKi_prepare_L1_R2.fastq.gz --se EToKi_prepare_L1_SE.fastq.gz -k 15,30,50,70,90 -p EToKi_spades
else
        EToKi.py assemble --pe EToKi_prepare_L1_R1.fastq.gz,EToKi_prepare_L1_R2.fastq.gz -k 15,30,50,70,90 -p EToKi_spades
fi
mv EToKi_spades.result.fasta ../assembly_fastas/EToKi_spades.fasta

# Build assembly using SPADES (vanilla version i.e straight out of the box)
spades.py -1 ../input_files/raw_forward.fastq.gz -2 ../input_files/raw_reverse.fastq.gz -o spades_vanilla
mv spades_vanilla/scaffolds.fasta ../assembly_fastas/spades.fasta
#AttributeError: module 'collections' has no attribute 'Hashable'

# Build assembly using megahit (vanilla version i.e straight out of the box)
megahit -1 ../input_files/raw_forward.fastq.gz -2 ../input_files/raw_reverse.fastq.gz -o megahit_vanilla
mv megahit_vanilla/final.contigs.fa ../assembly_fastas/megahit.fasta

# Build assembly using UNICYCLER
unicycler-runner.py -1 ../input_files/raw_forward.fastq.gz -2 ../input_files/raw_reverse.fastq.gz -o unicycler
mv unicycler/assembly.fasta ../assembly_fastas/unicycler.fasta

# Build assembly using idba
zcat ../input_files/raw_forward.fastq.gz > temp1.fq
zcat ../input_files/raw_reverse.fastq.gz > temp2.fq
fq2fa --merge temp1.fq temp2.fq idba_input.fa
rm temp1.fq temp2.fq
idba -r idba_input.fa -o idba --num_threads 4
mv idba/scaffold.fa ../assembly_fastas/idba.fasta
rm idba_input.fa

# Build assembly using vevlet (via velvet optimiser)
mkdir velvet
cd velvet
VelvetOptimiser.pl -s 53 -e 75 -f '-shortPaired -fastq ../../input_files/raw_forward.fastq.gz -shortPaired2 ../../input_files/raw_reverse.fastq.gz'
mv auto_data_*/contigs.fa ../../assembly_fastas/velvet.fasta
cd $WORKING_DIR

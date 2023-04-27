#!/bin/bash
# ------------------------------------------------------------------
# Author:       A.Sendell-Price
# Date:         April 2023
# Title:        pathsafeQC_assembler_quast.sh
# Description:  Writes quast report comparing assemblies
# Dependencies: Requires singularity container "pathsafeQC_container1"
# ------------------------------------------------------------------

#Fixing locale failed in Debian and Ubuntu error
export LC_ALL=C

#Get working directory
WORKING_DIR=$(pwd)

# Run quast
quast.py $(ls assembly_fastas/*.fasta)

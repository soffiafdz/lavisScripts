#!/bin/bash

#load module 
module load fsl/5.0.11

homeDir=/mnt/MD1200B/egarza/sfernandezl
inDir=${homedir}/AddimexConn/derivatives/CPAC
outDir=${homedir}/AddimexConn/derivatives/stimZanalysis
seedsDir=${homedir}/foxFiles/cones

for cone in $(ls $seedsDir); do
    stimZid=$(basename $cone _CONE_msk2_normed.nii.gz)
    stimZids+=( $stimZid );
done

for outCPAC in $(ls $inDir); do
    OUT=${outDir}/${outCPAC}/meanSeries
    mkdir -p $OUT
    for r_z in r z; do
        for stimZid in ${stimZids[@]}; do
            fslmerge -t ${OUT}/seed_${stimZid}_${r_z}} \
                ${outDir}/correlationMaps/${r_z}/sub*${stimZid}*;
            fslmaths ${OUT}/seed_${stimZid}_${r_z}} \
                -Tmean ${OUT}/avg_seed_${stimZid}_${r_z} \
                -odt input
        done
    done
done
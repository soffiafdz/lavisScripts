#!/bin/bash

#load module 
module load fsl/5.0.11

inDir=/mnt/MD1200B/egarza/sfernandezl/AddimexConn/derivatives/CPAC
outDir=/mnt/MD1200B/egarza/sfernandezl/AddimexConn/derivatives/stimZanalysis


for cone in $(ls [cones indeces]); do
    stimZ=$(basename $cone)
    stimZid=[] #Should this be needed?
    stimZids+=( $stimZid );
done

for outCPAC in $(ls $inDir); do
    OUT=${outDir}/${outCPAC}/meanSeries
    mkdir -p $OUT
    for r_z in r z; do
        for stimZid in ${stimZids[@]}; do
            fslmerge -t ${OUT}/${stimZid}_${r_z}} \
                ${outDir}/correlationMaps/${r_z}/sub*${stimZid}*;
            fslmaths ${OUT}/${stimZid}_${r_z}} \
                -Tmean ${OUT}/avg_${stimZid}_${r_z} \
                -odt input
        done
    done
done
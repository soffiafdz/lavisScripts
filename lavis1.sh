#!/bin/bash
# Use current working directory
#$ -cwd
#
# Join stdout and stderr
#$ -j y
#
# Run job through bash shell
#$ -S /bin/bash
#
#You can edit the scriptsince this line
#
# Your job name
#$ -N ANTs_norm_seeds
#
# Send an email after the job has finished
#$ -m bae
#$ -M so1.618e@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load ants/6dic2017
#
# Write your commands in the next line
home=$(pwd)
dir=/mnt/MD1200B/egarza/sfernandezl
std=${dir}/fsl_std/MNI152_T1_2mm.nii.gz
stdMsk=${dir}/fsl_std/MNI152_T1_2mm_brain_mask.nii.gz
workdir=${dir}/addimexTMS20190402/stimZanalysis20190328
csv=${workdir}/coordsMatlabANTS.csv

# Functions

point() { #t1 #name
    # Create point in specific location in native map
    fslmaths $1 -mul 0 -add 1 -roi ${coords} $2 -odt float;
    fslmaths $2 -bin $2
}

normalization() { #inFile #outFile
    ANTS 3 -m CC[$std,$1,1,4] -i 50x20x10 -o $2 -t SyN[0.1,3,0]
}

warpAnts() { #inFile #outFile #Warp/Affine 
    WarpImageMultiTransform 3 $1 ${2}.nii.gz -R $std ${3}_Warp.nii.gz ${3}_Affine.txt

}

sphere() { #inFile #outFile
    # Create sphere
    fslmaths $1 -kernel sphere 2 -fmean -thr 0.001 -bin $2 -odt float;
}

cone() { #inFile #outFile
## Create cone shaped ROI for TMS FC

    # Create spheres for each size.
    fslmaths $1 -kernel sphere 2 -fmean -bin pre_sphere2mm -odt float;
    fslmaths $1 -kernel sphere 4 -fmean -bin pre_sphere4mm -odt float;
    fslmaths $1 -kernel sphere 7 -fmean -bin pre_sphere7mm -odt float;
    fslmaths $1 -kernel sphere 9 -fmean -bin pre_sphere9mm -odt float;
    fslmaths $1 -kernel sphere 12 -fmean -thr 0.001 -bin pre_sphere12mm -odt float;

    # Cut each sphere so they fit one inside the other.
    fslmaths pre_sphere12mm -sub pre_sphere9mm pre_sphere12mm -odt float;
    fslmaths pre_sphere9mm -sub pre_sphere7mm pre_sphere9mm -odt float;
    fslmaths pre_sphere7mm -sub pre_sphere4mm pre_sphere7mm -odt float;
    fslmaths pre_sphere4mm -sub pre_sphere2mm pre_sphere4mm -odt float;

    # Give intensities to each sphere.
    fslmaths pre_sphere2mm -mul 5 pre_sphere2mm -odt float;
    fslmaths pre_sphere4mm -mul 4 pre_sphere4mm -odt float;
    fslmaths pre_sphere7mm -mul 3 pre_sphere7mm -odt float;
    fslmaths pre_sphere9mm -mul 2 pre_sphere9mm -odt float;
    fslmaths pre_sphere12mm -mul 1 pre_sphere12mm -odt float;

    # Cut outside cortex.
    fslmaths pre_sphere2mm -mul $stdMsk pre_sphere2mm -odt float;
    fslmaths pre_sphere4mm -mul $stdMsk pre_sphere4mm -odt float;
    fslmaths pre_sphere7mm -mul $stdMsk pre_sphere7mm -odt float;
    fslmaths pre_sphere9mm -mul $stdMsk pre_sphere9mm -odt float;
    fslmaths pre_sphere12mm -mul $stdMsk pre_sphere12mm -odt float;

    # Combine masks.
    fslmaths pre_sphere2mm -add pre_sphere4mm -add pre_sphere7mm -add pre_sphere9mm -add pre_sphere12mm $2 -odt float;

    # Normalize intensity to 1
    fslmaths $2 -inm 1 ${2}Norm -odt float
  
    # Remove preliminary files
    rm pre* 
}




#Body

while IFS="," read rid x y z ; do
    coords="$x 1 $y 1 $z 1 0 1"
    t1w=${workdir}/lin_correg/${rid}/vit/structural_head.nii.gz
    echo "#####"$rid"######"
    echo "##### Normalizing t1w #####"
    mkdir -p ${workdir}/mni_norm/${rid}
    cd ${workdir}/mni_norm/${rid}
    normalization $t1w ${rid}_2_mni
    cd $home

    #echo "##### Making stim-point mask in native space #####"   
    #mkdir -p ${workdir}/nativeStimPnt
    #cd ${workdir}/nativeStimPnt
    #point $t1w ${rid}nativePnt
    #cd $home

    #echo "##### Warping stim-point #####"
    #mkdir -p ${workdir}/mniStimSite
    #cd ${workdir}/mniStimSite
    #warpAnts ${workdir}/nativeStimPnt/${rid}nativePnt ${rid}mniPnt ${workdir}/mni_norm/${rid}/${rid}_2_mni
    #cd $home

    #echo "##### Making stim-point spheres #####"
    #mkdir -p ${workdir}/coneSeedsMNI
    #cd ${workdir}/coneSeedsMNI
    #sphere ${workdir}/mniStimSite/${rid}mniPnt ${rid}mniSphere
    #cone ${workdir}/mniStimSite/${rid}mniPnt ${rid}mniCone
    #cd $home
done < $csv


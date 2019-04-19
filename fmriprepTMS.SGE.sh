#! /bin/bash
## SGE batch file - fmriprepTMS
#$ -S /bin/bash
## cpacFAB is the jobname and can be changed
#$ -N fmriprepTMS
## execute the job using the mpi_smp parallel enviroment and 8 cores per job
## create an array of 2 jobs the number of subjects and sessions
#$ -t 1-31
#$ -V
#$ -l mem_free=18G
#$ -pe openmp 12
## change the following working directory to a persistent directory that is
## available on all nodes, this is were messages printed by the app (stdout
## and stderr) will be stored
#$ -wd /mnt/MD1200B/egarza/sfernandezl/TMS/derivatives/fmriprep

module load singularity/2.2

## sudo chmod 777 /mnt
mkdir -p /mnt/MD1200B/egarza/sfernandezl/TMS/derivatives/fmriprep/output
export FS_LICENSE=/mnt/MD1200B/egarza/sfernandezl/freesurferLicense/license.txt
container=/mnt/MD1200B/egarza/sfernandezl/singImages/poldracklab_fmriprep-2019-03-18-63091b7e6499.img
subList=/mnt/MD1200B/egarza/sfernandezl/TMS/participants.tsv
sge_ndx=$(awk -v F='\t' -v OFS='\t' -v subIndx=$(($SGE_TASK_ID + 1)) 'NR==subIndx {print $1}' $subList)

# random sleep so that jobs dont start at _exactly_ the same time
sleep $(( $SGE_TASK_ID % 10 ))

singularity run -B /mnt:/mnt \
    $container \
    /mnt/MD1200B/egarza/sfernandezl/TMS \
    /mnt/MD1200B/egarza/sfernandezl/TMS/derivatives/fmriprep/output \
    participant \
    --participant-label ${sge_ndx} \
    --longitudinal \
    --nthreads 12 --omp-nthreads 12 \
    --mem-mb 18 \
    --resource-monitor \
    --write-graph \
    --work-dir /mnt/MD1200B/egarza/sfernandezl/TMS/derivatives/fmriprep \
    --output-space template \
    --template-resampling-grid 2mm \
    --use-syn-sdc;

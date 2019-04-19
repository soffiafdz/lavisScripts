#! /bin/bash
## SGE batch file - fmriprepAddimexConn
#$ -S /bin/bash
## cpacFAB is the jobname and can be changed
#$ -N fmriprep_addimexConn
## execute the job using the mpi_smp parallel enviroment and 8 cores per job
#! /bin/bash
## SGE batch file - fmriprepAddimexConn
#$ -S /bin/bash
## cpacFAB is the jobname and can be changed
#$ -N fmriprep_addimexConn
## execute the job using the mpi_smp parallel enviroment and 8 cores per job
## create an array of 2 jobs the number of subjects and sessions
#$ -t 1-2 #CHANGE NUMBERS OF SUBS
#$ -V
#$ -l mem_free=16G
#$ -pe openmp 8
## change the following working directory to a persistent directory that is
## available on all nodes, this is were messages printed by the app (stdout
## and stderr) will be stored
#$ -wd /mnt/MD1200B/egarza/sfernandezl/addimexConn/derivatives/fmriprep

module load singularity/2.2

## sudo chmod 777 /mnt
mkdir -p /mnt/MD1200B/egarza/sfernandezl/addimexConn/derivatives/fmriprep/output
export FS_LICENSE=/mnt/MD1200B/egarza/sfernandezl/freesurferLicense/license.txt
container=/mnt/MD1200B/egarza/sfernandezl/singImages/poldracklab_fmriprep-2019-03-18-63091b7e6499.img
subList=/mnt/MD1200B/egarza/sfernandezl/addimexConn/sourcedata/validSubs.txt
sge_ndx=$(awk "NR==$SGE_TASK_ID" $subList)

# random sleep so that jobs dont start at _exactly_ the same time
sleep $(( $SGE_TASK_ID % 10 ))

singularity run -B /mnt:/mnt \
    $container \
    /mnt/MD1200B/egarza/sfernandezl/addimexConn \
    /mnt/MD1200B/egarza/sfernandezl/addimexConn/derivatives/fmriprep/output \
    participant \
    --participant-label ${sge_ndx} \
    --longitudinal \
    --nthreads 8 --omp-nthreads 8 \
    --mem-mb 16 \
    --low-mem \
    --resource-monitor \
    --write-graph \
    --work-dir /mnt/MD1200B/egarza/sfernandezl/addimexConn/derivatives/fmriprep \
    --output-space template \
    --template-resampling-grid 2mm \
    --use-syn-sdc;

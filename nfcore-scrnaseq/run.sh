module load nextflow singularity
cd /mnt/data/BioShell-Demos/nfcore-scrnaseq

nextflow run /mnt/data/scrnaseq \
  -profile singularity \
  -c bioshell.config \
  --outdir results \
  -resume

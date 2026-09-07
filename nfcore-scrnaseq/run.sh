module load nextflow singularity
cd /mnt/data

nextflow run scrnaseq \
  --input samplesheet.csv \
  --outdir gse174609_run \
  --aligner star \
  --protocol 10XV3 \
  --fasta reference_chr19/Homo_sapiens.GRCh38.dna.chromosome.19.fa \
  --gtf reference_chr19/Homo_sapiens.GRCh38.114.chr19.gtf \
  -params-file skip_params.json \
  -profile singularity \
  -c bioshell.config \
  -resume

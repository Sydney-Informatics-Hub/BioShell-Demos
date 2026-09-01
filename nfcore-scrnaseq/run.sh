
nextflow run nf-core/scrnaseq \
  --input /mnt/data/samplesheet.csv \
  --outdir gse174609_run \
  --protocol 10XV3 \
  --genome GRCh38 \
  -profile singularity

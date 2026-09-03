module load nextflow singularity

nextflow run /mnt/data/scrnaseq \
  --input /mnt/data/samplesheet.csv \
  --outdir gse174609_run \
  --aligner star \
  --protocol 10XV3 \
  --fasta /mnt/data/reference_chr19/Homo_sapiens.GRCh38.dna.chromosome.19.fa \
  --gtf /mnt/data/reference_chr19/Homo_sapiens.GRCh38.114.chr19.gtf \
  -profile singularity \
  -c bioshell.config \
  -resume

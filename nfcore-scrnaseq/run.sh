#!/bin/bash

nextflow run scrnaseq \
  --input samplesheet.csv \
  --outdir results \
  --aligner star \
  --protocol 10XV2 \
  --fasta data/GRCm38.p6.genome.chr19.fa \
  --gtf data/gencode.vM19.annotation.chr19.gtf \
  -params-file params.yaml \
  -profile singularity \
  -resume

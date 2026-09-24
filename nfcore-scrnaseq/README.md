# nfcore-scrnaseq

## Prep

Download data and references to /mnt/data/fastq and /mnt/data/refs

## Overview

In this video I will be stepping through how to configure and run Nextflow on the BioShell.

As an example, I will run nf-core/scrnaseq on their minimal test data.

## How to pull a Nextflow pipeline

First I will prepare my BioShell by changing directories into my provisioned data volume. We recommend storing your data, and working in the volume, as bioinformatics pipelines often generate and use large data which will exceed the storage on the X.

```bash
cd /mnt/data/
```

Next, I will load the nextflow and singularity modules. 

Nextflow will be used to run the pipeline, and singularity to execute the individual tool versions within them.

```bash
module load nextflow singularity
```

Probe the CVMFS to ensure Nextflow can access the singularity images.

```bash
cvmfs_config probe
```

Next, I will pull the code for nf-core/scrnaseq pipeline using `nextflow pull`.

```bash
nextflow pull nfcore/scrnaseq
```

If you are new to nf-core or nextflow, I recommend pulling the pipelines to your BioShell, so you know exactly where your pipeline files live, and what is being run.

Alternatively, you can use `git clone` here as well.

Confirm that it pulled successfully

```bash
ls
```

## How to check which containers are used

Use `nextflow inspect` to list every container a pipeline could use, without running anything.

```bash
nextflow inspect scrnaseq -profile singularity
```

So how do you actually know which ones apply to *your* run? Use the `-preview` flag that simulates a real run. Combined with `-with-dag`, it renders a picture of a graph of the processes that would be run given the parameters.

```bash
nextflow run /mnt/data/scrnaseq \
  -profile singularity \
  -c bioshell.config \
  -preview -with-dag dag.png
```

Open `dag.png`. It's busy — full of small dot/circle nodes for plumbing steps like `map`, `mix`, `groupTuple` — ignore all of those. What you're looking for are the labelled oval boxes, each named `NFCORE_SCRNASEQ:SCRNASEQ:...:PROCESS_NAME`. For this run there are exactly 10 of them, no `cellranger`, `simpleaf`, or `kallisto` process anywhere:

```
ANNDATA_BARCODES
ANNDATAR_CONVERT
CELLBENDER_REMOVEBACKGROUND
CONCAT_H5AD
FASTQC
GTF_GENE_FILTER
MTX_TO_H5AD
MULTIQC
STAR_ALIGN
STAR_GENOMEPARAMS_UPGRADE
```

Cross-reference that against the earlier `nextflow inspect` output (matching each name to its container) and only 3 of those 10 are Biocontainers images under `depot.galaxyproject.org/singularity/...` — the kind CVMFS mirrors:

| Process | Container |
|---|---|
| `FASTQC` | `https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0` |
| `GTF_GENE_FILTER` | `https://depot.galaxyproject.org/singularity/python:3.9--1` |
| `STAR_ALIGN` | `https://depot.galaxyproject.org/singularity/star:2.7.10b--h9ee0642_0` |

The other 7 (`CELLBENDER_REMOVEBACKGROUND`, `MTX_TO_H5AD`, `MULTIQC`, `ANNDATAR_CONVERT`, `CONCAT_H5AD`, `STAR_GENOMEPARAMS_UPGRADE`, `ANNDATA_BARCODES`) are Seqera Wave-built containers with no CVMFS mirror — nothing to redirect there, they download normally either way.

## How to make and apply a custom config

Reason: Free up storage for data, instead of containers. Every container above is a real file already sitting on this HPC's CVMFS mount — pointing the pipeline straight at those files means zero downloads and zero duplicate storage for anything CVMFS already covers.

First, look up the exact CVMFS path for each tool in the table above:

```bash
shelley find fastqc -v
```
```bash
shelley find python -v
```
```bash
shelley find star -v
```

Each one prints a table with a `Container Path` column — confirm the version matches the container tag from `nextflow inspect` above.

Then write `bioshell.config`, overriding just those three processes:

```bash
singularity {
    enabled    = true
    autoMounts = true
}
```

```bash
process {
    withName: 'FASTQC' {
        container = '/cvmfs/singularity.galaxyproject.org/all/fastqc:0.12.1--hdfd78af_0'
    }
    withName: 'GTF_GENE_FILTER' {
        container = '/cvmfs/singularity.galaxyproject.org/all/python:3.9--1'
    }
    withName: 'STAR_ALIGN' {
        container = '/cvmfs/singularity.galaxyproject.org/all/star:2.7.10b--h9ee0642_0'
    }
}
EOF
```

Each `withName { }` block points that one process straight at a local file — Nextflow runs `singularity exec` on it directly, with no cache directory and no download involved at all. Anything not listed here still downloads the normal way, so a pipeline with a mix of covered and uncovered containers (like this one) never breaks.

Apply it with `-c` (all of `input`/`fasta`/`gtf`/`aligner`/`protocol` already live in `bioshell.config`, so the run command stays minimal — see `run.sh`):

```bash
nextflow run /mnt/data/scrnaseq \
  -profile singularity \
  -c bioshell.config \
  --outdir results \
  -resume
```

# nfcore-scrnaseq

## Overview

The data being used

The pipeline being used

## How to pull a Nextflow pipeline

First let’s prepare our BioShell by changing directories into your provisioned volume. Recommend working in the volume, as pipelines often generate and use large data.

```bash
cd /mnt/data/
```

Next, load the nextflow and singularity modules. Nextflow will be used to run the processes, and singularity the individual processes within them.

Using singularity containers allows you to avoid downloading/compiling software and conda environments.

```bash
module load nextflow singularity
cvmfs_config probe
```

Pull the repository for the Nextflow pipeline with a local `git clone`, so you know exactly where your pipeline is saved and can pin it to a specific release yourself.

```bash
nextflow pull nfcore/scrnaseq
```

If pulling from a personal repo you can e.g. use `git clone https://github.com/Sydney-Informatics-Hub/Parabricks-Genomics-nf.git`. Adapt to your needs.

Confirm that it pulled successfully

```bash
ls
```

From here on, every `nextflow` command below refers to this local clone by its path (`/mnt/data/scrnaseq`) — not by the shorthand `nf-core/scrnaseq`, which instead pulls a separate copy into Nextflow's own hidden asset cache (`~/.nextflow/assets`). Using your own local clone means the exact pipeline code is sitting right here, browsable and reproducible, instead of tucked away somewhere you'd need to go looking for it.

## How to check which containers are used

Use `nextflow inspect` to list every container a pipeline could use, without running anything.

```bash
nextflow inspect scrnaseq -profile singularity
```

So how do you actually know which ones apply to *your* run? Use the `-preview` flag that simulates a real run. Combined with `-with-dag`, it renders a picture of a graph of the processes that would be run given the parameters.

```bash
nextflow run /mnt/data/scrnaseq \
  --input /mnt/data/samplesheet.csv \
  --outdir gse174609_run \
  --aligner star \
  --protocol 10XV3 \
  --fasta reference_chr19/Homo_sapiens.GRCh38.dna.chromosome.19.fa \
  --gtf creference_chr19/Homo_sapiens.GRCh38.114.chr19.gtf \
  -profile singularity \
  -preview -with-dag dag.png
```

Open `dag.png`. It's busy — full of small dot/circle nodes for plumbing steps like `map`, `mix`, `groupTuple` — ignore all of those. What you're looking for are the labelled oval boxes, each named `NFCORE_SCRNASEQ:SCRNASEQ:...:PROCESS_NAME`. For this run there are exactly 10 of them, no `cellranger`, `simpleaf`, or `kallisto` process anywhere:

Alternatively you could run it quickly to see which processes will be run.

```
executor >  local (9)
[2d/4abedf] NFCORE_SCRNASEQ:SCRNASEQ:FASTQC_CHECK:FASTQC (Post3)                                                   [100%] 6 of 6 ✔
[7c/92d29c] NFCORE_SCRNASEQ:SCRNASEQ:PREPARE_GENOME:GTF_GENE_FILTER (Homo_sapiens.GRCh38.dna.chromosome.19.fa)     [100%] 1 of 1 ✔
[37/b12c34] NFCORE_SCRNASEQ:SCRNASEQ:STARSOLO:STAR_GENOMEGENERATE (Homo_sapiens.GRCh38.dna.chromosome.19.fa)       [100%] 1 of 1 ✔
[c8/9392f3] NFCORE_SCRNASEQ:SCRNASEQ:STARSOLO:STAR_ALIGN (Pre1)                                                    [  0%] 0 of 6
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:MTX_TO_H5AD                                                                   -
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:H5AD_REMOVEBACKGROUND_BARCODES_CELLBENDER_ANNDATA:CELLBENDER_REMOVEBACKGROUND -
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:H5AD_REMOVEBACKGROUND_BARCODES_CELLBENDER_ANNDATA:ANNDATA_BARCODES            -
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:H5AD_CONVERSION:CONCAT_H5AD                                                   -
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:H5AD_CONVERSION:ANNDATAR_CONVERT                                              -
[-        ] NFCORE_SCRNASEQ:SCRNASEQ:MULTIQC                                                                       -
```

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

Apply it with `-c`:

```bash
nextflow run /mnt/data/scrnaseq \
  --input /mnt/data/samplesheet.csv \
  --outdir gse174609_run \
  --aligner star \
  --protocol 10XV3 \
  --fasta reference_chr19/Homo_sapiens.GRCh38.dna.chromosome.19.fa \
  --gtf reference_chr19/Homo_sapiens.GRCh38.114.chr19.gtf \
  -profile singularity \
  -preview -with-dag dag.png
``` 
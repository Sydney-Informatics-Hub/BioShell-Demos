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

Nextflow will be used to orchestrate the pipeline, and singularity will execute the individual tool versions that the pipeline uses.

```bash
module load nextflow singularity
```

Probe the CVMFS to ensure Nextflow can access the singularity images.

```bash
cvmfs_config probe
```

Next, I will pull the code for nf-core/scrnaseq pipeline

```bash
git clone https://github.com/nf-core/scrnaseq.git
```

I recommend pulling the pipelines to your BioShell, so you know exactly where your pipeline files live, and what is being run.

Alternatively, you can use `git clone` here as well.

Confirm that it pulled successfully

```bash
ls
```

## How to check which containers are used

When running nextflow, we want to use the containers that are already available on the BioShell. 

This avoids downloading unnecesary containers which extend your pipeline run, and take up space on the BioShell. 

In this example, the scranseq pipeline has several options, but I will only be using the STAR option.

Many existing pipelines will be similar in that it will have processes that will not be run.

In the next step, I will step through how to identify the containers you need, and how to use the ones available through the CVMFS.

---

Back in the BioShell, I have prepared a run script with all the parameters I need for the run,including:

* an input samplesheet which points to my input data I have on the mounted volume
* where outputs should be saved, 
* the aligner to use 
* and other options required for this run

This will look different based on the pipeline you're running, however -profile singularity should remain the same.

blah blah

```bash
nextflow run scrnaseq \
  --input samplesheet.csv \
  --outdir results \
  --aligner star \
  --protocol 10XV2 \
  --fasta data/GRCm38.p6.genome.chr19.fa \
  --gtf data/gencode.vM19.annotation.chr19.gtf \
  -profile singularity \
  -params-file params.yaml \
  -preview
```

Copy paste the processess into processes.txt to refer back to.

Next going back to the run script im going to replace the run command with inspect, and replacing -preview with -format config > bioshell.config.

What the inspect command does is output a config file with all the container versions that the pipeline uses.

```bash
nextflow inspect scrnaseq \
  --input samplesheet.csv \
  --outdir results \
  --aligner star \
  --protocol 10XV2 \
  --fasta data/GRCm38.p6.genome.chr19.fa \
  --gtf data/gencode.vM19.annotation.chr19.gtf \
  -params-file params.yaml \
  -profile singularity \
  -format config > bioshell.config
```

At the time of recording, there is no way to output only the ones we use, so the two-step preview and inspect needs to be used.

Now we have all of the containers and their versions, im going to clean out all the ones that we don't need, against the processes.txt file created earlier.

```
process { withName: 'FASTQC' { container = 'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' } }
process { withName: 'CELLRANGER_MULTI' { container = 'quay.io/nf-core/cellranger:10.0.0' } }
process { withName: 'CELLBENDER_REMOVEBACKGROUND' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/eb/ebcf140f995f79fcad5c17783622e000550ff6f171771f9fc4233484ee6f63cf/data' } }
process { withName: 'CELLRANGER_MKREF' { container = 'quay.io/nf-core/cellranger:10.0.0' } }
process { withName: 'PARSE_CELLRANGERMULTI_SAMPLESHEET' { container = 'https://depot.galaxyproject.org/singularity/python:3.9--1' } }
process { withName: 'CELLRANGERARC_COUNT' { container = 'quay.io/nf-core/cellranger-arc:2.0.2' } }
process { withName: 'MULTIQC' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/1b/1bef8af6be88c5733461959c46ac8ef73d18f65277f62a1695d0e1633054f9c2/data' } }
process { withName: 'MTX_TO_H5AD' { container = 'community.wave.seqera.io/library/scanpy:1.10.2--e83da2205b92a538' } }
process { withName: 'GAWK' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a1/a125c778baf3865331101a104b60d249ee15fe1dca13bdafd888926cc5490a34/data' } }
process { withName: 'ANNDATAR_CONVERT' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d8/d8036a262b63ab783572e3cb3120b6b138593e19d93a1059b9bfef80785c7218/data' } }
process { withName: 'KALLISTOBUSTOOLS_REF' { container = 'https://depot.galaxyproject.org/singularity/kb-python:0.28.2--pyhdfd78af_2' } }
process { withName: 'GUNZIP' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/52/52ccce28d2ab928ab862e25aae26314d69c8e38bd41ca9431c67ef05221348aa/data' } }
process { withName: 'SIMPLEAF_INDEX' { container = 'https://depot.galaxyproject.org/singularity/simpleaf:0.19.5--ha6fb395_0' } }
process { withName: 'CELLRANGER_MKGTF' { container = 'quay.io/nf-core/cellranger:10.0.0' } }
process { withName: 'CELLRANGERARC_MKGTF' { container = 'quay.io/nf-core/cellranger-arc:2.0.2' } }
process { withName: 'CELLRANGER_COUNT' { container = 'quay.io/nf-core/cellranger:10.0.0' } }
process { withName: 'CELLRANGERARC_MKREF' { container = 'quay.io/nf-core/cellranger-arc:2.0.2' } }
process { withName: 'KALLISTOBUSTOOLS_COUNT' { container = 'https://depot.galaxyproject.org/singularity/kb-python:0.28.2--pyhdfd78af_2' } }
process { withName: 'GTF_GENE_FILTER' { container = 'https://depot.galaxyproject.org/singularity/python:3.9--1' } }
process { withName: 'QCATCH' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a7/a7d0112866550e3bcf97c40104596a3ca2ecbc26c13cf919fe76587554528281/data' } }
process { withName: 'CONCAT_H5AD' { container = 'community.wave.seqera.io/library/scanpy:1.10.2--e83da2205b92a538' } }
process { withName: 'CELLRANGER_MKVDJREF' { container = 'quay.io/nf-core/cellranger:10.0.0' } }
process { withName: 'STAR_GENOMEPARAMS_UPGRADE' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a1/a125c778baf3865331101a104b60d249ee15fe1dca13bdafd888926cc5490a34/data' } }
process { withName: 'STAR_GENOMEGENERATE' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/26/268b4c9c6cbf8fa6606c9b7fd4fafce18bf2c931d1a809a0ce51b105ec06c89d/data' } }
process { withName: 'STAR_ALIGN' { container = 'https://depot.galaxyproject.org/singularity/star:2.7.10b--h9ee0642_0' } }
process { withName: 'ANNDATA_BARCODES' { container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fa/fa01776f530c0a0fe2b7d8d41009884040f75d175ff194641f846b215a1da8d6/data' } }
process { withName: 'SIMPLEAF_QUANT' { container = 'https://depot.galaxyproject.org/singularity/simpleaf:0.19.5--ha6fb395_0' } }
```

Some formatting:

```bash
process { 
    withName: 'FASTQC' { 
        container = 'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' 
    }
    withName: 'GTF_GENE_FILTER' { 
        container = 'https://depot.galaxyproject.org/singularity/python:3.9--1' 
    }
    withName: 'STAR_GENOMEGENERATE' { 
        container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/26/268b4c9c6cbf8fa6606c9b7fd4fafce18bf2c931d1a809a0ce51b105ec06c89d/data' 
    }
    withName: 'STAR_ALIGN' { 
        container = 'https://depot.galaxyproject.org/singularity/star:2.7.10b--h9ee0642_0' 
    }
    withName: 'MTX_TO_H5AD' { 
        container = 'community.wave.seqera.io/library/scanpy:1.10.2--e83da2205b92a538' 
    }
    withName: 'CONCAT_H5AD' { 
        container = 'community.wave.seqera.io/library/scanpy:1.10.2--e83da2205b92a538' 
    }
    withName: 'ANNDATAR_CONVERT' { 
        container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d8/d8036a262b63ab783572e3cb3120b6b138593e19d93a1059b9bfef80785c7218/data' 
    }
    withName: 'MULTIQC' { 
        container = 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/1b/1bef8af6be88c5733461959c46ac8ef73d18f65277f62a1695d0e1633054f9c2/data' 
    }
}
```

I want to point out that the containers used in this pipeline are hosted on different online repositories.

Those on galaxyproject will have exactly the same container on the CVMFS.

community-cr-prod.seqera.io and community.wave.seqera.io are seqera containers.

The wave containers indicate the tool and version, however the community-cr-prod ones do not. I will revist this later

First, i'll start with replacing the galaxyproject containers. 

I will use shelley find -v fastqc to get the full path to the CVMFS, copy, and replace the exist container identifier.

And repeat the same process with the other galaxyproject containers (GTF_GENE_FILTER, STAR_ALIGN).

Next I will tackle the wave containers. These use scanpy 1.10.2, however the CVMFS only has 1.7 as the latest version. For this demo, I will use 1.7. However, depending on your use case and need for reproducibility you might want to leave it. To help decide, you can refer to the softwares changelog to see the differences between the versions.

Lastly, I will tackle the community-cr-prod.seqera.io containers. I will run nextflow inspect again, but with -profile docker. This will contain information about the tools included.

```bash
nextflow inspect scrnaseq -profile docker -format config | grep -E 'STAR_GENOMEGENERATE|ANNDATAR_CONVERT|MULTIQC'
```

```
process { withName: 'MULTIQC' { container = 'community.wave.seqera.io/library/multiqc:1.34--db7c73dae76bc9e6' } }
process { withName: 'ANNDATAR_CONVERT' { container = 'community.wave.seqera.io/library/bioconductor-anndatar_bioconductor-rhdf5_bioconductor-singlecellexperiment_r-seurat:a0f51df063bb9b2a' } }
process { withName: 'STAR_GENOMEGENERATE' { container = 'community.wave.seqera.io/library/htslib_samtools_star_gawk:ae438e9a604351a4' } }
```

MULTIQC we can use a drop-in replacement, however ANDATAR_CONVERT and STAR_GENOMEGENERATE are mulled containers. These are containers that come packaged with multiple tools. These need to remain as the CVMFS contains only single-tool containers.

shelley find multiqc -v

```
process {
    resourceLimits = [ cpus: 3, memory: '14.GB' ]
}

singularity {
    cacheDir = '/mnt/data/.singularity_cache'
}
```

## Running the pipeline

```bash
nextflow run scrnaseq \
  --input samplesheet.csv \
  --outdir results \
  --aligner star \
  --protocol 10XV2 \
  --fasta data/GRCm38.p6.genome.chr19.fa \
  --gtf data/gencode.vM19.annotation.chr19.gtf \
  -params-file params.yaml \
  -profile singularity \
  -c bioshell.config
```

I've come across an error in ANNDATAR_CONVERT saying that the H5AF file was not valid, or created with an incompatbile version.

I checked the upstream process and it was MTX_TO_H5AD, the process where I used an older version of scanpy.

What I will do is delete the process definitions for MTX_TO_H5AD and CONCAT_H5AD, and this will default back to the wave container with the updated version.

So in this case the newer version was required and should have been left as is.

Then I'll go back to run.sh and add -resume to run only the processes that failed.

---

Pipeline has finished successfully and the results output.

I'm going to check how much space the pulled containers used.

du -sh .*

1.2 GB for three containers. Some containers can be larger, about 2-5GB

To recap, when using Nextflow on the BioShell:

1. Work in the mounted volume 
2. Use the nextflow and singularity modules to orchestrate the pipeline runs
3. Create a bioshell.config to utilise the available containers. This will conserve space on your BioShell, which becomes important when you are working with large input files, and pipelines that generate large outputs.

Thanks for watching, and happy BioShelling!


Music by: https://www.bensound.com/free-music-for-videos
License code: C3R6G4G1TEE9L8FZ
Artist: : Yunior Arronte
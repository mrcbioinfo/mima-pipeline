---
title: Installation
---

# Install MIMA Pipeline Singularity container

All tools required by the MIMA pipeline are encapsulated into a Singularity container called `mima_hXXX_mpaX.sif`, where the XXX depends on the version. Follow the guide below to install this container. After installing you can then run the [Data processing with Singularity](tutorials/tutorial-with-singularity) tutorial.

{% capture environment_note %}
This section assumes that your HPC/terminal environment already has Singularity installed via `modules`. You will also need to download reference databases required by third party tools, see <a href="requirements">Requirements</a>.
{% endcapture %}

{% include alert.html type="warning" title="Note" content=environment_note %}


## MIMA pipeline Singularity container

There are two Singularity container versions depending on the HUMAnN and MetaPhlAn reference database you have installed in your environment. If you are going to download the reference data from scratch, then it doesn't matter which container file you select.

| Singularity container | [mima_h350_mpa4.sif](https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h350_mpa401.sif){:target="_blank"} (1.64GB) | [mima_h301_mpa3.sif](https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h301_mpa310.sif){:target="_blank"} (1.61GB) |
|-----------------------|-------------------------------|-----------------------------|
| Tools included in the image | HUMAnN version 3.5<br/> MetaPhlAn version 4.0.1 | HUMAnN version 3.0.1<br/> MetaPhlAn version 3.1.0 |
| Required database | ChocoPhlAn database v201901_v31<br/> MetaPhlAn database v201901_v31 or 202103_vJan21 | ChocoPhlAn database v296_201901b<br/> MetaPhlAn database v201901_v30 |


- Download the MIMA image file you want (right click and copy link)

```
$ wget https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h301_mpa310.sif
```

## Start an interactive PBS job

We assume you are on a HPC environment with Singularity installed under `modules`. Many HPC environments won't allow running Singularity from the login or head node, you will need to start an *interactive* PBS job first.

- In OpenPBS, you can specify an interactive job using the command
  - this requests an interactive job with 4 CPUs, 4GB ram for 6 hours

```
$ qsub -I -l select=1:ncpus=4:mem=4gb,walltime=6:00:00
```

- Once the interactive job has been allocated, load `Singularity` via `modules`

```
$ module load singularity
```

- Load singularity first with the `module` command

```
$ module load singularity
$ singularity --version
```
at the time of writing this tutorial we were using `singularity version 3.6.4`. To specify a specific version, use `module load singularity/3.6.4`

## Build a sandbox and configure environment variables

When running commands using Singularity, the container needs to be unpacked each time. This can be slow when you need to run multiple commands sequentially. We can speed this up by building a *sandbox* environment, thus skipping the unpacking step.

- Build a *sandbox* called `mima-pipeline` and
- Create an environment variable called `SANDBOX` to store the full path (helps save typing a long filename each time)

```
$ singularity build --sandbox mima-pipeline mima_h301_mpa3.sif
$ export SANDBOX=`pwd`/mima-pipeline
```

- test that the `SANDBOX` environment variable and the sandbox is working by running the following command
  - if this command is not working then check your `SANDBOX` environment variable using `echo $SANDBOX` which will output the path

```
$ singularity run $SANDBOX
```

Below is the output, check the line **active environment : mima** is the same as below  
```
----
This singularity container contains MIMA pipeline
v1.0.0 - build: 2022-09-14

     active environment : mima
    active env location : /opt/miniconda/envs/mima
            shell level : 1
       user config file : /home/z3534482/.condarc
 populated config files : /home/z3534482/.condarc
          conda version : 4.12.0
    conda-build version : not installed
         python version : 3.9.12.final.0
       virtual packages : __linux=3.10.0=0
                          __glibc=2.35=0
                          __unix=0=0
                          __archspec=1=x86_64
       base environment : /opt/miniconda  (read only)
      conda av data dir : /opt/miniconda/etc/conda
  conda av metadata url : None
           channel URLs : https://conda.anaconda.org/biobakery/linux-64
                          https://conda.anaconda.org/biobakery/noarch
                          https://conda.anaconda.org/bioconda/linux-64
                          https://conda.anaconda.org/bioconda/noarch
                          https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
                          https://conda.anaconda.org/conda-forge/linux-64
                          https://conda.anaconda.org/conda-forge/noarch
                          https://conda.anaconda.org/default/linux-64
                          https://conda.anaconda.org/default/noarch
          package cache : /opt/miniconda/pkgs
                          /home/z3534482/.conda/pkgs
       envs directories : /home/z3534482/.conda/envs
                          /opt/miniconda/envs
               platform : linux-64
             user-agent : conda/4.12.0 requests/2.27.1 CPython/3.9.12 Linux/3.10.0-1160.76.1.el7.x86_64 ubuntu/22.04.1 glibc/2.35
                UID:GID : 13534482:40064
             netrc file : None
           offline mode : False

Python 3.10.6
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.0.1
MetaPhlAn version 3.1.0 (25 Jul 2022)
java -ea -Xmx138229m -Xms138229m -cp /opt/miniconda/envs/mima/opt/bbmap-38.97-1/current/ clump.Clumpify --version
BBMap version 38.97
For help, please run the shellscript with no parameters, or look in /docs/.
fastp 0.23.2
2.24-r1122
Kraken version 2.1.2
Copyright 2013-2021, Derrick Wood (dwood@cs.jhu.edu)
```

The `mima_h301_mpa3.sif` image should return the lines `humann v3.0.1` and `MetaPhlAn version 3.1.0` as above.

The `mima_h350_mpa4.sif` image should return the lines `humann v3.5` and `MetaPhlAn version 4.0.1` (not shown).

----

# Congratulations!

If you don't already have the required reference databases installed in your environment, then refer to the [Requirements](requirements) page.

Now you're ready to start the [Data processing with Singularity](tutorials/tutorial-with-singularity) tutorial

{% capture singularity_bind %}
<p>By default, Singularity will load the bare minimum filesystem to operate, that is your home directory. It does not automatically have access to other file systems. If you're data is located on another drive or path, then you need to inform Singularity using the <code class="language-plaintext highlighter-rouge">-B</code> parameter or the <code class="language-plaintext highlighter-rouge">SINGULARITY_BIND</code> environment variable.</p>

<p>See: <a href="tutorials/tutorial-with-singularity#pbs-configuration-files">Setting environment variable</a> example</p>
{% endcapture %}

{% include alert.html type="info" title="Note" content=singularity_bind %}
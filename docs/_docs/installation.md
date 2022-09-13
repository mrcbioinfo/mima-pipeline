---
title: Installation
---

# Install MIMA Pipeline Singularity container

All tools required by the MIMA pipeline are encapsulated into a Singularity container called `mima-pipeline.sif`. Follow the below step-by-step guide to install this container. After installing you can then run the [Data processing with Singularity](tutorial/tutorial-with-singularity) tutorial.

{% capture environment_note %}
This section assumes that your HPC/terminal environment already has Singularity installed via `modules`. You will also need to download reference databases required by third party tools, see [Requirements](requirements).
{% endcapture %}

{% include alert.html type="warning" title="Note" content=environment_node %}


## MIMA pipeline Singularity container

- Download the [mima-pipeline.sif] image file

```
$ wget
```

- We assume you are on a HPC environment with Singularity installed under `modules` (if not skip the `module` line)
- Load singularity first with the `module` command

```
$ module load singularity
$ singularity --version
```
at the time of writing this tutorial we were using `singularity version 3.6.4`
  - to specify a specific version, use `module load singularity/3.6.4`

## Build a sandbox and configure environment variables

When running commands using Singularity, the container needs to be unpacked each time. This can be slow when you need to run multiple commands sequentially. We can speed this up by building a 'sandbox' environment, thus skipping the unpacking step.

- Build a *sandbox* called `mima-pipeline` and
- Create an environment variable called `SANDBOX` to store the full path (helps save typing a long filename each time)

```
$ singularity build --sandbox mima-pipeline mima-pipeline.sif
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
This singularity container contains MIMA conda environment
v1.0.0 - build: 2022-09-06

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
             user-agent : conda/4.12.0 requests/2.27.1 CPython/3.9.12 Linux/3.10.0-1160.62.1.el7.x86_64 ubuntu/22.04.1 glibc/2.35
                UID:GID : 13534482:40064
             netrc file : None
           offline mode : False

Python 3.10.5
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.1.1
```

Now you're ready to start the [Data processing with Singularity](tutorials/tutorial-with-singularity) tutorial

{% capture singularity_bind %}
By default, Singularity will load the bare minimum filesystem to operate, that is your home directory. It does not automatically have access to other file systems. If you're data is located on another drive or path, then you need to inform Singularity using the `-B` parameter or the `SINGULARITY_BIND` environment variable. See the tutorial for example: [Data processing with Singularity](tutorials/tutorial-with-singularity)
{% endcapture %}

{% include alert.html type="warning" title="Note" content=singularity_bind %}
---
title: Installation
weight: 20
---

## MIMA Container image

All tools required by the MIMA pipeline are encapsulated into a [Container image]({{< ref "what-is-container.md" >}}) file with the `mimaX_vX.X.X_yyyyddmm.sif` naming scheme, where XXX denotes different versions.

The latest MIMA container version (mima4_v2.0.0) supports HUMAnN v3.8 and MetaPhlAn v4.1.0 tools and their reference database (older reference databases will not work).

{{% alert info=warn %}}
For MRC users, see <a href="https://unsw.sharepoint.com/:w:/r/sites/mrc_bioinformatics_unit/_layouts/15/doc2.aspx?sourcedoc=%7BBF4C59B2-9C8D-4868-AB8C-5B6B4C206252%7D&file=Katana%20reference%20databases%20-%20MIMA%20pipeline.docx&action=default&mobileredirect=true" target="_blank;">here for Container image location</a>
{{% /alert %}}

## Start an interactive PBS job

We assume you are on a HPC environment with a job scheduling system. Many HPC environments will not allow running containers from the login or head node. You need to start an *interactive* PBS job first.

- In OpenPBS, specify the following to request an interactive job with 4 CPUs, 4GB ram for 6 hours

```Shell
qsub -I -l select=1:ncpus=4:mem=4gb,walltime=6:00:00
```

- **Optional**: if `apptainer` (or `singularity`) is installed via *Modules* on your host machine, then run the following 

```Shell
module load apptainer
apptainer --version
```

at the time of writing this tutorial we were using `apptainer version 1.2.4-1el.8`

## Build a sandbox

As mentioned previously, to [skip repeated unpacking the image]({{< ref "what-is-container.md/#build-a-sandbox" >}}) when we deploy containers, we will build a *sandbox* container.

- Build a sandbox called `mima-pipeline`
  - below shows command for the two MIMA versions

{{< tabpane text=true right=false >}}
  {{% tab header="**Image version**:" disabled=true /%}}
  {{% tab header="mima4_v2.0.0_20240409" lang="en" %}}

  ```Shell
  apptainer build --sandbox mima-pipeline mima4_v2.0.0_20240409.sif
  ```
  ```Text
  INFO:    Starting build...
  INFO:    Verifying bootstrap image mima4_v2.0.0_20240409.sif
  INFO:    Creating sandbox directory...
  INFO:    Build complete: 
  ```
  {{% /tab %}}
{{< /tabpane >}}

- Create a `SANDBOX` environment variable to store the full directory path (saves typing a long paths!)

```Shell
export SANDBOX=`pwd`/mima-pipeline
```

## Confirm installation

- Test `SANDBOX` environment variable is working
- If this command is not working then check your `SANDBOX` environment variable using `echo $SANDBOX` which should output the path where you build the sandbox

```Shell
apptainer run $SANDBOX
```

Below is the output, check the line **active environment : mima** is the same as below  

{{< tabpane text=true right=false >}}
  {{% tab header="**Image version**:" disabled=true /%}}
  {{% tab header="mima4_v2.0.0" lang="en" %}}
  ```Text
----
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-binutils_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gcc_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gfortran_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gxx_linux-64.sh:10:40: parameter expansion requires a literal
Auto-activate MIMA conda environment
source: /opt/miniconda/envs/mima/etc/conda/deactivate.d/deactivate-gxx_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/deactivate.d/deactivate-gfortran_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/deactivate.d/deactivate-gcc_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/deactivate.d/deactivate-binutils_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-binutils_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gcc_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gfortran_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gxx_linux-64.sh:10:40: parameter expansion requires a literal
----
This is the MIMA pipeline Container
v2.0.0 - build: 20240409

     active environment : mima
    active env location : /opt/miniconda/envs/mima
            shell level : 1
       user config file : /home/z3534482/.condarc
 populated config files : /home/z3534482/.condarc
          conda version : 24.1.2
    conda-build version : not installed
         python version : 3.12.1.final.0
                 solver : libmamba (default)
       virtual packages : __archspec=1=zen2
                          __conda=24.1.2=0
                          __glibc=2.35=0
                          __linux=4.18.0=0
                          __unix=0=0
       base environment : /opt/miniconda  (read only)
      conda av data dir : /opt/miniconda/etc/conda
  conda av metadata url : None
           channel URLs : https://conda.anaconda.org/biobakery/linux-64
                          https://conda.anaconda.org/biobakery/noarch
                          https://conda.anaconda.org/conda-forge/linux-64
                          https://conda.anaconda.org/conda-forge/noarch
                          https://conda.anaconda.org/bioconda/linux-64
                          https://conda.anaconda.org/bioconda/noarch
                          https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
                          https://conda.anaconda.org/default/linux-64
                          https://conda.anaconda.org/default/noarch
          package cache : /opt/miniconda/pkgs
                          /home/z3534482/.conda/pkgs
       envs directories : /home/z3534482/.conda/envs
                          /opt/miniconda/envs
               platform : linux-64
             user-agent : conda/24.1.2 requests/2.31.0 CPython/3.12.1 Linux/4.18.0-513.24.1.el8_9.x86_64 ubuntu/22.04.4 glibc/2.35 solver/libmamba conda-libmamba-solver/23.12.0 libmambapy/1.5.3
                UID:GID : 13534482:5000
             netrc file : None
           offline mode : False


Python 3.10.8
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.8
MetaPhlAn version 4.1.0 (23 Aug 2023)
java -ea -Xmx97655m -Xms97655m -cp /opt/miniconda/envs/mima/opt/bbmap-39.01-1/current/ clump.Clumpify --version
BBMap version 39.01
For help, please run the shellscript with no parameters, or look in /docs/.
fastp 0.23.4
2.28-r1209
Kraken version 2.1.3
Copyright 2013-2023, Derrick Wood (dwood@cs.jhu.edu)
```
  {{% /tab %}}
{{< /tabpane >}}


{{% alert color="warning" title=Reminder %}}
By default Containers are deployed with very minimum filesystem access and you might need to [bind paths]({{< ref "what-is-container.md#path-binding" >}})
{{% /alert %}}

Next check you have all the required [data-dependencies]({{< ref "data-dependencies.md" >}}).

---
title: Installation
weight: 20
---


All tools required by the MIMA pipeline are encapsulated into a [Container image](../what-is-container) file with the `mima_XXX.sif` naming scheme, where XXX denotes different versions.

- [MIMA container version](#mima-container-version)
- [Start an interactive PBS job](#start-an-interactive-pbs-job)
- [Build a sandbox](#build-a-sandbox)
- [Confirm installation](#confirm-installation)

## MIMA container version

Two MIMA container versions are provided, differing in the HUMAnN and MetaPhlAn tools and their reference database. If you are downloading the reference data from scratch, then it doesn't matter which container file you select.

{{< blocks/section color="white" type="row" >}}
{{% blocks/download icon="fa-solid fa-download"
title="**MIMA_h350m401.sif**"
url="https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h350_mpa401.sif" %}}
  **Tools**

    - HUMAnN v3.5.0
    - MetaPhlAn v4.0.1

  **Reference database**

    - ChocoPhlAn v201901_v31
    - MetaPhlAn DB: 
    v201901_v31 or 202103_vJan21
{{% /blocks/download %}}
{{% blocks/download icon="fa-solid fa-download"
title="**MIMA_h301m310.sif**"
url="https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h301_mpa310.sif" %}}
**Tools** 

    - HUMAnN v3.0.1
    - MetaPhlAn v3.1.0
  
**Reference database**

    - ChocoPhlAn v296_201901b
    - MetaPhlAn DB v201901_v30
{{% /blocks/download %}}
{{< /blocks/section >}}

&nbsp;

- Right click > copy link, download using the following command

```Shell
curl -L https://github.com/mrcbioinfo/mima-pipeline/releases/download/v1.0.0/mima_h301_mpa310.sif
```

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

As mentioned previously, to [skip repeated unpacking of the container image](../what-is-container/#build-a-sandbox), we will build a *sandbox* container.

- Build a *sandbox* called `mima-pipeline`
- Create a `SANDBOX` environment variable to store the full directory path (saves typing a long paths!)

{{< tabpane text=true right=false >}}
  {{% tab header="**Image version**:" disabled=true /%}}
  {{% tab header="mima_h350_mpa401" lang="en" %}}
  ```Shell
  apptainer build --sandbox mima-pipeline mima_h350_mpa401.sif
  ```

  ```
  INFO:    Starting build...
  INFO:    Verifying bootstrap image mima_h350_mpa401.sif
  INFO:    Creating sandbox directory...
  INFO:    Build complete: 
  ```

  ```Shell
  export SANDBOX=`pwd`/mima-pipeline
  ```
  {{% /tab %}}
  {{% tab header="mima_h301_mpa310" lang="en" %}}
  ```Shell
  apptainer build --sandbox mima-pipeline mima_h301_mpa310.sif
  ```

  ```
  INFO:    Starting build...
  INFO:    Verifying bootstrap image mima_h350_mpa401.sif
  INFO:    Creating sandbox directory...
  INFO:    Build complete: 
  ```

  ```Shell
  export SANDBOX=`pwd`/mima-pipeline
  ```
  {{% /tab %}}
{{< /tabpane >}}


## Confirm installation

- test `SANDBOX` environment variable is working. 
- if this command is not working then check your `SANDBOX` environment variable using `echo $SANDBOX` which will output the path

```Shell
apptainer run $SANDBOX
```

Below is the output, check the line **active environment : mima** is the same as below  

{{< tabpane text=true right=false >}}
  {{% tab header="**Image version**:" disabled=true /%}}
  {{% tab header="mima_h305_mpa401" disabled=false lang="en" %}}
  ```Text
----
This is the MIMA pipeline Container
v1.1.0 - build: 20240118

     active environment : mima
    active env location : /opt/miniconda/envs/mima
            shell level : 1
       user config file : /home/z3534482/.condarc
 populated config files : /home/z3534482/.condarc
          conda version : 4.12.0
    conda-build version : not installed
         python version : 3.9.12.final.0
       virtual packages : __linux=4.18.0=0
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
             user-agent : conda/4.12.0 requests/2.27.1 CPython/3.9.12 Linux/4.18.0-477.27.1.el8_8.x86_64 ubuntu/22.04.3 glibc/2.35
                UID:GID : 13534482:5000
             netrc file : None
           offline mode : False

Python 3.10.8
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.5
MetaPhlAn version 4.0.1 (24 Aug 2022)
java -ea -Xmx83265m -Xms83265m -cp /opt/miniconda/envs/mima/opt/bbmap-38.97-1/current/ clump.Clumpify --version
BBMap version 38.97
For help, please run the shellscript with no parameters, or look in /docs/.
fastp 0.23.2
2.24-r1122
Kraken version 2.1.2
Copyright 2013-2021, Derrick Wood (dwood@cs.jhu.edu)
  ```
  {{% /tab %}}
  {{% tab header="mima_h301_mpa310" lang="en" %}}
  ```Text
----
This is the MIMA pipeline Container
v1.1.0 - build: 20240122

     active environment : mima
    active env location : /opt/miniconda/envs/mima
            shell level : 1
       user config file : /home/centos/.condarc
 populated config files :
          conda version : 4.12.0
    conda-build version : not installed
         python version : 3.9.12.final.0
       virtual packages : __linux=4.18.0=0
                          __glibc=2.35=0
                          __unix=0=0
                          __archspec=1=x86_64
       base environment : /opt/miniconda  (read only)
      conda av data dir : /opt/miniconda/etc/conda
  conda av metadata url : None
           channel URLs : https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
          package cache : /opt/miniconda/pkgs
                          /home/centos/.conda/pkgs
       envs directories : /home/centos/.conda/envs
                          /opt/miniconda/envs
               platform : linux-64
             user-agent : conda/4.12.0 requests/2.27.1 CPython/3.9.12 Linux/4.18.0-257.el8.x86_64 ubuntu/22.04.3 glibc/2.35
                UID:GID : 1000:1000
             netrc file : None
           offline mode : False

Python 3.10.8
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.0.1
MetaPhlAn version 3.1.0 (25 Jul 2022)
java -ea -Xmx5377m -Xms5377m -cp /opt/miniconda/envs/mima/opt/bbmap-38.97-1/current/ clump.Clumpify --version
BBMap version 38.97
For help, please run the shellscript with no parameters, or look in /docs/.
fastp 0.23.2
2.24-r1122
Kraken version 2.1.2
Copyright 2013-2021, Derrick Wood (dwood@cs.jhu.edu)
  ```
  {{% /tab %}}
{{< /tabpane >}}


{{% alert color="warning" title=Reminder %}}
By default Containers are deployed with very minimum filesystem access and you might need to [bind paths](../what-is-container/#path-binding)
{{% /alert %}}

Next [check the data-dependencies](../data-dependencies)

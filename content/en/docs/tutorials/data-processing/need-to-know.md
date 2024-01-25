---
title: Need to know
description: preparation for data-processing tutorials
weight: 100
type: docs
---


## Working directory

After [downloading the tutorial data]({{< ref "download-tutorial-data" >}}), we assume that the `mima_tutorial` is the working directory located in your *home directory* (specified by the tilde, `~`). Hence, we will try to always make sure we are in the right directory first before executing a command, for example, run the following commands:

```
$ cd ~/mima_tutorial
$ tree .
```

- the starting directory structure for `mima_tutorial` should look something like:

```
mima_tutorial
├── ftp_download_files.sh
├── manifest.csv
├── pbs_header_func.cfg
├── pbs_header_qc.cfg
├── pbs_header_taxa.cfg
├── raw_data/
    ├── SRR17380115_1.fastq.gz
    ├── SRR17380115_2.fastq.gz
    ├── ...
...
```

From here on, `~/mima_tutorial` will refer to the project directory as depicted above. Replace this path if you saved the tutorial data in another location.


{{% alert title="TIP: Text editors" color="primary" %}} 

There are several places where you may need to edit the commands, scripts or files. You can use the <a href="https://www.tutorialspoint.com/vim/vim_editing.htm" target="_blank">`vim` text editors</a> to edit text files directly on the terminal. 

For example, the command below lets you edit the `pbs_head_qc.cfg` text file

```Shell
vim pbs_header_qc.cfg
```
{{% /alert %}}

## PBS configuration files

The three modules (QC, Taxonomy profiling and Function profiling) in the data-processing pipeline require access to a job queue and instructions about the resources required for the job. For example, the number of CPUs, the RAM size, the time required for execution etc. These parameters are defined in PBS configuration text files. 

Three such configuration files are in provided after you have [downloaded the tutorial data]({{< ref "download-tutorial-data" >}}). There are 3 configuration files, one for each module as they require different PBS settings indicated by lines starting with the `#PBS` tags.

{{< highlight Bash "linenos=table,linenostart=1" >}}
#!/bin/bash
#PBS -N mima-qc
#PBS -l ncpus=8
#PBS -l walltime=2:00:00
#PBS -l mem=64GB
#PBS -j oe

set -x

IMAGE_DIR=~/mima-pipeline
export APPTAINER_BIND="</path/to/source1>:</path/to/destination1>,</path/to/source2>:</path/to/destination2>"
{{< /highlight >}}

| <div style="width:150px">PBS settings</div> | Description |
|------------------------|------------------------------------------------------------------------------------------|
| `#PBS -N`              | name of the job |
| `#PBS -l ncpus`        | number of CPUs required |
| `#PBS -l walltime`     | how long the job will take, here it's 2 hours. *Note* check the log files whether your jobs have completed correctly or failed due to not enough time |
| `#PBS -l mem=64GB `    | how much RAM the job needs, here it's 64GB |
| `#PBS -l -j oe`        | standard output logs and error logs are concatenated into one file |


- `IMAGE_DIR` refers to where you installed MIMA and [built your sandbox](/docs/installation/#build-a-sandbox).

- `APPTAINER_BIND` is the environment variable you set when [binding file paths](/docs/what-is-container/#path-binding) to the container.

## Use absolute paths

When running the pipeline it is best to use **full paths** when specifying the locations of input files, output files and reference data to avoid any ambiguity.

### Absolute/Full paths
always start with the root directory, indicated by the forward slash (`/`) on Unix based systems.

- e.g., below changes directory (`cd`) to a folder named `scripts` that is located in the user `jsmith`'s home directory. Provided this folder exists, then this command will work from anywhere on the filesystem."

```
[~/metadata] $ cd /home/jsmith/scripts
```

### Relative paths
are relative to the current working directory

- Now imagine the following file system structure in the user `john_doe`'s home directory
- The asterisks marks his current location, which is inside the `/home/user/john_doe/studyAB/metadata` sub-folder

{{< highlight Text "linenos=false,hl_lines=5,linenostart=1" >}}
/home/user/john_doe
├── apps
├── reference_data
├── studyABC
│   ├── metadata **
│   ├── raw_reads
│   └── analysis
├── study_123
├── scripts
└── templates
{{< /highlight >}}

- In this example we are currently in the `metadata` directory, and change directory to a folder named `data` that is located in the parent directory (`..`)
- This command **only works** provided there is a `data` folder in the parent directory above `metadata`
- According to the filesystem above, the parent directory of `metadata` is `studyABC` and there is no `data` subfolder in this directory, so this command will fail with an error message

```
[/home/user/john_doe/studyABC/metadata] $ cd ../data
-bash: cd: ../data: No such file or directory
```

Now that you have installed the data and know the basics, you can begin data processing with [quality control]({{< ref "mima-apptainer-qc" >}}).

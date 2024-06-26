---
title: Functional Profiling
description: assign reads to gene families and pathways, generating a function feature table ready for analysis
weight: 130
---


## Introduction to Functional Profiling

Functional profiling, like taxonomy profiling, takes the cleaned sequenced reads after [QC checking]({{< ref "mima-apptainer-qc" >}}) as input and matches them against a reference database of previously characterised gene sequences.

There are different types of functional classification tools available. This pipeline uses the <a href="https://huttenhower.sph.harvard.edu/humann/">HUMAnN3</a> pipeline, which also comes with its own [reference databases]({{< ref "data-dependencies.md#function-profiling" >}}).

### Workflow description

One PBS script per sample is generated by this module. In this tutorial, we have 9 samples, so there will be 9 PBS scripts.

Steps in the functional profiling module:

<table class="table table-borderless">
<tr>
  <th>Steps</th>
  <th></th>
</tr>
<tr>
  <td><b>HUMAnN3</b> is used for processing and generates three outputs for each sample: <br/>
  <ol type='i'>
    <li>gene families</li>
    <li>pathway abundances</li>
    <li>pathway coverage</li>
  </ol>
  <td rowspan=2 style="width:40%"><img src="../images/tut_function_pipeline.png"/></td>
</tr>
<tr>
  <td><b>Generate feature table</b> is performed after <i>all samples</i> have been processed. This combines the output and generates a <i>feature table</i> that contains the abundance of gene/pathway X in sample Y.</td>
</tr>
</table>


## Step 1. Generate PBS scripts

Before starting, have you understood the [need to know]({{< ref "need-to-know" >}}) points?

  - After [QC checking]({{< ref "mima-apptainer-qc" >}}) your sequence samples and generating a set of `CleanReads`
  - Find the [absolute paths]({{< ref "need-to-know.md#use-absolute-paths" >}}) for the **HUMAnN3** and **MetaPhlAn** reference databases depending on the [MIMA version you installed]({{< ref "installation" >}})
  - Replace the highlighted lines with the absolute path for the reference databases
    - `path/to/humann3/chocophlan`
    - `path/to/humann3/uniref`
    - `path/to/humann3/utility_mapping`
    - `path/to/metaphlan_databases`
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come (we broke up the command for readability purposes to explain each parameter below)
  - *note* if you enter the command as one line, remove the backslashes

{{< highlight Tcsh "linenos=table,hl_lines=4-7,linenostart=1" >}}
apptainer run --app mima-function-profiling $SANDBOX \
-i ~/mima_tutorial/output/QC_module/CleanReads \
-o ~/mima_tutorial/output \
--nucleotide-database </path/to>/humann3/chocophlan \
--protein-database /<path/to>/humann3/uniref \
--utility-database /<path/to>/humann3/utility_mapping \
--metaphlan-options "++bowtie2db /<path/to>/metaphlan_databases" \
--mode container \
--pbs-config ~/mima_tutorial/pbs_header_func.cfg
{{< /highlight >}}


{{% alert info=warn %}}
For MRC users, see <a href="https://unsw.sharepoint.com/:w:/r/sites/mrc_bioinformatics_unit/_layouts/15/doc2.aspx?sourcedoc=%7BBF4C59B2-9C8D-4868-AB8C-5B6B4C206252%7D&file=Katana%20reference%20databases%20-%20MIMA%20pipeline.docx&action=default&mobileredirect=true" target="_blank;">here for file locations</a>
{{% /alert %}}


### Parameters explained

| <div style="width:250px">Parameter</div> | Required? | Description |
| ---------- | --------- | ----------- |
| `-i <input>` | yes | full path to the `~/mima_tutorial/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | yes | full path to the `~/mima_tutorial/output` output directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--nucleotide-database <path>` | yes | directory containing the nucleotide database, (default=`/refdb/humann/chocophlan`) |
| `--protein-database <path>` | yes | directory containing the protein database, (default=`/refdb/humann/uniref`) |
| `--utility-database <path>` | yes | directory containing the protein database, (default=`/refdb/humann/utility_mapping`) |
| `--metaphlan-options <string>` | yes | additional MetaPhlAn settings, like specifying the bowtie2 reference database (default=`"++bowtie2db /refdb/humann/metaphlan_databases"`). Enclose parameters in double quotes and use `++` for parameter settings. |
| `--mode container` | no (default='single') | set this if you are running in the Container mode |
| `--pbs-config` | yes if `--mode container` | path to the pbs configuration file (see below). You must specify this parameter if `--mode container` is set. You do not need to set this parameter if running outside of Singularity | 
| `--mpa3` | no | this parameter is only applicable for MIMA container with MetaPhlAn4. You can set `--mpa3` for <a href="https://forum.biobakery.org/t/announcing-metaphlan-4/3994" target="_blank;">backward compatibility with MetaPhlAn3 databases</a> |

## Step 2. Check PBS scripts output

- After step 1, you should see in the output directory: `~/mima_tutorial/output/Function_profiling`

```Shell
tree ~/mima_tutorial/output/Function_profiling
```

- There should be one PBS script/sample  (total of 9 bash scripts in this tutorial)
  
```Text
...
├── featureTables
│   ├── generate_func_feature_tables.pbs
│   └── generate_func_feature_tables.sh
├── SRR17380209.pbs
├── SRR17380218.pbs
├── SRR17380222.pbs
├── SRR17380231.pbs
├── SRR17380232.pbs
└── SRR17380236.pbs
```

## Step 3. Submit Function jobs

- Let's examine one of the PBS scripts

```
$ cat ~/mima_tutorial/output/Function_profiling/SRR17380209.pbs
```

* Your PBS script should look something like below, with some differences
  - line 10: `IMAGE_DIR` should be where you installed MIMA and [build the sandbox]({{< ref "installation.md#build-a-sandbox" >}})
  - line 11: `APPTAINER_BIND` should be setup during installation when [binding paths]({{< ref "what-is-container.md#path-binding" >}})
    - make sure to include the path where the host reference genome file is located
  - line 14: `/home/user` is replaced with the [absolute path]({{< ref "need-to-know.md#use-absolute-paths" >}}) to your actual home directory
  - lines 22-25: ensure the paths to the reference databases are all replaced (the example below uses the vJan21 database version and the parameter `index` is sent to MetaPhlAn to disable autocheck of index)
  - note that the walltime is set to 8 hours

{{< highlight shell "linenos=table,hl_lines=10-11 14 22-25,linenostart=1" >}}
#!/bin/bash
#PBS -N mima-func
#PBS -l ncpus=8
#PBS -l walltime=8:00:00
#PBS -l mem=64GB
#PBS -j oe

set -x

IMAGE_DIR=~/mima-pipeline
export APPTAINER_BIND="/path/to/humann3_database:/path/to/humann3_database,/path/to/metaphlan_databases:/path/to/metaphlan_databases"


cd /home/user/mima_tutorial/output/Function_profiling/

# Execute HUMAnN3
cat /home/user/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_1.fq.gz ~/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_2.fq.gz > ~/mima_tutorial/output/Function_profiling/SRR17380209_combine.fq.gz

outdir=/home/user/mima_tutorial/output/Function_profiling/
apptainer exec ${IMAGE_DIR} humann -i ${outdir}SRR17380209_combine.fq.gz --threads 28 \
-o $outdir --memory-use maximum \
--nucleotide-database </path/to/humann3>/chocophlan \
--protein-database </path/to/humann3>/uniref \
--utility-database </path/to/humann3>/utility_mapping \
--metaphlan-options \"++bowtie2db /path/to/metaphlan_databases ++index mpa_vJan21_CHOCOPhlAnSGB_202103\" \
--search-mode uniref90
{{< /highlight >}}


{{% alert color=info title="Tip: when running your own study" %}}
- increase the walltime if you have alot of samples
- increase the memory as needed
{{% /alert %}}


- Change directory to `~/mima_tutorial/output/Functional_profiling`
- Submit PBS job using `qsub`

```
$ cd ~/mima_tutorial/output/Functional_profiling
$ qsub SRR17380209.pbs
```

- Repeat this for each `*.pbs` file
- You can check your job statuses using `qstat`
- Wait until all PBS jobs have completed

## Step 4. Check Function outputs

- After all PBS jobs have completed, you should have the following outputs

```
$ ls -1 ~/mima_tutorial/output/Function_profiling
```

- Only a subset of the outputs are shown below with `...` meaning *"and others"*
- Each sample that passed QC, will have a set of functional outputs

```shell
featureTables
...
SRR17380115_combine_genefamilies.tsv
SRR17380115_combine_humann_temp
SRR17380115_combine_pathabundance.tsv
SRR17380115_combine_pathcoverage.tsv
SRR17380115.pbs
SRR17380118_combine_genefamilies.tsv
SRR17380118_combine_humann_temp
SRR17380118_combine_pathabundance.tsv
SRR17380118_combine_pathcoverage.tsv
SRR17380118.pbs
...
SRR17380236.pbs
```


{{% alert color=info title="Functional outputs" %}}
The HUMAnN3 website provides very good descriptions <a href="https://github.com/biobakery/humann#output-files" target="_blank">explaining the HUMAnN3 output files</a>
{{% /alert %}}


## Step 5. Generate Function feature tables

- After **all samples** have been functionally annotated, we need to combine the tables together and normalise the abundances
- Navigate to `~/mima_tutorial/output/Fuctional_profiling/featureTables`
- Submit the PBS script file `generate_func_feature_tables.pbs`

```
$ cd <PROJECT_PATH>/output/Functional_profiling/featureTables
$ qsub generate_func_feature_tables.pbs
```

- Check the output
- Once the job completes you should have 7 output files beginning with the `merge_humann3table_` prefix

```
~/mima_tutorial/
└── output/
    ├── Function_profiling
    │   ├── featureTables
    │   ├── func_table.o2807928
    │   ├── generate_func_feature_tables.pbs
    │   ├── generate_func_feature_tables.sh
    │   ├── merge_humann3table_genefamilies.cmp_uniref90_KO.txt
    │   ├── merge_humann3table_genefamilies.cpm.txt
    │   ├── merge_humann3table_genefamilies.txt
    │   ├── merge_humann3table_pathabundance.cmp.txt
    │   ├── merge_humann3table_pathabundance.txt
    │   ├── merge_humann3table_pathcoverage.cmp.txt
    │   └── merge_humann3table_pathcoverage.txt
    ├── ...
```

{{% alert color=info title="Tip: if you want different pathway mappings" %}}
In the file `generate_func_feature_tables.sh`, the last step in the `humann_regroup_table` command uses the KEGG orthology mapping file, that is the `-c` parameter:

```
-g uniref90_rxn -c <path/to/>map_ko_uniref90.txt.gz
```

If you prefer other mappings than change this line accordingly before running the PBS job using `generate_func_feature_tables.pbs`
{{% /alert %}}

----

# Congratulations !

You have completed processing your shotgun metagenomics data and are now ready for further analyses

Analyses usually take in either the [taxonomy feature tables]({{< ref "mima-apptainer-taxonomy.md#step-5-generate-taxonomy-abundance-table" >}}) or [functional feature tables](#step-5-generate-function-feature-tables)

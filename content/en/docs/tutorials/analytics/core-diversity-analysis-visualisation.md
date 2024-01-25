---
title: Core diversity analysis and visualisation
description: comparisons of groups in cross-sectional studies
weight: 210
---


## Introduction

This tutorial runs through three common core biodiversity analyses for cross-sectional study designs that include group comparisons.

#### Alpha-diversity analysis
  - describes the biodiversity of a single sample/community. There are many metrics such as Richness (number of species detected), Evenness (describing the distribution of abundances across the detected species in a sample), Shannon Diversity (combines richness and abundances) and  others.
  - the pipeline will calculate the alpha-diversity for each sample present in the feature table and then perform hypothesis testing to assess if there are any significant (p < 0.05) differences between groups. The pipeline also generates a set of plots to compare the alph-diversity between groups.

#### Beta-diversity analysis
  - measures the community (dis)similarity between two or more samples/communities. Two common metrics are:
    - Jaccard (dis)similarity which only considers presence/absences of species
    - Bray-Curtis dissimilarity which also considers the abundances of the detected species
  - the pipeline will calculate the pairwise beta-diversities between all samples present in the feature table and then perform <a href="https://search.r-project.org/CRAN/refmans/vegan/html/adonis.html" target="_blank">PERMANOVA testing using the `adonis` function in `vegan`</a> to assess for any significant (p < 0.05) differences between groups. The pipeline also generates a set of plots to help visualise the similarity between samples coloured by the groups using multiple ordinations.

#### Differential abundance analysis
  - identifies which features (e.g., species, genes, pathways) are significant different between groups based on their relative abundances


## Example study data

The data set used for this tutorial is based on the *full* data set from the [data processing tutorials]({{< ref "data-processing" >}} <a href="https://journals.asm.org/doi/10.1128/spectrum.01915-21" target="_blank">(Tourlousse, *et al.*, 2022)</a> that was pre-process with the same pipeline. There are 56 samples in total from the study, but after taxonomy profiling with Kraken2 and Bracken, 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples.

This data set consists of two mock communities: (i) *DNA-mock* and (ii) *Cell-mock* processed in three different labs: A, B and C.

{{% alert color=secondary title="Analysis objective" %}}
In this tutorial, our main questions are:

- *is there a difference between the two types of mock communities?* and
- *are there any differences between the processing labs?*
{{% /alert %}}


## Check list

For this set of tutorial, you need

  - System with `Apptainer` or `Singularity` installed (currently only tested on UNIX-based system)
  - [Install MIMA Pipeline Singularity container]({{< ref "installation" >}}) and check that you have
    - started an interactive PBS job
    - build the *sandbox* container
    - set the `SANDBOX` environment variable


## Step 1) Data preparation

{{% alert color=success title="Skip if ..." %}}
You can skip this section if you have already run the [Biodiversity bar plot tutorial]({{< ref "biodiversity-bar-plots" >}}) and go directly to [Step 2-to refresh yourself with the data](#step-2-examine-input-files) or proceed to [Step 3, running the analysis.](#step-3-run-core-diversity-analysis)
{{% /alert %}}

  - Use the `vis-tutorial` directory from [Biodiversity bar plots]({{< ref "biodiversity-bar-plots" >}}) or create a directory `vis-tutorial`
  - Change into this directory

```Shell
mkdir vis-tutorial
cd vis-tutorial
```

  - Download [taxonomy-feature-table.tar.gz](https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/taxonomy-feature-table.tar.gz)
    - *Note* only the processed feature tables are provided in this download; intermediate files from the [data processing pipeline]({{< ref "data-processing" >}}) are not provided.

```Shell
wget https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/taxonomy-feature-table.tar.gz
```

  - Extract the archived file

```Shell
tar xf taxonomy-feature-table.tar.gz
```

  - Check the directory structure matches
  - Only a subset of the files are shown below and `...` means "and others"

```Shell
tree .
```
```
~/vis-tutorial/
├── metadata.tsv
├── taxonomy-feature-table.tar.gz
└── Taxonomy_profiling
    └── featureTables
        ├── bracken_FT_class
        ├── bracken_FT_class_counts
        ├── bracken_FT_class_relAbund
        ├── ...
        ├── bracken_FT_genus
        ├── bracken_FT_genus_counts
        ├── bracken_FT_genus_relAbund
        ├── combine_bracken_class.log
        ├── ...
        ├── combine_bracken_genus.log
        └── generate_bracken_feature_table.py
```

{{% alert color=warning title="Note! Assumed working directory" %}}
This tutorial assumes the `vis-tutorial` directory is in your home directory as indicated by the `~` (tilde) sign. 
If you have put the files in another location then replace all occurrences of `~/vis-tutorial` with your location.
{{% /alert %}}


### Data files explained

| Directory / File | Description |
|------------------|-------------|
| `metadata.tsv`   | is a tab-separated text file of the study metadata |
| `Taxonomy_profiling/featureTables` | <p>directory contains the [taxonomy feature tables]({{< ref "mima-apptainer-taxonomy.md#step-5-generate-taxonomy-abundance-table" >}}) using Kraken2 and Bracken. </p><p>There are feature tables for each taxonomy rank from Phylum to Species. As some analysis tools might require feature table input to be discrete counts while others might require relative abundances, two formats are provided with the suffixes:</p><ul><li>`*_count` files have discrete counts of features (row) per samples (columns)</li><li>`*_relAbund` files ahve the relative abundances of features (row) per samples (columns)</li></ul> |


- Confirm you have the following 3 files (if they don't exists, there will be an error message)

```Shell
ls metadata.tsv
ls Taxonomy_profiling/featureTables/bracken_FT_genus_counts
ls Taxonomy_profiling/featureTables/bracken_FT_genus_relAbund
```

## Step 2) Examine input files

### Examine metadata

- Examine the `metadata.csv` file:
  - `head` shows the first 10 rows
  - `column` formats the output into columns using tab as the separator (prettier view)

```Shell
head metadata.tsv | column -t -s $'\t'
```

```
Sample_ID    biosample     experiment   instrument           library.name                     sample.name                                         lab   type                 n_species
SRR17380113  SAMN20256237  SRX13554346  Illumina HiSeq 2500  metagenome_mockCell_labC_lib016  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380114  SAMN20256237  SRX13554345  Illumina HiSeq 2500  metagenome_mockCell_labC_lib015  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380115  SAMN20256237  SRX13554344  Illumina HiSeq 2500  metagenome_mockCell_labC_lib014  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380116  SAMN20256237  SRX13554343  Illumina HiSeq 2500  metagenome_mockCell_labC_lib013  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380117  SAMN20256237  SRX13554342  Illumina HiSeq 2500  metagenome_mockCell_labC_lib012  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380118  SAMN20256237  SRX13554341  Illumina HiSeq 2500  metagenome_mockCell_labC_lib011  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380119  SAMN20256237  SRX13554340  Illumina HiSeq 2500  metagenome_mockCell_labC_lib010  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380120  SAMN20256237  SRX13554339  Illumina HiSeq 2500  metagenome_mockCell_labC_lib009  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380121  SAMN20256237  SRX13554338  Illumina HiSeq 2500  metagenome_mockCell_labC_lib008  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
```

- There should be 9 columns in the `metadata.tsv` file
  - row 1 is the header and the columns are pretty much self-explanatory
  - column 1 is the `Sample_ID`, which **must correspond** with the sample names in the feature tables
  - column 8 is the `lab` where the sample was processed, this will be our grouping factor in later steps

### Examine taxonomy feature table
 
- You can have a quick look at the taxonomy input table
  - this command will show the first 10 rows and 6 columns

```Shell
head Taxonomy_profiling/featureTables/bracken_FT_genus_relAbund | cut -f1-6 | column -t -s $'\t'
```

- For example, check the sample IDs (columns) are the same as the `metadata.tsv`
  
```
name                        SRR17380113  SRR17380114  SRR17380116  SRR17380117  SRR17380119
s__Escherichia flexneri     0.06616      0.06187      0.06694      0.06276      0.0674
s__Escherichia dysenteriae  0.0346       0.03221      0.03489      0.03252      0.03523
s__Escherichia coli_D       0.03155      0.02893      0.03205      0.02955      0.03223
s__Escherichia coli         0.0185       0.01747      0.01875      0.01766      0.01872
s__Escherichia coli_C       0.00975      0.00943      0.00986      0.00956      0.00994
s__Escherichia sp004211955  0.00458      0.00473      0.0046       0.00474      0.00463
s__Escherichia sp002965065  0.00375      0.00399      0.00381      0.00402      0.00379
s__Escherichia fergusonii   0.00398      0.00371      0.00405      0.00375      0.00405
s__Escherichia sp000208585  0.00321      0.0033       0.00326      0.00334      0.00328
```

## Step 3) Run core diversity analysis

- Enter the following command
  - if `/vis-tutorial` is not in your home directory (`~`), change the `~/vis-tutorial/` to the [absolute path]({{< ref "need-to-know.md#use-absolute-paths" >}}) where you [downloaded the tutorial data](#step-1-data-preparation)
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come (we broke up the command for readability purposes to explain each parameter below)
  - *note* if you enter the command as one line, remove the backslashes
  

{{< highlight Bash "linenos=table,linenostart=1" >}}
apptainer run --app mima-visualisation $SANDBOX \
--feature-table ~/vis-tutorial/Taxonomy_profiling/featureTables/bracken_FT_species_counts \
--metadata ~/vis-tutorial/metadata.tsv \
--study-groups lab,type \
--output-dir ~/vis-tutorial/analysis > ~/vis-tutorial/visualisation.log
{{< /highlight >}}

### Parameters explained

| <div style="width:225px">Parameter</div>   | Description |
|-----------------|-------------|
| `--feature-table <path>` | [absolute filepath](../data-processing/need-to-know/#use-absolute-paths) to the taxonomy abundance table |
| `--metadata <path>`      | filepath to the study metadata table |
| `--study-groups <col1>,<col2>`  | Comma separated list of column names found in the `--metadata` file. These columns contain the study groups of interest. Each column should have at least 2 or more levels for comparisons. |
| `--output-dir <path>`    | output directory path |

- In this tutorial, we are performing two sets of comparisons:
  - comparing between `lab`s (3 levels: A, B, and C)
  - comparing between mock community `type` (2 levels: DNA and Cell)

### Confirm output directories

```Shell
tree -d ~/vis-tutorial/analysis
```

```
~/vis-tutorial/analysis/
├── Kraken
├── Kraken_alpha
│   ├── boxplots
│   │   ├── corrected_sig
│   │   ├── non_sig
│   │   └── uncorrected_sig
│   └── wilcox-pairwise
├── Kraken_beta
│   ├── permanova
│   └── plots
└── Kraken_diff-abundance
    ├── barplot
    ├── boxplots
    │   ├── corrected_sig
    │   └── uncorrected_sig
    ├── volcano
    └── wilcox-pairwise
```

Your output directory (only folders are shown) should resemble something like above, where first level sub-directories:

| <div style="width:200px">Directory</div>      |  Description              |
|-------------------|---------------------------|
| `Kraken/`         | <p>directory contains two text files:</p><ol type='i'><li>`otu_matrix.txt` - the feature abundance table</li><li> `TaxProfileWithMeta.txt` - the feature abundance table concatenated with the study metadata provided by the `--metadata` parameter</li></ol> |
| `Kraken_alpha/`   | outputs from [alpha-diversity analysis](#alpha-diversity-output) |
| `Kraken_beta/`      | outputs from [beta-diversity analysis](#beta-diversity-output) |
| `Kraken_diff-abundance/` | outputs from [differential abundance analysis](#differential-abundance-analysis-output) |

## Step 4) Understanding the output files

### Alpha-diversity output

- Examine the output files for [alpha-diversity analysis](#alpha-diversity-analysis)

```Shell
tree ~/vis-tutorial/analysis/Kraken_alpha
```

{{< highlight Bash "linenos=false,hl_lines=5-7 9 16 18-19 21-23 27-29,linenostart=1" >}}
~/vis-tutorial/analysis/Kraken_alpha
├── alpha_diversity_raw_data.txt
├── boxplots
│   ├── corrected_sig
│   │   ├── chao1_lab_dotplot.png
│   │   ├── chao2_lab_dotplot.png
│   │   ├── evenness_lab_dotplot.png
│   │   ├── invsimperson_type_dotplot.png
│   │   ├── observed_lab_dotplot.png
│   │   ├── shannon_type_dotplot.png
│   │   └── simperson_type_dotplot.png
│   ├── non_sig
│   │   ├── chao1_type_dotplot.png
│   │   ├── chao2_type_dotplot.png
│   │   ├── evenness_type_dotplot.png
│   │   ├── invsimperson_lab_dotplot.png
│   │   ├── observed_type_dotplot.png
│   │   ├── shannon_lab_dotplot.png
│   │   └── simperson_lab_dotplot.png
│   └── uncorrected_sig
├── lab_filter_table.txt
├── lab_kw_stat_summary.txt
├── lab_pairwise_dunn_test.txt
├── type_filter_table.txt
├── type_kw_stat_summary.txt
└── wilcox-pairwise
    ├── lab_labA_labB.wil.stat_summary.txt
    ├── lab_labA_labC.wil.stat_summary.txt
    ├── lab_labB_labC.wil.stat_summary.txt
    └── type_Cell mock community_DNA mock community.wil.stat_summary.txt

5 directories, 24 files
{{< /highlight >}}

- Since we ran 2 sets of comparisons, between `lab` and `type`, there are 2 sets of results as indicated by the 2nd part of the filename.
- When **comparing between labs**, the output files with `*_lab_*` in the filename (highlighted rows), you should have:
  - 4 significant results after adjusting for multiple comparison adjustment using: chao1, chao2, [evenness and observed richness](#example-figures) diversity indcies
  - 3 non-significant results after adjustment using: inverse simpson, shannon and simpson indices
  - 0 results that were significant before adjustment


#### Sub-directories explained

| <div style="width:200px">Directory</div>      |  Description              |
|-------------------|---------------------------|
| `Kraken_alpha/boxplots/` | <p>boxplots comparing groups defined by the `--study-groups` parameter. If there are two groups then the Wilcox rank-sum test is performed, if there are more than two groups than the Kruskal-Wallis test is performed.</p><p>Comparisons are adjusted for multiple comparisons and results are separated further into sub-directories.</p>|
| `.../boxplots/corrected_sig/` | alpha-diversities that show significant group differences after adjustment |
| `.../boxplots/non_sig/` | non-significant alpha-diversities after adjustment |
| `.../boxplots/uncorrected_sig/` | results that are significant before adjustment |
| `Kraken_alpha/wilcox-pairwise/` | text output from Wilcox rank-sum tests for two-group comparisons defined by the `--study-groups` parameter |
| **File**             |  |
| `alpha_diversity_raw_data.txt` | tab-separated text file of calculated alpha-diversities (columns) for each sample (row)|
| `*_filter_table.txt`           | filtered `alpha_diversity_raw_data.txt` table|
| `*_kw_stat_summary.txt`        | output from Kruskal-Wallis test when there are > 2 groups being compared |
| `*_pairwise_dunn_test.txt`     | output from post-hoc pairwise comparisons when there are > 2 groups being compared |

#### Example figures

{{< cardpane >}}
{{< card header="**Comparing Observed Richness between Labs**" 
         footer="File: observed_lab_dotplot.png" >}}
  <img src="../images/core-diversity/observed_lab_dotplot.png"/>
  There is significant differences between Labs A-vs-B, A-vs-C and B-vs-C when comparing their Observed richness (number of species detected in a sample).
{{< /card >}}

{{< card header="**Comparing Evenness between Labs**" 
        footer="File: evenness_lab_dotplot.png" >}}
  <img src="../images/core-diversity/evenness_lab_dotplot.png" />
  There is significant differences between Labs A-vs-B, A-vs-C and B-vs-C when comparing their Evenness (a measure to describe the abundance distribution of species detected in a sample/community, e.g., their dominance/rareness).
{{< /card >}}
{{< /cardpane >}}


### Beta-diversity analysis output

- Examine the output files for [beta-diversity analysis](#beta-diversity-analysis)

```Shell
tree ~/vis-tutorial/analysis/Kraken_beta
```

{{< highlight Bash "linenos=false,hl_lines=3 6 8 10 12 14 16 18,linenostart=1" >}}
~/vis-tutorial/analysis/Kraken_beta/
├── permanova
│   ├── lab_pairwise_adonis.results.tsv
│   └── type_pairwise_adonis.results.tsv
└── plots
    ├── CA-Bray-Curtis-lab.png
    ├── CA-Bray-Curtis-type.png
    ├── CCA-Bray-Curtis-lab.png
    ├── CCA-Bray-Curtis-type.png
    ├── DCA-Bray-Curtis-lab.png
    ├── DCA-Bray-Curtis-type.png
    ├── NMDS-Bray-Curtis-lab.png
    ├── NMDS-Bray-Curtis-type.png
    ├── PCA-Bray-Curtis-lab.png
    ├── PCA-Bray-Curtis-type.png
    ├── PCoA-Bray-Curtis-lab.png
    ├── PCoA-Bray-Curtis-type.png
    ├── RDA-Bray-Curtis-lab.png
    └── RDA-Bray-Curtis-type.png

2 directories, 16 files
{{< /highlight >}}

* `*_results.tsv` are text files of results from the PERMANOVA tests
* Multiple ordination plots are generated in the `plots` directory
* As we preformed 2 sets of comparisons (the `--study-groups` parameter had value `lab,type`) we have 2 files per ordination with the column name used as the suffix for the output file

#### Example figures

Principal co-ordinate analysis plot of the beta-diversity measured using Bray-Curtis dissimilarity between samples grouped by the three labs.

{{< figure src="../images/core-diversity/PCoA-Bray-Curtis-lab.png"
           caption="File: PCoA-Bray-Curtis-lab.png."
           class="figure"
           img-class="figure-img img-fluid rounded mx-auto d-block border border-medium"
           height="50%"
           width="50%" >}}

### Differential abundance analysis output

- Examine the output files for [differential abundance analysis](#differential-abundance-analysis)

```Shell
tree ~/vis-tutorial/analysis/Kraken_diff-abundance/
```
  
**warning!** there will be *a lot* of files because we performed 2 sets of comparisons between `lab` and `type`. Below only shows a snapshot with `...` meaning *"and others"*
{{< highlight Bash "linenos=false,hl_lines=3-4 10 13-14 20-22 27-30 35-37,linenostart=1" >}}
~/vis-tutorial/analysis/Kraken_diff-abundance/
├── barplot
│   ├── lablabA_labB_barplot_FDR.png
│   ├── lablabA_labB_barplot_p.png
│   ├── typeCell mock community_DNA mock community_barplot_FDR.png
│   └── typeCell mock community_DNA mock community_barplot_p.png
├── boxplots
│   ├── corrected_sig
│   │   ├── ...
│   │   ├── s__Bifidobacterium.callitrichos_lab_dotplot.png
│   │   ├── s__Bifidobacterium.callitrichos_type_dotplot.png
│   │   ├── ...
│   │   └── s__Zag1.sp900556295_lab_dotplot.png
│   └── uncorrected_sig
│       ├── ...
│       ├── s__Acetatifactor.muris_type_dotplot.png
│       ├── ...
│       └── s__Zag1.sp900556295_type_dotplot.png
├── lab_filter_table.txt
├── lab_kw_stat_summary.txt
├── lab_pairwise_dunn_test.txt
├── type_filter_table.txt
├── type_kw_stat_summary.txt
├── volcano
│   ├── Cell mock community_DNA mock community.volcanoplot.d.p.png
│   ├── labA_labB.volcanoplot.d.p.png
│   ├── lablabA_labB.volcanoplot.d.FDR.png
│   ├── lablabA_labB.volcanoplot.Log2FC.FDR.png
│   ├── lablabA_labB_volcanoplot_Log2FC_p.png
│   ├── typeCell mock community_DNA mock community.volcanoplot.d.FDR.png
│   ├── typeCell mock community_DNA mock community.volcanoplot.Log2FC.FDR.png
│   └── typeCell mock community_DNA mock community_volcanoplot_Log2FC_p.png
└── wilcox-pairwise
    ├── lab_labA_labB.wil.stat_summary.txt
    ├── lab_labA_labC.wil.stat_summary.txt
    ├── lab_labB_labC.wil.stat_summary.txt
    └── type_Cell mock community_DNA mock community.wil.stat_summary.txt

6 directories, 2301 files
{{< /highlight >}}

#### Example figures

{{< cardpane >}}
  {{< card header="Example marker 1" 
           footer="<small>File: s__Acetivibrio_A.ethanolgignens_lab_dotplot.png</small>" >}}
    <img src="../images/core-diversity/s__Acetivibrio_A.ethanolgignens_lab_dotplot.png" />
    The univariate comparison suggests there is significant lab differences after adjustment for multiple comparison in species *Acetivibrio A ethanolgignens*.
  {{< /card >}}
  {{< card header="Example marker 2" 
           footer="<small>File: s__Bifidobacterium.callitrichos_lab_dotplot.png</small>" >}}
    <img src="../images/core-diversity/s__Bifidobacterium.callitrichos_lab_dotplot.png" />
    Another example of significant lab differences after adjustment for multiple comparison in species *Bifidobacterium callitrichos*.
  {{< /card >}}
{{< /cardpane >}}



#### Sub-directories explained

The output files are organised in a similar fashion as per [alpha-diversity output](#alpha-diversity-output)

| <div style="width:200px">Directory</div>      |  Description              |
|-------------------|---------------------------|
| `Kraken_diff-abundance/barplot/` | bar plot of each input feature and the measured Hodges-Lehmann estimator.<br/>*suitable for 2 groups only*, if you have >2 groups in your study, this will only compare the first two groups. |
| `Kraken_diff-abundance/boxplots/` | <p>one boxplot for every feature (e.g., species, gene, pathway) in the input feature table, comparing between groups specified by the columns in `--study-groups`.</p><p>Comparisons are adjusted for multiple comparisons and results are separated further into sub-directories</p> |
| `.../boxplots/corrected_sig/` | features that show significant group differences after adjustment |
| `.../boxplots/non_sig/` | non-significant features after adjustment |
| `.../boxplots/uncorrected_sig/` | features that are significant before adjustment |
| `Kraken_diff-abundance/volcano/` | volcano plots of comparisons, a scatterplot showing the statistical significance (p-value) versus the magnitude of change (fold change). |
| `Kraken_diff-abundance/wilcox-pairwise/` | text output from Wilcox rank-sum tests for two-group comparisons defined by the `--study-groups` parameter |
| **File**             |  |
| `*_filter_table.txt`           | filtered `alpha_diversity_raw_data.txt` table|
| `*_kw_stat_summary.txt`        | output from Kruskal-Wallis test when there are > 2 groups being compared |
| `*_pairwise_dunn_test.txt`     | output from post-hoc pairwise comparisons when there are > 2 groups being compared |
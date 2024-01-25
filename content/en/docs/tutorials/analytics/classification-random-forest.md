---
title: Classification with Random Forest
description: assessing the classification using Random Forest for cross-sectional studies
weight: 220
math: true
---

## Introduction

This tutorial shows how to run Random Forest classification using the MIMA Container.

Briefly, <a href="https://towardsdatascience.com/understanding-random-forest-58381e0602d2" target="_blank">Random Forest</a> is a supervised machine learning approach for classification and regression. It uses labelled data (what samples below to what group) to learn which key data features are useful in differentiating samples between classes (groups)---hence "supervised learning"---so that when *new* data are presented it can make a prediction. 

Input data required for training a Random Forest classifier:
  - one or more feature tables: a text file with features (e.g., species, genes, or pathways) as rows and samples as columns. The cells denote the relative abundance of feature *i* for sample *j*. 
  - metadata: informs the classifier which samples belong to which group; samples must belong to mutually exclusive groups.

One common approach to **evaluate classifier performance** is via <a href="https://towardsdatascience.com/cross-validation-705644663568" target="_blank">cross-validation (CV)</a>, which basically splits the input data into a *training* set and a *testing* set. MIMA uses the *K-fold* cross-validation approach. This splits the input data into *K* number of partitions; hold one partition for testing and the remaining *K-1* partitions are used for training. So when you have 5-fold CV, you split data into 5 parts or 80/20% split with 80% of the data used for training and 20% used for testing.

In MIMA, *K* ranges from 3 to 10, incrementing by one each time, so for each input data you will get 8 [outputs](#step-4-check-output-files): cv_3, cv_4, ..., cv_9, cv_10.


## Example data

For this tutorial, we will use data from the <a href="https://www.hmpdacc.org/hmp/" target="_blank">Human Microbiome Project V1</a>.

Our data consists of N=205 stool samples, of which 99 are from females and 106 are from males. Only samples from their first visit are used. The taxonomy profiles have been annotated using the MetaPhlAn2 pipeline. 

{{% alert color=secondary title="Analysis objective" %}}
Our question is *"how well can we distinguish between Sex using the human stool microbiome?"*
{{% /alert %}}

## Check list

For this set of tutorial, you need

  - System with `Apptainer` or `Singularity` installed (currently only tested on UNIX-based system)
  - [Install MIMA Pipeline Singularity container]({{< ref "installation" >}}) and check that you have
    - started an interactive PBS job
    - build the *sandbox* container
    - set the `SANDBOX` environment variable

## Step 1) Data preparation

- Create a directory `randforest-tut`
- Change directory

```Shell
mkdir randforest-tut
cd randforest-tut
```

- Download data [HMPv1-stool-samples.tar.gz](https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/HMPv1-stool-samples.tar.gz)

```Shell
wget https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/HMPv1-stool-samples.tar.gz
```

- Extract the archived file

```Shell
tar -xf HMPv1-stool-samples.tar.gz
```

- Check directory structure

```Shell
tree .
```

```
~/random-forest
├── HMPv1-stool-samples
│   ├── hmp1-stool-visit-1.features_1-kingdom.tsv
│   ├── hmp1-stool-visit-1.features_2-phylum.tsv
│   ├── hmp1-stool-visit-1.features_3-class.tsv
│   ├── hmp1-stool-visit-1.features_4-order.tsv
│   ├── hmp1-stool-visit-1.features_5-family.tsv
│   ├── hmp1-stool-visit-1.features_6-genus.tsv
│   ├── hmp1-stool-visit-1.features_7-species.tsv
│   ├── hmp1-stool-visit-1.features_8-strain.tsv
│   └── hmp1-stool-visit-1.metadata.tsv
└── HMPv1-stool-samples.tar.gz

1 directory, 10 files
```

There should be 9 tab-separated text files (*.tsv extension) of which one is the *metadata* and the other are *feature tables* from Kingdom to Strain ranks.


{{% alert color=warning title="Note! assumed working directory" %}}
This tutorial assumes the `randforest-tut` directory is in your home directory as indicated by the `~` (tilde) sign. 
If you have put the files in another location then replace all occurrences of `~/randforest-tut` with your location.
{{% /alert %}}

## Step 2) Examine input files

- Examine the metadata

```Shell
head HMPv1-stool-samples/hmp1-stool-visit-1.metadata.tsv | column -t
```

```Text
SN         RANDSID    VISNO  STArea  STSite  SNPRNT     Gender  WMSPhase  SRS
700014562  158458797  1      Gut     Stool   700014555  Female  1         SRS011061
700014724  158479027  1      Gut     Stool   700014718  Male    1         SRS011084
700014837  158499257  1      Gut     Stool   700014832  Male    1         SRS011134
700015181  158742018  1      Gut     Stool   700015179  Female  1         SRS011239
700015250  158802708  1      Gut     Stool   700015245  Male    1         SRS011271
700015415  158944319  1      Gut     Stool   700015394  Female  1         SRS011302
700015981  159247771  1      Gut     Stool   700015979  Female  1         SRS011405
700016142  159146620  1      Gut     Stool   700016136  Male    1         SRS011452
700016610  159166850  1      Gut     Stool   700016608  Male    1         SRS011529
```

There are 9 columns, where `SN` is the Sample ID and should correspond with the columns of the feature table


- Examine the *CLASS* feature table

```Shell
head HMPv1-stool-samples/hmp1-stool-visit-1.features_3-class.tsv | cut -f1-6 | column -t
```

```Text
lineage                                               700014562  700014724  700014837  700015181  700015250  700015415  700015981  700016142  700016610
k__Archaea|p__Euryarchaeota|c__Methanobacteria        0          0          0.0008246  0.0006299  0          0.0013228  0          0          0.0005494
k__Archaea|p__Euryarchaeota|c__Methanococci           0          0          0          0          0          0          0          0          0
k__Bacteria|p__Acidobacteria|c__Acidobacteria_noname  0          0          0          0          0          0          0          0          0
k__Bacteria|p__Acidobacteria|c__Acidobacteriia        0          0          0          0          0          0          0          0          0
k__Bacteria|p__Actinobacteria|c__Actinobacteria       0.00042    0.0038802  0.0006441  0.0082703  0.0020957  0.0042049  0.0001552  0.0012545  0.0031392
k__Bacteria|p__Bacteroidetes|c__Bacteroidetes_noname  0          0          0          0          0          0          0          0          0
k__Bacteria|p__Bacteroidetes|c__Bacteroidia           0.910796   0.837664   0.600565   0.844245   0.80352    0.451224   0.924745   0.887734   0.838053
k__Bacteria|p__Bacteroidetes|c__Cytophagia            0          0          0          0          0          0          0          0          0
k__Bacteria|p__Bacteroidetes|c__Flavobacteriia        0          0          0          0          0          0          0          0          0
```
 


## Step 3) Run Random Forest Classifier

- First create an output directory

```Shell
mkdir classifer-output
```

- Enter the following command
  - if you used different [data preparation](#step-1-data-preparation) settings, than replace all `~/randforest-tut` with your location.
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come (we broke up the command for readability purposes to explain each parameter below)
  - *note* if you enter the command as one line, remove the backslashes
  

{{< highlight Bash "linenos=table,linenostart=1" >}}
$ apptainer run --app mima-classifier-RF $SANDBOX \
-i ~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_1-kingdom.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_2-phylum.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_3-class.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_4-order.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_5-family.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_6-genus.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_7-species.tsv,\
~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.features_8-strain.tsv \
-m ~/randforest-tut/HMPv1-stool-samples/hmp1-stool-visit-1.metadata.tsv \
-c Gender \
-o classifier-output
{{< /highlight >}}

### Parameters explained

| Line | <div style="width:250px">Parameters</div> | Description |
|------|------------|-------------|
| 2 | `-i/--input <path>` | comma separated list of input text files (e.g. taxonomy abundance tables). |
| 10 | `-m/--metadata <path>` | file path of the study metadata table. Expect a tab separated text file with one row per sample with the first row being the header, and columns are the different metadata. |
| 11 | `-c/--column <column_name>` | column header from the metadata table that contains the grouping categories for classification |
| 12 | `-o/--output <output_dir>` | output directory path where results are stored |

{{% alert color=secondary title="N+1 output"%}}
If N input files are provided, there will be N+1 sets of output: 
- one classifier for each input data 
- a classifier trained on `data_all` which combines all the input data together as a big table

In this tutorial, we provided 8 input taxonomy files from Kingdom to Strain level features. This will generate 9 output files: one for each taxonomy rank and the last is a big table combining all the previous 8 together.
{{% /alert %}}


## Step 4) Check output files

As [mentioned above](#introduction), MIMA uses K-fold cross validation (CV/cv) to evaluate the trained Random Forest classifier overall performance. For each input data there will be 8 outputs from cv_3 to cv_10.

- Examine the output files

```Shell
tree classifier-output
```

```
~/randforest-tut/classifier-output
├── cv_auc.pdf
├── roc_classif.randomForest_dataset.pdf
├── roc_data_1_classifier.pdf
├── roc_data_1.pdf
├── roc_data_2_classifier.pdf
├── roc_data_2.pdf
├── roc_data_3_classifier.pdf
├── roc_data_3.pdf
├── roc_data_4_classifier.pdf
├── roc_data_4.pdf
├── roc_data_5_classifier.pdf
├── roc_data_5.pdf
├── roc_data_6_classifier.pdf
├── roc_data_6.pdf
├── roc_data_7_classifier.pdf
├── roc_data_7.pdf
├── roc_data_8_classifier.pdf
├── roc_data_8.pdf
├── roc_data_all_classifier.pdf
├── roc_data_all.pdf
└── socket_cluster_log.txt

0 directories, 21 files
```

You should have 21 files in total

| File | N files | N pages/file | Description          |
|------|-----------|-----------|----------------------|
| `socket_cluster_log.txt` | 1 | n/a | log text file |
| `roc_data_*_classifier.pdf` | 9 | 8 | <p>there is on file one per input data (8 in total from Kingdom to Strain taxonomy abundance tables) and the last output `data_all` is where all input tables are combined.</p><p>Each PDF (data set) will have 8 pages: from 3- to 10-fold CV</p> |
| `cv_auc.pdf` | 1 | 9 | one page per input data: 8 from Kingdom to Strain and the last page for `data_all` where all the input tables are combined |
| `roc_classif.randomForest_dataset.pdf` | 1 | 8 | one page per cross-validation (from 3- to 10-fold CV) |
| `roc_data_*.pdf` | 9 | 8 | <p>same as above</p> |



### Example figures

There is one `roc_data_*_classifier.pdf` file for each input data. Each PDF contains one page per N-fold cross validation (CV) that includes 3-folds to 10-folds CV. 

Below we've only shown the classification results when using Species (`data_7`) as input features and for 4 out of 8 CVs.

<a href="https://en.wikipedia.org/wiki/Receiver_operating_characteristic" target="_blank">**Receiver operating characteristic curve (ROC curve)**</a> is a graph that shows the overall performance of a classification model. Ideally, good classifiers will have high specificity (x-axis) and high sensitivity (y-axis), therefore the desired curve is towards to top-left above the diagonal line. If the curve follows the diagonal line then the classifier is no better than randomly guessing the class (groups) a sample belongs.


{{< cardpane >}}
{{< card >}}
  {{< figure src="https://upload.wikimedia.org/wikipedia/commons/1/13/Roc_curve.svg"
            caption="ROC curve characteristics [source: Wikipedia]"
            class="figure"
            img-class="figure-img img-fluid mx-auto d-block" >}}
{{< /card >}}
{{< card >}}
  {{% alert color=warning title="note" %}}
  In the plots generated by MIMA Random Forest Classification, the x-axis shown is in reverse order from 1 to 0, since false positive rate, \\(FPR = 1-Specificity\\)
  {{% /alert %}}
{{< /card >}}
{{< /cardpane >}}


The **area under the ROC curve (AUC)** is the overall accuracy of a classifier, ranging between 0-1 (or reported as percentages).

- Below shows a subset of the figures from the Species (input 7) abundance table `roc_data_7_classifier.pdf`. There is one page per cross-validation from 3- to 10-fold CV.
- Note the AUC annotation at the top of each figure

{{< tabpane text=true right=false >}}
{{% tab header="**roc_data_7_classifier.pdf**" disabled=true /%}}
{{% tab header="cv_3" disabled=false lang="en" %}}
  {{< figure src="images/random-forest-HMP/roc_data_7_cv3.png"
              caption="This shows the ROC curve for the Species relative abundance table (data_7) when using 3-fold cross-validation."
              class="figure"
              img-class="figure-img img-fluid rounded mx-auto d-block" 
              height="75%"
              width="75%" >}}
{{% /tab %}}
{{% tab header="cv_4" lang="en" %}}
  {{< figure src="/images/tutorials/classifer/random-forest-HMP/roc_data_7_cv4.png"
              caption="This figure shows the ROC curve for the Species relative abundance table (data_7) when using 4-fold cross-validation."
              class="figure"
              img-class="figure-img img-fluid rounded mx-auto d-block" 
              height="75%"
              width="75%">}}
{{% /tab %}}
{{% tab header="..." disabled=true lang="en" /%}}
{{% tab header="cv_8" lang="en" %}}
  {{< figure src="/images/tutorials/classifer/random-forest-HMP/roc_data_7_cv8.png"
              caption="This figure shows the ROC curve for the Species relative abundance table (data_7) when using 8-fold cross-validation."
              class="figure"
              img-class="figure-img img-fluid rounded mx-auto d-block" 
              height="75%"
              width="75%">}}
{{% /tab %}}
{{% tab header="cv_9" lang="en" %}}
  {{< figure src="/images/tutorials/classifer/random-forest-HMP/roc_data_7_cv9.png"
              caption="This figure shows the ROC curve for the Species relative abundance table (data_7) when using 10-fold cross-validation."
              class="figure"
              img-class="figure-img img-fluid rounded mx-auto d-block" 
              height="75%"
              width="75%">}}
{{% /tab %}}
{{% /tabpane %}}

**cv.auc.pdf** files shows an aggregation of the above `roc_data_*_classifier.pdf` plots. There is *one page per input data* and the plots shows the AUC against the K-fold CV.

In this plot, we observe that when using Species (data_7) abundances as the feature table, the classifier accuracy ranges between 0.7 to 0.8 with a peak performance occurring at cv_8 (8-fold cross validation). In general, when there is more data for training (higher cv) there is better performance (higher AUC).

{{< figure src="/images/tutorials/classifer/random-forest-HMP/cv_auc_data_7.png"
          caption="This plot compares accuracy (AUC) for Random Forest classifiers trained on the Species abundance tables (input 7 == page 7). The AUC values correspond to the area under the curve of the above `roc_data_7_classifier.pdf` file. In this plot, we observe that when using Species (data_7) abundances as the feature table, the classifier accuracy ranges between 0.7 to 0.8 with a peak performance occurring at cv_8 (8-fold cross validation). In general, when there is more data for training (higher cv) there is better performance (higher AUC)."
          class="figure"
          img-class="figure-img img-fluid rounded mx-auto d-block"
          height="55%"
          width="55%" >}}


**roc_classif.randomForest_dataset.pdf** is summary PDF with one page per K-fold CV. Each plot shows the ROC curves for each *input data* for a specified *K-fold CV*. Below shows the performance for classifiers trained using 8-fold CV (page 8) across the 8 input tables (Kingdom to Strain) plus the final data table that combine all the eight tables together as one big dataset giving the ninth data set. 

This PDF combines the individual plots from the set of `roc_data_*_classifier.pdf` files.

The plot below tells us that when using 8-fold CV for training, the best performing classifier to distinguish between males and females, in this set is `data_7` with an accuracy of 0.787 (or 78.7%). This classifier was trained using Species rank abundance table. Strain level is comparable with accuracy of 0.779, while Kingdom classifiers perform very poorly (accuracy = 0.519) which are pretty much random guesses. There was no improvement to the classify if we combined all the features (data_9) together.
 
{{< figure src="/images/tutorials/classifer/random-forest-HMP/roc_classif.randomForest_dataset_cv8.png"
           caption="The ROC curves of Random Forest classifiers trained using 8-fold cross-validation (cv_8) for input data from Kingdom (data_1) to Strain (data_8) and the combined dataset which merges all input data as one table (data_9). When using 8-fold CV the best performing classifier has accuracy of 0.787 using the Species input data (data_7). See text description for further interpretation."
           class="figure"
           img-class="figure-img img-fluid rounded mx-auto d-block" 
           height="75%"
           width="75%" >}}
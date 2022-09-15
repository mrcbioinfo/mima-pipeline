---
title: Classification with Random Forest
---

# Classification with Random Forest

This tutorial steps through the classification module using Random Forest.

The module trains a random forest classifier given an input data of feature relative abundances. The input table consists of features (taxa, genes, pathways) as rows and samples as columns. The cells denote the relative abundance of feature *i* for sample *j*.

Samples belong to mutually exclusive groups defined in the `metadata` and the goal is to classify the samples based on these groups.

## Tutorial data

The **mock data** data sets from Tourlousse *et.al.* 2022 which we used in the [Data processing with Singularity](tutorial-with-singularity) and visualisation tutorial is very clean and does not make for an interesting classification problem. 

We will use a real data from human stool microbiome, from the Human Microbiome Project V1. The data consists n=241 total samples, of which 118 are from females and 123 are from males. The taxonomy have been annotated using the Metaphlan2 process. We will train the random forest classifier to distinguish between sex.

# Getting started

1. First [Install MIMA pipeline with Singularity]({{site.baseurl}}/docs/installation)
  - Remember to start an *interactive* PBS job
  - Set the `SANDBOX` environment variable
  - If needed, [set the `SINGULARITY_BIND` environment variable](tutorial-with-singularity#pbs-configuration-files)

2. Download example data set: [HMPv1-stool-samples.tar.gz](https://github.com/xychua/test-gitpages/raw/master/examples/HMPv1-stool-samples.gz) or use the `wget` command below
3. Extract the files using the following commands
4. Check directory structure

```
$ wget https://github.com/xychua/test-gitpages/raw/master/examples/HMPv1-stool-samples.tar.gz
$ tar -xf HMPv1-stool-samples.tar.gz
$ tree HMPv1-stool-samples
```

```
HMPv1-stool-samples
├── hmp1-stool-visit-1.features.tsv
└── hmp1-stool-visit-1.metadata.tsv
```


# Random Forest classifier: Stool-gender HMP

- First create an output directory
- Enter the following command, all on one line without the backslash `\`
  - the backslash (`\`) is for readability and tells the terminal the command is not yet finished

```
$ cd HMPv1-stool-samples
$ mkdir output
$ singularity run --app mima-classifier-RF $SANDBOX \
-i hmp1-stool-visit-1.features.tsv \
-m hmp1-stool-visit-1.metadata.tsv \
-c Gender \
-o output
```

**Expected output**

```
$ tree . 
```

```
.
├── hmp1-stool-visit-1.features.tsv
├── hmp1-stool-visit-1.metadata.tsv
└── output
    ├── cv_auc.png
    ├── roc_classif.randomForest_dataset.png
    ├── roc_data_1_classifier.png
    ├── roc_data_1.png
    └── socket_cluster_log.txt
```

- there should be 4 PDF files and 1 log file
- the PDF files are figures which are explained in the table below

<table class="table table-borderless">
<tr>
  <td>
    <p>cv_auc.pdf</p> 
    <img src="{{site.baseurl}}/assets/img/tutorials/classifer/random-forest-HMP/cv_auc.png" height="50%"/>
    <p>For each input table, cv_auc.pdf has the area under the curve (AUC) values against number of folds (3 to 10 folds)</p>
  </td>
  <td>
    <p>roc_classif.randomForest_dataset.pdf</p> 
    <img src="{{site.baseurl}}/assets/img/tutorials/classifer/random-forest-HMP/roc_classif.randomForest_dataset.png" height="40%"/>
    <p>Has the AUC plot for all the data table input in a single figure</p>
  </td>
</tr>
<tr>
  <td>
    <p>roc_data_1_classifier.pdf</p> 
    <img src="{{site.baseurl}}/assets/img/tutorials/classifer/random-forest-HMP/roc_data_1_classifier.png" height="50%"/>
    <p>roc_data_1_classifier.pdf is for data table 1, plot roc by combining all the classifiers into one figure</p>
  </td>
  <td>
    <p>roc_data_1.pdf</p> 
    <img src="{{site.baseurl}}/assets/img/tutorials/classifer/random-forest-HMP/roc_data_1.png" height="40%"/>
    <p>roc_data_1.pdf has the confidence intervals</p>
  </td>
</tr>
s</table>
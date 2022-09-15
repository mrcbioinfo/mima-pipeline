---
title: classification_random_forest.R
---

This script runs Random Forest classification training and testing using 

***


# Basic usage

```
$ singularity run --app mima-classifier-RF $SANDBOX \
-i <path/to/input/file> \
-m <path/to/metadata> \
-c column \
-o <path/to/output>
```

* see below for parameter explanations
* **note** the output directory needs to be created first, see [Classification with Random Forest](../tutorials/classification-random-forest) tutorial

***

# Full help

```
Usage: /opt/mima/scripts/classifier/random_forest/classifier_pipeline.R [options]


Options:
        -i INPUT, --input=INPUT
                input file: a list of tab seperated feature tables
                with rows (first row is header) and columns (first column is
                sample ID) indicate features and samples, respectively

        -m METADATA, --metadata=METADATA
                input file of study metadata where the first row is
                header and the first column is assumed to be the same ID. The
                metadata is applied to all the feature tables

        -c COLUMN, --column=COLUMN
                column header from the metadata table that contains
                the grouping categories for classfication

        -o OUTPUT, --output=OUTPUT
                output directory

        -h, --help
                Show this help message and exit


```

## Required inputs

All input parameters listed above are required.


## Outputs


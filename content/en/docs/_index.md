---
title: Documentation
linkTitle: Docs
no_list: true
hide_feedback: true
menu:
  main:
    weight: 10
    pre: <i class='fa-solid fa-book'></i>
---

## MIMA Pipeline

The MIMA Pipeline contains two fundamental components and the tutorials are split as such:

1) [Data processing](tutorials/data-processing)
    - checks the quality of shotgun metagenomics sequence reads
    - detects what taxa (phylum to species) are present in the samples and generates taxonomy feature tables
    - detects what genes (families and pathways) are present in the samples and generates function feature tables
  
2) [Analytics](tutorials/analytics)
   - core biodiversity analysis (e.g., alpha-diversity, beta-diversity and differential abundance analyses) and comparisons between groups
   - classification analysis

![pipeline-schema](/images/mima_pipeline.svg)


## Getting started

If you are new to shotgun metagenomics processing, or have not heard of Apptainer/Singularity before, then start with ["What are Container images?"](what-is-container.md)
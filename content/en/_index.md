---
title: MRC Shotgun metagenomics Pipeline (MIMA)
type: docs
no_list: true
hide_feedback: true
params:
  ui:
    breadcrumb_disable: true
    taxonomy_breadcrumb_disable: true
---

## MIMA Pipeline

The MIMA Pipeline contains two fundamental components and the tutorials are split as such:

1) [Data processing]({{< ref "data-processing" >}})
    - checks the quality of shotgun metagenomics sequence reads
    - detects what taxa (phylum to species) are present in the samples and generates taxonomy feature tables
    - detects what genes (families and pathways) are present in the samples and generates function feature tables
  
2) [Analytics]({{< ref "analytics" >}})
   - core biodiversity analysis (e.g., alpha-diversity, beta-diversity and differential abundance analyses) and comparisons between groups
   - classification analysis

![pipeline-schema](images/mima_pipeline.svg)


## Getting started

If you are new to shotgun metagenomics processing, or have not heard of Apptainer/Singularity before, then start with ["What are Container images?"]({{< ref "what-is-container.md" >}})
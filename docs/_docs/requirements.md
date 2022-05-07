---
title: Requirements
---

# Reference databases

Many steps in the pipeline require access to reference databases. These reference databases can be very big and often are already downloaded by the administators of the high-performance computing clusters. As such they are not included in the Singularity build. To run the pipeline you will need to know where the required reference databases are stored in order to provide the paths as a parameter setting.

## QC - decontamination

| Tool | Description |
|------|-------------|
| Minimap2 | requires reference genome |


## Taxonomy profiling


| Tool | Description |
|------|-------------|
| Kraken2 | requires reference database |


## Functional profiling


| Tool | Description |
|------|-------------|
| HUMAnN | requires reference databases |
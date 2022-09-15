---
layout: page
title: Documentation
permalink: /
---

# MIMA shotgun metagenomics pipeline

Welcome to the {{ site.title }} Documentation pages! 

The MRC Metagenomics pipeline consists of four modules covered in 2 tutorials:

[Data processing](docs/tutorials/tutorial-with-singularity) tutorial which covers 1 to 3
1. Quality checking module (entry point)
2. Taxonomy profiling module - can run in parallel with [3]
3. Functional profiling module - can run in parallel with [2]
4. [Core diversity analysis and visualisation](docs/tutorials/core-diversity-analysis-visualisation) tutorial - run after steps [2] or [3]

This repository contains helper scripts for generating PBS job scripts to process multiple samples.
Each module will generate outputs in a predefined directory structure and some filenames will be hard-coded. These are used for later modules. 

Here you can quickly jump to a particular page.

 - [Installation](docs/installation)
 - [Requirements](docs/requirements)
 - [Tutorials](docs/tutorials)
 - [User documentation](docs/usage)


<!-- Would you like to see another question type, or another kind of extra? Please [open an issue]({{ site.repo }}/issues/new). -->


<!--
<div class="section-index">
    <hr class="panel-line">
    {% for post in site.docs  %}        
    <div class="entry">
    <h5><a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a></h5>
    <p>{{ post.description }}</p>
    </div>{% endfor %}
</div>
-->
---
layout: page
title: Documentation
permalink: /
---

# Documentation

Welcome to the {{ site.title }} Documentation pages! 

The MRC Metagenomics pipeline consists of four modules:

1. Quality checking module (entry point)
2. Taxonomy profiling module - can run in parallel with [3]
3. Functional profiling module - can run in parallel with [2]
4. Data visualisation and analysis (core) module - run after steps [2] or [3]

This repository contains helper scripts for generating PBS job scripts to process multiple samples.
Each module will generate outputs in a predefined directory structure and some filenames will be hard-coded. These are used for later modules. 

!!**CAUTION**: Please beware that changing the output file names or paths might not make subsequent scripts in the pipeline work. We are in the process of making this more robust and configurable.

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
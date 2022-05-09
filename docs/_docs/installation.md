---
title: Installation
---

# Installation

There are two options for using this pipeline

1. Singularity container
2. Independently without Singularity

Both options require access to external reference databases (see [Requirements]( {{ site.baseurl}}/docs/requirements ))

---

## Option 1) Singularity container

* All tools required by the pipeline are encapsulated into a Singularity container, the image named (IMAGE_NAME)
* You will also need to download the reference databases that are required by the third party tools (see [Requirements]({{ site.baseurl }}/docs/requirements))

---

## Option 2) Setting up the MIMA environent

In order to use the MIMA pipeline **without Singularity**, you will need to install the following

1. Install Miniconda [guide](https://docs.conda.io/en/latest/miniconda.html#installing)
2. Download [`mima.tar.gz`]() from Release
3. Untar the file:  `tar -xf mima.tar.gz`
4. There are two directories in the file: `requirements/` and `scripts/`

    ```
    mima.tar.gz
    ├── requirements/
    │   ├── mima-conda-env.yml
    │   ├── Rpackages.R
    │   └── test_Rpackages.R
    └── scripts/
        ├── func_profiling.py
        ├── qc_module.py
        ├── qc_report.py
        ├── taxa_module.py
        ├── utils/
        └── visualisation
            ├── ...
            ├── taxa_plot_v2.pl
            └── visualisation.py

    ```

5. Create the MIMA environment, in the terminal where you downloaded the `mima-conda-env.yml` file, type

    ```
    $ conda env create -f requirements/mima-conda-env.yml
    ```

6. Test the installation:

    ```
    $ conda activate mima
    ```

7. You can now start using the MIMA scripts from within the `scripts/` folder

    ```
    $ cd scripts
    $ python3 qc_module.py --help
    ```

install.packages(c('argparse',
                   'futile.logger',
                   'tidyverse',
                   'funrar',
                   'data.table',
                   'dunn.test',
                   'reshape2',
                   'vegan',
                   'ape',
                   'ggfortify',
                   'ggpubr',
                   'otuSummary',
                   'devtools',
                   'BiocManager'))
BiocManager::install('EnhancedVolcano', ask=F)
devtools::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")

install.packages(c('argparse',
                   'devtools',                   
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
                   'BiocManager'))
BiocManager::install('EnhancedVolcano', ask=F)
devtools::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")

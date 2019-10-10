#!/bin/bash

# Add GPG key and R repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt update


# Install R
sudo apt install -y r-base


# Install Linux dependencies
sudo apt install -y libssl-dev
sudo apt install -y libcurl4-openssl-dev
sudo apt install -y libxml2-dev
sudo apt install -y texlive-full
sudo apt install -y nginx
sudo apt install -y util-linux
sudo apt install -y openjdk-8-jdk
sudo apt install -y openjdk-11-jdk
sudo apt install -y libglpk-dev
sudo apt install -y coinor-libsymphony-dev coinor-libsymphony-doc


# Configure Java
sudo update-java-alternatives --set java-1.8.0-openjdk-amd64

# Install RStudio Server
sudo apt install -y gdebi-core
wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb
sudo dpkg -i rstudio-server-1.2.1335-amd64.deb


# Create RStudio Server config file
sudo bash -c "echo -e '
[*]
max-memory-mb = 2048
session-timeout-minutes=60
session-timeout-kill-hours=4
' >> /etc/rstudio/profiles"


# Restarts RStudio Server
sudo rstudio-server restart


# Install Anaconda
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
sudo bash Anaconda3-2019.03-Linux-x86_64.sh -b -p /opt/anaconda/201903/


# Update PATH variable for Anaconda
sudo su -

echo 'export PATH="/opt/anaconda/201903/bin:$PATH"' >> /etc/skel/.bashrc
echo 'export PATH="/opt/anaconda/201903/bin:$PATH"' >> /root/.bashrc

echo 'export RETICULATE_PYTHON="/opt/anaconda/201903/bin"' >> /etc/skel/.bashrc
echo 'export RETICULATE_PYTHON="/opt/anaconda/201903/bin"' >> /root/.bashrc

echo '
local({
  old_path <- Sys.getenv("PATH")
  Sys.setenv(PATH = paste(old_path, "/opt/anaconda/201903/bin", sep = ":"))
})
' >> /usr/lib/R/etc/Rprofile.site
exit


# Update Anaconda and install SciPy
sudo su -
conda update conda -y
conda update anaconda -y
conda create -n venv pip python=3.7 -y
conda install --name venv scipy -y
exit


# Install R Packages
sudo R -e "install.packages(c('abind','anytime','ape','assertthat','backports','base64enc','BH','bindr','bindrcpp','bitops','brew','broom','callr','car','carData','caTools','cellranger','cli','clipr','cloudml','cmprsk','colorspace','commonmark','config','cowplot','crayon','crosstalk','curl','data.table','DBI','dbplot','dbplyr','Deriv','desc','devtools','digest','dplyr','ellipsis','evaluate','exactRankTests','fansi','forcats','forecast','forge','fracdiff','future','generics','geosphere','GGally','ggdendro','ggfortify','ggnetwork','ggplot2','ggpubr','ggrepel','ggsci','ggsignif','ggthemes','git2r','glue','gridExtra','gtable','haven','hexbin','highr','hms','htmltools','htmlwidgets','httpuv','httr','igraph','jsonlite','keras','km.ci','KMsurv','knitr','labeling','later','lazyeval','lme4','lmtest','lubridate','magrittr','maptools','markdown','MatrixModels','maxstat','memoise','mime','minqa','modelr','munsell','mvtnorm','neuralnet','NeuralNetTools','nloptr','nycflights13','ompr','ompr.roi','openssl','openxlsx','packrat','parallel','pbkrtest','pillar','pkgbuild','pkgconfig','pkgload','PKI','plogr','plotly','plyr','polynom','prettyunits','processx','profvis','progress','promises','pryr','ps','purrr','quadprog','quantmod','QuantPsyc','quantreg','r2d3','R6','randomForest','RApiDatetime','rappdirs','RColorBrewer','Rcpp','RcppArmadillo','RcppEigen','RCurl','readr','readxl','rematch','reprex','reshape','reshape2','reticulate','rgdal','rgeos','rio','RJSONIO','rlang','rmarkdown','ROI','ROI.plugin.glpk','ROI.plugin.symphony','roxygen2','rpart','rpart.plot','rprojroot','rsconnect','rstudioapi','rvest','scales','selectr','shiny','sourcetools','sp','sparklyr','SparseM','stringi','stringr','survival','survminer','survMisc','tensorflow','tfdatasets','tfestimators','tfruns','tibble','tidyr','tidyselect','tidyverse','timeDate','tinytex','tseries','tsibble','TTR','urca','utf8','vcd','viridis','viridisLite','whisker','withr','xfun','xml2','xtable','xts','yaml','zeallot','zip','zoo'), lib='/usr/lib/R/site-library')" 1>&2


# Install TensorFlow
sudo R -e "tensorflow::install_tensorflow(method = 'conda', conda = 'auto', envname = 'venv')" 1>&2


# Configure SSL for RStudio
sudo mkdir /etc/nginx/ssl
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=UK/ST=Denial/O=Dis/CN=staines-r-training-july-2019.uksouth.cloudapp.azure.com"
sudo chmod 600 /etc/nginx/ssl/nginx.key
sudo systemctl restart nginx
sudo rstudio-server restart


# Format the 1TB disk (/dev/sdc1) for /home
echo 'start=2048, type=83' | sudo sfdisk /dev/sdc
sudo partprobe
sudo mkfs.ext4 -F /dev/sdc1
sudo mount /dev/sdc1 /home
sudo su -
UUID_sdc1=$(sudo blkid | grep '^/dev/sdc1:' | grep -oE ' UUID="([a-zA-Z0-9-]*)" ' | grep -oE '\".*?\"' | grep -oE '[a-zA-Z0-9-]*')
echo UUID=$UUID_sdc1   /home   ext4   defaults,nofail   1   2 >> /etc/fstab
exit
sudo fstrim /home


# Format the 512GB disk (/dev/sdd1) for /tmp
echo 'start=2048, type=83' | sudo sfdisk /dev/sdd
sudo partprobe
sudo mkfs.ext4 -F /dev/sdd1
sudo mount /dev/sdd1 /tmp
sudo su -
UUID_sdd1=$(sudo blkid | grep '^/dev/sdd1:' | grep -oE ' UUID="([a-zA-Z0-9-]*)" ' | grep -oE '\".*?\"' | grep -oE '[a-zA-Z0-9-]*')
echo UUID=$UUID_sdd1   /tmp   ext4   defaults,nofail   1   2 >> /etc/fstab
exit
sudo fstrim /tmp


# Change permission for /tmp
sudo chmod -R 1777 /tmp


# Install Apache Spark
wget http://apache.mirror.anlx.net/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
tar -xvf spark-2.4.4-bin-hadoop2.7.tgz
sudo mv spark-2.4.4-bin-hadoop2.7 /usr/local/
sudo ln -s /usr/local/spark-2.4.4-bin-hadoop2.7/ /usr/local/spark
cd /usr/local/spark

sudo su -
echo 'export SPARK_HOME=/usr/local/spark' >> /root/.bashrc
echo 'export export SPARK_HOME=/usr/local/spark' >> /etc/skel/.bashrc
echo '
local({
  Sys.setenv(SPARK_HOME = "/usr/local/spark")
})
' >> /usr/lib/R/etc/Rprofile.site
exit

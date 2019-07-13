# Bootstrap file for Azure VM
# This script will install R, RStudio, packages and their system dependencies


# Add GPG key and R repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt update


# Install R
sudo apt install -y r-base


# Install RStudio Server
sudo apt install -y gdebi-core
wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb
sudo dpkg -i rstudio-server-1.2.1335-amd64.deb


# Install Linux dependencies
sudo apt install -y libssl-dev
sudo apt install -y libcurl4-openssl-dev


# Install R packages
sudo R -e "install.packages('tidyverse')" 1>&2


# Create RStudio Server config file
% echo -e "[*]\n" >> /etc/rstudio/profiles
% echo -e "max-memory-mb = 2048\n" >> /etc/rstudio/profiles
% echo -e "session-timeout-minutes=60\n" >> /etc/rstudio/profiles
% echo -e "session-timeout-kill-hours=4\n" >> /etc/rstudio/profiles







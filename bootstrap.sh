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


# Install R packages
sudo R -e "install.packages('reticulate', lib='/usr/lib/R/site-library')" 1>&2


# Install RStudio Server
sudo apt install -y gdebi-core
wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb
sudo dpkg -i rstudio-server-1.2.1335-amd64.deb


# Create RStudio Server config file
sudo bash -c "echo -e '[*]' >> /etc/rstudio/profiles"
sudo bash -c "echo -e 'max-memory-mb = 2048' >> /etc/rstudio/profiles"
sudo bash -c "echo -e 'session-timeout-minutes=60' >> /etc/rstudio/profiles"
sudo bash -c "echo -e 'session-timeout-kill-hours=4' >> /etc/rstudio/profiles"


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


# Install TensorFlow (R & Python)
sudo R -e "install.packages('tensorflow', lib='/usr/lib/R/site-library')" 1>&2
sudo R -e "tensorflow::install_tensorflow(method = 'conda', conda = 'auto', envname = 'venv')" 1>&2

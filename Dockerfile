# This docker file will install and deploy Jupyter Notebooks for analysis
FROM centos:7.6.1810 AS base
LABEL maintainer="carteaga@archerdx.com"

# Reccomended update by centos to address potential security concerns and installation of various development tools
RUN yum -y update && yum clean all 
COPY /yum-requirements.txt /yum-reqs.txt
RUN yum install -v -y $(cat yum-reqs.txt)  && yum clean all
RUN yum -y groupinstall "Development Tools" && yum clean all
RUN yum-builddep -y python

# Installing Python 3
FROM base AS languages
RUN yum-config-manager --enable centos-sclo-rh-testing
RUN yum -y install rh-python36

# Installing R 3.3.3 and packages
RUN cd /usr/src \
    && wget https://cran.r-project.org/src/base/R-3/R-3.3.3.tar.gz \
    && tar xzf R-3.3.3.tar.gz \
    && cd R-3.3.3 \
    && ./configure --with-x=no \
    && make \
    && make install

RUN R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')" \
    && R -e "install.packages('dplyr', repos = 'http://cran.us.r-project.org')" \
    && R -e "install.packages('scales', repos = 'http://cran.us.r-project.org')" \
    && R -e "require('grid')" \
    && R -e "install.packages(c('repr', 'IRdisplay', 'crayon', 'pbdZMQ', 'devtools'), repos='http://cran.us.r-project.org')" \
    && R -e "update.packages(repos = 'http://cran.us.r-project.org')"

# Installing and configuring Jupyter Notebooks
FROM languages AS py_configs

RUN yum -y install python-pip
RUN pip install backports.ssl_match_hostname==3.4.0.2
RUN pip install --upgrade pip
RUN pip install seaborn==0.9.0 --ignore-installed pyparsing 
RUN pip install matplotlib==2.2.2 --ignore-installed pyparsing
COPY /requirements.txt reqs.txt
RUN pip install -r reqs.txt
RUN jupyter contrib nbextension install --symlink
RUN jupyter-notebook --generate-config
RUN sed -i.bak -e "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/" ~/.jupyter/jupyter_notebook_config.py
RUN R -e "install.packages('IRkernel', repos = 'http://cran.us.r-project.org')" && R -e "IRkernel::installspec(user = FALSE)"

# Enable scl for py3, add user, install py3 kernel and set entrypoint
FROM py_configs AS jup

RUN echo "source scl_source enable rh-python36" >> /etc/bashrc
ENV PATH=$PATH:/opt/rh/rh-python36/root/usr/bin/ 

RUN useradd -m archer
USER archer
RUN python3 -m pip -v install ipykernel --user  && python3 -m ipykernel install --user
RUN mkdir ~/notebooks 
ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--notebook-dir=~/notebooks"]

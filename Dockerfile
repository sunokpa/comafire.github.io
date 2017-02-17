FROM ubuntu:16.04
MAINTAINER comafire <comafire@gmail.com>

# Bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
apt-utils \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Common
RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential vim curl wget git cmake bzip2 sudo locales unzip net-tools \
libssl-dev

# System Python 
RUN apt-get update && apt-get install -y --no-install-recommends \
software-properties-common libjpeg-dev libpng-dev ncurses-dev imagemagick \
libgraphicsmagick1-dev libzmq3-dev gfortran gnuplot gnuplot-x11 libsdl2-dev \
python python-dev python-pip python-virtualenv python-software-properties 
RUN pip install --upgrade pip

# pyenv
RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
RUN pyenv update
RUN echo 'export PATH="~/.pyenv/bin:$PATH"' >> ~/.bash_profile 
RUN echo 'eval "$(pyenv init -)"' >> ~/.bash_profile 
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
RUN echo 'source /usr/local/opt/autoenv/activate.sh' >> ~/.bash_profile

# Python-Jupyter
RUN pip3 install setuptools
RUN pip3 install jupyter

# Python-Deps
RUN apt-get update && apt-get install -y --no-install-recommends \
libfreetype6-dev libxft-dev
RUN pip3 install matplotlib pandas pandas-datareader quandl 
RUN pip3 install numpy scipy sklearn
RUN pip3 install azure-storage

# Tensorflow
RUN pip3 install --upgrade tensorflow

# Julia
RUN add-apt-repository ppa:staticfloat/juliareleases
RUN add-apt-repository ppa:staticfloat/julia-deps
RUN apt-get update && apt-get install -y --no-install-recommends \
julia
 
RUN julia -e 'Pkg.add("IJulia")'

# JAVA
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=121
ARG JAVA_BUILD_NUMBER=33
ENV JAVA_HOME /usr/local/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -sL --retry 3 --insecure \
--header "Cookie: oraclelicense=accept-securebackup-cookie;" \
"http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/server-jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
| gunzip \
| tar x -C /usr/local/ \
&& ln -s $JAVA_HOME /usr/local/java \
&& rm -rf $JAVA_HOME/man

# SPARK
ENV SPARK_VERSION 2.1.0
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/local/spark-${SPARK_VERSION}

ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
"http://d3kbcqa49mib13.cloudfront.net/${SPARK_PACKAGE}.tgz" \
| gunzip \
| tar x -C /usr/local \
&& mv /usr/local/$SPARK_PACKAGE $SPARK_HOME \
&& ln -s $SPARK_HOME /usr/local/spark \
&& chown -R root:root $SPARK_HOME
ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH
ENV PYTHONPATH $SPARK_HOME/python/lib/py4j-0.10.3-src.zip:$PYTHONPATH

# Scala
RUN apt-get update && apt-get install -y --no-install-recommends \
scala
RUN pip3 install py4j

# toree
#RUN pip3 install --pre toree
# for spark 2.1.0, scala 2.11
RUN pip3 install -i https://pypi.anaconda.org/hyoon/simple toree
RUN jupyter toree install

# Env
VOLUME /root/volume

EXPOSE 8888

CMD cd $HOME && cd volume && jupyter notebook --ip='*' --no-browser
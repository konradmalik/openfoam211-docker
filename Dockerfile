FROM ubuntu:12.04

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV APT_INSTALL="apt-get update && apt-get install -y --no-install-recommends --fix-missing"
ENV PIP_INSTALL="python -m pip --no-cache-dir install --upgrade"

# install openfoam and needed tools
RUN eval $APT_INSTALL \
    wget apt-utils \
    && sh -c "wget -O - http://dl.openfoam.org/gpg.key | apt-key add - && echo deb http://dl.openfoam.org/ubuntu precise main > /etc/apt/sources.list.d/openfoam.list" \
    && eval $APT_INSTALL \
        openfoam211 paraviewopenfoam3120 \
        nano sudo git mc gnuplot tmux make cmake vim

# python
# this is max what can be done on 12.04
# also this deadsnakes repo is archived, but the newer one does not support 12.04
ENV PYTHON_COMPAT_VERSION=3.5
RUN eval $APT_INSTALL \
        software-properties-common python-software-properties && \
    add-apt-repository ppa:fkrull/deadsnakes && \
    eval $APT_INSTALL \
        python${PYTHON_COMPAT_VERSION} \
        python${PYTHON_COMPAT_VERSION}-dev \
        python3-distutils-extra \
        libblas-dev liblapack-dev libatlas-base-dev gfortran \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python${PYTHON_COMPAT_VERSION} ~/get-pip.py && \
    ln -s /usr/bin/python${PYTHON_COMPAT_VERSION} /usr/local/bin/python3 && \
    ln -s /usr/bin/python${PYTHON_COMPAT_VERSION} /usr/local/bin/python

# pyfoam
RUN $PIP_INSTALL PyFoam==2020.5

# config and cleanup
RUN ldconfig && \
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

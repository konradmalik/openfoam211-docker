FROM ubuntu:16.04
# 18.04 does not work as it uses gcc 4.8 and it fails to build openfoam 211
# even when following instructions on wiki for 18.04

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV APT_INSTALL="apt-get update && apt-get install -y --no-install-recommends --fix-missing"
ENV PIP_INSTALL="python -m pip --no-cache-dir install --upgrade"

# use bash in all commands
SHELL ["/bin/bash", "-c"]

# compile openfoam and install tools
# prepare apps
RUN eval $APT_INSTALL \
    build-essential binutils-dev flex bison zlib1g-dev qt4-dev-tools libqt4-dev libqtwebkit-dev gnuplot \
    libreadline-dev libncurses-dev libxt-dev libopenmpi-dev openmpi-bin libboost-system-dev libboost-thread-dev libgmp-dev \
    libmpfr-dev python python-dev libcgal-dev gcc-4.7 g++-4.7 libglu1-mesa-dev libqt4-opengl-dev \
    # my addition
    ca-certificates wget make cmake vim nano sudo git mc

# prepare of21x
RUN mkdir -p $HOME/OpenFOAM \
    && cd $HOME/OpenFOAM \
    && git clone https://github.com/OpenFOAM/OpenFOAM-2.1.x.git \
    && git clone https://github.com/OpenFOAM/ThirdParty-2.1.x.git \
    && cd ThirdParty-2.1.x \
    && mkdir download \
    && wget -P download http://www.paraview.org/files/v3.12/ParaView-3.12.0.tar.gz \
    && wget -P download https://gforge.inria.fr/frs/download.php/28043/scotch_5.1.11.tar.gz \
    && tar -xzf download/ParaView-3.12.0.tar.gz \
    && tar -xzf download/scotch_5.1.11.tar.gz \
    && cd .. \
    && sed -i -e 's/gcc/gcc-4.7/' OpenFOAM-2.1.x/wmake/rules/linux64Gcc47/c \
    && sed -i -e 's/g++/g++-4.7/' OpenFOAM-2.1.x/wmake/rules/linux64Gcc47/c++ \
    && echo "export WM_CC='gcc-4.7'" >> OpenFOAM-2.1.x/etc/bashrc \
    && echo "export WM_CXX='g++-4.7'" >> OpenFOAM-2.1.x/etc/bashrc \
    && source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && echo "source \$HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc $FOAM_SETTINGS" >> $HOME/.bashrc \
    && cd $WM_PROJECT_DIR \
    && find src applications -name "*.L" -type f | xargs sed -i -e 's=\(YY\_FLEX\_SUBMINOR\_VERSION\)=YY_FLEX_MINOR_VERSION < 6 \&\& \1='

# build openfoam
RUN source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && cd $WM_PROJECT_DIR \
    && ./Allwmake \
    && ./Allwmake

# prepare 3rd party
RUN source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && cd $WM_THIRD_PARTY_DIR \
    && export QT_SELECT=qt4 \
    && wget https://cmake.org/files/v2.8/cmake-2.8.12.1.tar.gz -P download \
    && tar -xf download/cmake-2.8.12.1.tar.gz \
    && sed -i -e 's=/bin/sh=/bin/bash=' makeCmake \
    && ./makeCmake cmake-2.8.12.1 \
    && sed -i -e 's=cmake-2\.8\.4=cmake-2.8.12.1 cmake-2.8.4=' $WM_PROJECT_DIR/etc/config/paraview.sh \
    && source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && sed -i -e 's=//#define GLX_GLXEXT_LEGACY=#define GLX_GLXEXT_LEGACY=' \
      ParaView-3.12.0/VTK/Rendering/vtkXOpenGLRenderWindow.cxx \
    && sed -i -e 's/ClearAndSelect = Clear | Select/ClearAndSelect = static_cast<int>(Clear) | static_cast<int>(Select)/' \
      ParaView-3.12.0/Qt/Core/pqServerManagerSelectionModel.h \
    && sed -i -e 's/\(export CXX.*$\)/\1\n[ -n "$WM_CC" ] \&\& export CC="$WM_CC"/' makeParaView

# build paraview
RUN source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && cd $WM_THIRD_PARTY_DIR \
    && export QT_SELECT=qt4 \
    && ./makeParaView

# build utilities
RUN source $HOME/OpenFOAM/OpenFOAM-2.1.x/etc/bashrc WM_NCOMPPROCS=4 WM_MPLIB=SYSTEMOPENMPI WM_COMPILER=Gcc47 \
    && cd $FOAM_UTILITIES/postProcessing/graphics/PV3Readers \
    && ./Allwclean \
    && ./Allwmake

# python
ENV PYTHON_COMPAT_VERSION=3.6
RUN eval $APT_INSTALL \
        software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa && \
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

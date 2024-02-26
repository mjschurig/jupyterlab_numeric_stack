# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/julia-notebook

FROM $BASE_CONTAINER

# Copyright 2021-2023 The MathWorks, Inc.
# Builds Docker image on Ubuntu 22.04 with:
# 1. MATLAB - Using MPM
# 2. MATLAB Integration for Jupyter
# on a base image of jupyter/base-notebook:python-3.xx

# NOTE: This Dockerfile can only build MATLAB releases which have system dependency lists available for 22.04 on container-images/matlab-deps.
#       For complete listing, see https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-deps

## Sample Build Command:
# docker build --build-arg MATLAB_RELEASE=r2023b \
#              --build-arg PYTHON_VERSION=3.11 \
#              --build-arg MATLAB_PRODUCT_LIST="MATLAB Deep_Learning_Toolbox Symbolic_Math_Toolbox"\
#              --build-arg LICENSE_SERVER=12345@hostname.com \
#              -t my_matlab_image_name .

## Support for MATLAB Engine for Python by Release
# For more information, see: https://mathworks.com/support/requirements/python-compatibility.html
# MATLAB RELEASE | Supported Python Versions  | OS supported by matlab-deps|Supported by this Dockerfile     |
# ---------------| (MATLAB Engine for Python) |----------------------------|---------------------------------|
# ---------------|----------------------------|----------------------------|---------------------------------|
#     R2023b     |  3.9, 3.10, 3.11           | Ubuntu 22.04 & 20.04       |  Yes                            |
#     R2023a     |  3.8, 3.9, 3.10            | Ubuntu 22.04 & 20.04       |  Yes                            |
#     R2022b     |  3.8, 3.9, 3.10            | Ubuntu 22.04 & 20.04       |  Yes                            |
#     R2022a     |  3.8, 3.9                  | Ubuntu 20.04               |  No, use ubuntu20.04/Dockerfile |
#     R2021b     |  3.8, 3.9                  | Ubuntu 20.04               |  No, use ubuntu20.04/Dockerfile |
#     R2021a     |  3.8                       | Ubuntu 20.04               |  No, use ubuntu20.04/Dockerfile |
#     R2020b     |  3.8                       | Ubuntu 20.04               |  No, use ubuntu20.04/Dockerfile |

# Specify release of MATLAB to build. (use lowercase, default is r2023b)
ARG MATLAB_RELEASE=r2023b

# Specify version of python thats used by jupyter/base-notebbok
# Using python 3.10 as default as it is the latest version compatible with MATLAB Engine for Python in R2023b, R2023a & R2022b
ARG PYTHON_VERSION=3.10

# Specify the list of products to install into MATLAB, 
ARG MATLAB_PRODUCT_LIST="MATLAB Symbolic_Math_Toolbox"

# Optional Network License Server information
ARG LICENSE_SERVER

# If LICENSE_SERVER is provided then SHOULD_USE_LICENSE_SERVER will be set to "_use_lm"
ARG SHOULD_USE_LICENSE_SERVER=${LICENSE_SERVER:+"_with_lm"}

# Default DDUX information
ARG MW_CONTEXT_TAGS=MATLAB_PROXY:JUPYTER:MPM:V1

# Switch to root user
USER root
ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"

## Installing Dependencies for Ubuntu 22.04
# For MATLAB : Get base-dependencies.txt from matlab-deps repository on GitHub
# For mpm : wget, unzip, ca-certificates
# For MATLAB Integration for Jupyter : xvfb
# List of MATLAB Dependencies for Ubuntu 22.04 and specified MATLAB_RELEASE
ARG MATLAB_DEPS_REQUIREMENTS_FILE="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE}/ubuntu22.04/base-dependencies.txt"
ARG MATLAB_DEPS_REQUIREMENTS_FILE_NAME="matlab-deps-${MATLAB_RELEASE}-base-dependencies.txt"

# Install dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install --no-install-recommends -y \
    wget \
    unzip \
    ca-certificates \
    xvfb \
    git \
    && wget ${MATLAB_DEPS_REQUIREMENTS_FILE} -O ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} \
    && xargs -a ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} -r apt-get install --no-install-recommends -y \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME}

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=/opt/matlab \
    --products ${MATLAB_PRODUCT_LIST} && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab

# Optional: Install MATLAB Engine for Python, if possible. 
# Note: Failure to install does not stop the build.
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install --no-install-recommends -y  python3-distutils \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && cd /opt/matlab/extern/engines/python \
    && python setup.py install || true

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Install integration
RUN python -m pip install jupyter-matlab-proxy

# Make JupyterLab the default environment
ENV JUPYTER_ENABLE_LAB="yes"

# Install FenicsX
RUN conda create -n fenicsx-env python=3.10
RUN conda install -y -c conda-forge fenics-dolfinx mpich pyvista
RUN conda install -y nb_conda

RUN conda install -y ipykernel


RUN ipython kernel install --user --name=fenicsx-env --display-name "Fenicsx"

# Install deno
USER root

RUN curl -fsSL https://deno.land/install.sh | sudo DENO_INSTALL=/usr/local sh
RUN deno jupyter --unstable --install

USER $NB_USER
WORKDIR /home/${NB_USER}

#Install draw.io
RUN conda create -n drawio
RUN source activate drawio
RUN conda install -c conda-forge ipydrawio
RUN conda install -yc conda-forge ipydrawio-export ipydrawio-mathjax

#Install variable inspector
RUN conda create -n variableinspector
RUN source activate variableinspector
RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install jupyterlab-variableinspector

#Install myst
RUN conda create -n myst
RUN source activate myst
RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install jupyterlab-myst

RUN conda create -n spreadsheet
RUN source activate spreadsheet
RUN conda install conda-forge::jupyterlab-spreadsheet-editor

RUN conda create -n book
RUN source activate book
RUN conda install -c conda-forge jupyter-book

RUN conda create -n plotly
RUN source activate plotly
RUN conda install "jupyterlab>=3" "ipywidgets>=7.6"
RUN conda install -c conda-forge -c plotly jupyter-dash
RUN conda install pandas

RUN conda create -n ipywidgets
RUN source activate ipywidgets
RUN conda install -c conda-forge ipywidgets

RUN conda create -n archive
RUN source activate archive
RUN conda install -c conda-forge jupyter-archive

RUN conda create -n datagrid
RUN source activate datagrid
RUN conda install -c conda-forge ipydatagrid

RUN conda create -n ipygany
RUN source activate ipygany
RUN conda install -c conda-forge ipygany
RUN conda install -c conda-forge vtk
RUN conda install -c conda-forge bqplot

RUN mamba create -n xeus-python
RUN source activate xeus-python
RUN mamba install xeus-python notebook -c conda-forge

RUN mamba create -n voila
RUN source activate voila
RUN mamba install -c conda-forge voila

RUN pip install jupyterlab-tabular-data-editor
RUN pip install yfiles_jupyter_graphs
RUN pip install --upgrade jupyterlab jupyterlab-git

USER $NB_USER
WORKDIR /home/${NB_USER}

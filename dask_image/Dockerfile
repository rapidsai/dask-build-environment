ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniforge-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.8
# RAPIDS_VER isn't used but is part of the matrix so must be included
ARG RAPIDS_VER=21.08

COPY environment.yml rapids.yml
ADD https://raw.githubusercontent.com/dask/dask-image/main/continuous_integration/environment-$PYTHON_VER.yml dask.yml

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba conda-merge \
    && conda-merge rapids.yml dask.yml > dask.yml

# RUN gpuci_mamba_retry env create -n dask_image --file /dask.yml

# # Clean up pkgs to reduce image size and chmod for all users
# RUN chmod -R ugo+w /opt/conda \
#     && conda clean -tipy \
#     && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

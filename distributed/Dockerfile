ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniforge-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.9
ARG NUMPY_VER=1.20.1
ARG RAPIDS_VER=21.08
ARG UCX_PY_VER=0.21

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask/distributed/main/continuous_integration/environment-$PYTHON_VER.yaml /dask.yml

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba conda-merge "conda>=4.14"

RUN cat /rapids.yml \
    | sed -r "s/CUDA_VER/${CUDA_VER}/g" \
    | sed -r "s/RAPIDS_VER/${RAPIDS_VER}/g" \
    | sed -r "s/UCX_PY_VER/${UCX_PY_VER}/g" \
    | sed -r "s/NUMPY_VER/${NUMPY_VER}/g" \
    > /rapids_pinned.yml

# need to unpin pyarrow in python 3.9 environment
RUN cat /dask.yml \
    | sed -r "s/pyarrow=/pyarrow>=/g" \
    > dask_unpinned.yml

RUN conda-merge /rapids_pinned.yml /dask_unpinned.yml > /distributed.yml

RUN gpuci_mamba_retry env create -n dask --file /distributed.yml

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

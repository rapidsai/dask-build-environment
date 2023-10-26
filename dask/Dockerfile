ARG CUDA_VER=11.5.2
ARG LINUX_VER=ubuntu20.04
ARG PYTHON_VER=3.9

FROM rapidsai/miniforge-cuda:cuda$CUDA_VER-base-$LINUX_VER-py$PYTHON_VER

ARG CUDA_VER=11.5.2
ARG PYTHON_VER=3.9
ARG RAPIDS_VER=23.12
ARG UCX_PY_VER=0.35

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask/dask/main/continuous_integration/environment-$PYTHON_VER.yaml /dask.yml

RUN conda config --set ssl_verify false

RUN mamba install -c gpuci gpuci-tools

RUN gpuci_mamba_retry install conda-merge git

RUN cat /rapids.yml \
    | sed -r "s/CUDA_VER/$(echo $CUDA_VER | cut -d. -f1,2)/g" \
    | sed -r "s/RAPIDS_VER/${RAPIDS_VER}/g" \
    | sed -r "s/UCX_PY_VER/${UCX_PY_VER}/g" \
    > /rapids_pinned.yml

# need to unpin numpy & pyarrow in python 3.8 environment
RUN cat /dask.yml \
    | sed -r "s/pyarrow=/pyarrow>=/g" \
    > dask_unpinned.yml

RUN conda-merge /rapids_pinned.yml /dask_unpinned.yml > /dask.yml

RUN gpuci_mamba_retry env create -n dask --file /dask.yml

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

CMD [ "/bin/bash" ]

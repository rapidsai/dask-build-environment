ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniforge-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.8
ARG NUMPY_VER=1.20.1
ARG RAPIDS_VER=21.08
ARG UCX_PY_VER=0.21

ENV RUSTUP_HOME="/opt/rustup"
ENV CARGO_HOME="/opt/cargo"
ADD https://sh.rustup.rs /rustup-init.sh
RUN sh /rustup-init.sh -y --default-toolchain=stable --profile=minimal
ENV PATH="/opt/cargo/bin:${PATH}"

ADD https://raw.githubusercontent.com/dask-contrib/dask-sql/main/continuous_integration/environment-$PYTHON_VER-dev.yaml /dask_sql_environment.yaml

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba

RUN gpuci_mamba_retry env create -n dask_sql --file /dask_sql_environment.yaml

RUN gpuci_mamba_retry install -y -n dask_sql -c rapidsai -c rapidsai-nightly -c nvidia -c conda-forge \
    cudatoolkit=$CUDA_VER \
    cudf=$RAPIDS_VER \
    cuml=$RAPIDS_VER \
    dask-cudf=$RAPIDS_VER \
    dask-cuda=$RAPIDS_VER \
    "numpy>=$NUMPY_VER" \
    "ucx-proc=*=gpu" \
    ucx-py=$UCX_PY_VER \
    "xgboost=*=cuda_*"

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

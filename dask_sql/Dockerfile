ARG CUDA_VER=11.8.0
ARG LINUX_VER=ubuntu20.04
ARG PYTHON_VER=3.9

FROM rapidsai/miniforge-cuda:cuda$CUDA_VER-base-$LINUX_VER-py$PYTHON_VER

ARG CUDA_VER=11.8.0
ARG PYTHON_VER=3.9
ARG RAPIDS_VER=23.12
ARG UCX_PY_VER=0.35

RUN apt-get update \
    && apt-get install -y wget

ENV RUSTUP_HOME="/opt/rustup"
ENV CARGO_HOME="/opt/cargo"
ADD https://sh.rustup.rs /rustup-init.sh
RUN sh /rustup-init.sh -y --default-toolchain=stable --profile=minimal -c rustfmt \
    && chmod -R ugo+rw /opt/cargo /opt/rustup

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask-contrib/dask-sql/main/continuous_integration/environment-$PYTHON_VER.yaml /dask.yml

ADD https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz /tools.tar.gz
RUN tar -xzvf /tools.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tools.tar.gz

RUN conda config --set ssl_verify false

RUN rapids-mamba-retry install conda-merge git 

RUN cat /rapids.yml \
    | sed -r "s/CUDA_VER/$(echo $CUDA_VER | cut -d. -f1,2)/g" \
    | sed -r "s/RAPIDS_VER/${RAPIDS_VER}/g" \
    | sed -r "s/UCX_PY_VER/${UCX_PY_VER}/g" \
    > /rapids_pinned.yml

# unpin problematic CI dependencies
RUN cat /dask.yml \
    | sed -r "s/pyarrow=/pyarrow>=/g" \
    | sed -r "s/uvicorn=/uvicorn>=/g" \
    | sed -r "s/dask=/dask>=/g" \
    | sed -r "s/numpy=/numpy>=/g" \
    | sed -r "s/mlflow=/mlflow>=/g" \
    > /dask_unpinned.yml

RUN conda-merge /rapids_pinned.yml /dask_unpinned.yml > /dask_sql.yml

RUN rapids-mamba-retry env create -n dask_sql --file /dask_sql.yml

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+rw /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+rw /opt/conda

# need a user with access to conda
RUN useradd -r -g conda -u 10000 dask

CMD [ "/bin/bash" ]

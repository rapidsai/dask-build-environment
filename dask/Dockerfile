ARG CUDA_VER=unset
ARG LINUX_VER=unset
ARG PYTHON_VER=unset

FROM rapidsai/miniforge-cuda:cuda$CUDA_VER-base-$LINUX_VER-py$PYTHON_VER

ARG CUDA_VER=unset
ARG PYTHON_VER=unset
ARG RAPIDS_VER=unset
ARG UCX_PY_VER=unset

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask/dask/main/continuous_integration/environment-$PYTHON_VER.yaml /dask.yml

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
    | sed -r "s/pandas=/pandas>=/g" \
    | sed -r "s/numpy=/numpy>=/g" \
    > dask_unpinned.yml

RUN conda-merge /rapids_pinned.yml /dask_unpinned.yml > /dask.yml

RUN rapids-mamba-retry env create -n dask --file /dask.yml

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+rw /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+rw /opt/conda

# need a user with access to conda
RUN useradd -r -g conda -u 10000 dask

CMD [ "/bin/bash" ]

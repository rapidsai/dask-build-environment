ARG CUDA_VER=11.8.0
ARG LINUX_VER=ubuntu20.04
ARG PYTHON_VER=3.10

FROM rapidsai/miniforge-cuda:cuda$CUDA_VER-base-$LINUX_VER-py$PYTHON_VER

ARG CUDA_VER=11.8.0
ARG PYTHON_VER=3.10
# RAPIDS_VER isn't used but is part of the matrix so must be included
ARG RAPIDS_VER=23.12

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask/dask-image/main/continuous_integration/environment-$PYTHON_VER.yml /dask.yml

ADD https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz /tools.tar.gz
RUN tar -xzvf /tools.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tools.tar.gz

RUN conda config --set ssl_verify false

RUN rapids-mamba-retry install conda-merge git

RUN cat /rapids.yml \
    | sed -r "s/CUDA_VER/$(echo $CUDA_VER | cut -d. -f1,2)/g" \
    > /rapids_pinned.yml

RUN conda-merge /rapids_pinned.yml /dask.yml > /dask_image.yml

RUN rapids-mamba-retry env create -n dask_image --file /dask_image.yml

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+rw /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+rw /opt/conda

# need a user with access to conda
RUN useradd -r -g conda -u 10000 dask

CMD [ "/bin/bash" ]

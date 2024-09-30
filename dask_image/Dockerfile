ARG CUDA_VER=unset
ARG LINUX_VER=unset
ARG PYTHON_VER=unset

FROM rapidsai/miniforge-cuda:cuda$CUDA_VER-base-$LINUX_VER-py$PYTHON_VER

ARG CUDA_VER=unset
ARG PYTHON_VER=unset

COPY environment.yml /rapids.yml
ADD https://raw.githubusercontent.com/dask/dask-image/main/continuous_integration/environment-$PYTHON_VER.yml /dask.yml
ADD https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz /tools.tar.gz

RUN <<EOT
  tar -xzvf /tools.tar.gz -C /usr/local/bin --strip-components=1
  rm /tools.tar.gz
  conda config --set ssl_verify false
  rapids-mamba-retry install conda-merge git
  cat /rapids.yml
    | sed -r "s/CUDA_VER/$(echo $CUDA_VER | cut -d. -f1,2)/g"
    > /rapids_pinned.yml
  conda-merge /rapids_pinned.yml /dask.yml > /dask_image.yml
  rapids-mamba-retry env create -n dask_image --file /dask_image.yml
  chmod -R ugo+rw /opt/conda
  conda clean -tipy
  chmod -R ugo+rw /opt/conda
  useradd -r -g conda -u 10000 dask
EOT

CMD [ "/bin/bash" ]

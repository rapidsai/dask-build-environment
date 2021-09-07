ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniconda-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.8
ARG NUMPY_VER=1.21
ARG RAPIDS_VER=21.08
ARG UCX_PY_VER=0.21

ADD https://raw.githubusercontent.com/dask-contrib/dask-sql/main/conda.txt /dask_sql_requirements.txt

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba

RUN gpuci_mamba_retry env create -n dask_sql --file /dask_sql_requirements.txt -c conda-forge

RUN gpuci_mamba_retry install -y -n dask_sql -c rapidsai -c rapidsai-nightly -c nvidia -c conda-forge \
    cudatoolkit=$CUDA_VER \
    cudf=$RAPIDS_VER \
    dask-cudf=$RAPIDS_VER \
    numpy=$NUMPY_VER \
    # following requirements are for postgres testing; might not need them
    sqlalchemy>=1.4.23 \
    pyhive>=0.6.4 \
    psycopg2>=2.9.1 \
    ciso8601>=2.2.0 \
    tpot>=0.11.7 \
    mlflow>=1.19.0 \
    docker-py>=5.0.0
    
RUN conda activate dask_sql && python -m pip install fugue[sql]>=0.5.3

RUN docker pull bde2020/hive:2.3.2-postgresql-metastore
RUN docker pull bde2020/hive-metastore-postgresql:2.3.0

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

FROM intelanalytics/ipex-llm-xpu:latest
USER root

WORKDIR /llm

# Update system, install necessary packages, update conda, create & configure the environment
RUN apt update && apt full-upgrade -y && \
    apt install -y bc google-perftools wget && \
    apt autoclean -y && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/miniconda3 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && \
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
    rm ~/miniconda3/miniconda.sh && \
    . ~/miniconda3/bin/activate

ENV PATH /root/miniconda3/bin:$PATH
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_NUM_GPU=999
ENV no_proxy=localhost,127.0.0.1
ENV ZES_ENABLE_SYSMAN=1
ENV SYCL_CACHE_PERSISTENT=1
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV ONEAPI_DEVICE_SELECTOR=level_zero:0

RUN conda init --all && \
    conda create -y -n llm-cpp python=3.11 && \
    echo "conda activate llm-cpp" >> ~/.bashrc && . ~/.bashrc && \
    conda run --no-capture-output -n llm-cpp pip install --pre --upgrade ipex-llm[cpp] && \
    conda run --no-capture-output -n llm-cpp init-ollama 

ADD run.sh .
RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]

#!/bin/bash -x

. /opt/intel/oneapi/setvars.sh
conda run --no-capture-output -n llm-cpp ./ollama serve

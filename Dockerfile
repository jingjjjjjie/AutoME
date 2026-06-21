FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-runtime

RUN pip install --no-cache-dir nvitop

RUN groupadd -g 1055 jingjie && useradd -u 1055 -g 1055 -m jingjie

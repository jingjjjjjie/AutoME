FROM pytorch/pytorch:2.7.0-cuda12.8-cudnn9-runtime

RUN pip install --no-cache-dir \
    nvitop \
    ftfy \
    omegaconf \
    regex \
    scikit-learn \
    submitit \
    termcolor \
    torchmetrics \
    torchvision \
    opencv-python \
    matplotlib \
    pandas \
    torchinfo \
    tqdm \
    timm

# Node.js + Codex CLI
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @openai/codex && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1055 jingjie && useradd -u 1055 -g 1055 -m jingjie

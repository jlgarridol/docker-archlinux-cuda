FROM base/archlinux

# Locale settings
RUN pacman -Sy --noconfirm \
        sed gzip grep awk which patch tar opencv && \
    echo 'es_ES.UTF-8 UTF-8' > /etc/locale.gen; locale-gen
ENV LANG es_ES.UTF-8
ENV LANGUAGE es_ES:es
ENV LC_ALL es_ES.UTF-8

# Download and install NVIDIA CUDA
RUN mkdir -p /nvidia/build && \
    cd /nvidia/build/ && \
    curl -o nvidia-install http://us.download.nvidia.com/tesla/440.33.01/NVIDIA-Linux-x86_64-440.33.01.run && \
    chmod +x nvidia-install && \
    /nvidia/build/nvidia-install -s -N --no-kernel-module && \
    rm -r /nvidia/
    
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &&\
    bash Miniconda3-latest-Linux-x86_64.sh -b &&\
    conda activate base &&\
    wget https://raw.githubusercontent.com/jlgarridol/docker-archlinux-cuda/master/enviroment.yml &&

RUN conda env create -f environment.yml &&\
    conda activate default-conda &&\
    pip install opencv-python
    
RUN conda install pytorch torchvision cudatoolkit=10.2 -c pytorch &&\
    python -m pip install 'git+https://github.com/facebookresearch/detectron2.git' 

#
# Install cuda from reqo
# Dependencies are skipped to avoid installing of nvidia driver
#
RUN pacman -S --noconfirm -dd \
                    cuda \
                    gcc5 \
                    libmpc \
                    binutils && \
    pacman -Scc --noconfirm
    
# Install extra packages    

ENV PATH=$PATH:/opt/cuda/bin

CMD nvidia-smi

FROM quay.io/fedora/fedora-toolbox:42 AS davincibox

# Support Nvidia Container Runtime (https://developer.nvidia.com/nvidia-container-runtime)
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox commands" \
    summary="Dependencies for running DaVinci Resolve on image-based Linux operating systems" \
    maintainer="pcsikos@zelikos.dev"

COPY system_files /

COPY davinci-dependencies /
RUN dnf -y update && \
    grep -v '^#' /davinci-dependencies | xargs dnf -y install
RUN rm /davinci-dependencies

RUN dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
RUN dnf -y install akmod-nvidia

FROM davincibox AS davincibox-opencl

# Remove mesa-libOpenCL since it breaks rocm-opencl
# https://github.com/zelikos/davincibox/issues/173
RUN dnf -y remove mesa-libOpenCL
RUN dnf -y install intel-compute-runtime rocm-opencl

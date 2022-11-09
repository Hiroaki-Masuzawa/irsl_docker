# create /choreonoid_ws
# choreonoid_ws: choreonoid
ARG BASE_IMAGE=ros:ros-melodic-base
FROM ${BASE_IMAGE}

ARG UBUNTU_VER=18.04

LABEL maintainer "IRSL-tut (https://github.com/IRSL-tut) <faculty@irsl.eiiris.tut.ac.jp>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

###
RUN apt update -q -qq && \
    apt install -q -qq -y curl wget git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

### install choreonoid
WORKDIR /choreonoid_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    wstool init src https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/main/config/dot.rosinstall && \
    wstool update -t src

## add robot_assembler
RUN (cd /choreonoid_ws/src/choreonoid/ext; git clone https://github.com/IRSL-tut/robot_assembler_plugin.git)

## add jupyter_plugin
#RUN (cd /choreonoid_ws/src/choreonoid/ext; git clone https://github.com/IRSL-tut/jupyter_plugin.git)

RUN apt update -q -qq && \
    src/choreonoid/misc/script/install-requisites-ubuntu-${UBUNTU_VER}.sh && \
    if [ "$ROS_DISTRO" = "noetic" ]; then \
    apt install -q -qq -y python3-catkin-tools libreadline-dev ipython3; \
    else \
    apt install -q -qq -y python-catkin-tools libreadline-dev ipython3; fi && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin config --install && catkin build irsl_choreonoid --no-status --no-notify -p 1 && catkin clean -d -b --logs -y"

### ADD entry point
## jupyter lab --no-browser --port=8888 --ip=0.0.0.0 --NotebookApp.token='' --allow-root

FROM osrf/ros:humble-desktop

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    sudo \
    cmake \
    git \
    git-core \
    pkg-config \
    build-essential \
    freeglut3-dev \
    libxmu-dev \
    libxi-dev \
    libusb-1.0-0-dev \
    libpython3-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libglew-dev \
    libepoxy-dev \
    libxkbcommon-dev \
    libopencv-dev \
    libboost-all-dev \
    libssl-dev \
    ros-humble-foxglove-bridge \
    ros-humble-rviz2 \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -ms /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN git clone https://github.com/OpenKinect/libfreenect.git /opt/libfreenect \
    && cmake -S /opt/libfreenect -B /opt/libfreenect/build -L \
    && cmake --build /opt/libfreenect/build \
    && cmake --install /opt/libfreenect/build \
    && ldconfig /usr/local/lib64/ \
    && ldconfig \
    && mkdir -p /etc/udev/rules.d \
    && printf '%s\n' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02b0", MODE="0666"' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ad", MODE="0666"' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ae", MODE="0666"' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02c2", MODE="0666"' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02be", MODE="0666"' \
      'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bf", MODE="0666"' \
      > /etc/udev/rules.d/51-kinect.rules

COPY ros2_ws /tmp/ros2_ws
RUN apt-get update \
    && bash -c "source /opt/ros/humble/setup.bash && rosdep update && rosdep install --from-paths /tmp/ros2_ws/src --ignore-src -r -y" \
    && rm -rf /var/lib/apt/lists/* /tmp/ros2_ws

USER $USERNAME
WORKDIR /home/$USERNAME

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

CMD ["bash"]

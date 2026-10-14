# kinect-ros2

Docker container with ROS 2 Humble and a node for the Kinect v1 (Xbox 360), based on [libfreenect](https://github.com/OpenKinect/libfreenect).

The image builds `libfreenect` from source and installs the workspace ROS dependencies. Package sources are mounted at `ros2_ws`, so `colcon` runs inside the container.

## Requirements

- Docker and Docker Compose
- Kinect v1 connected over USB
- USB access on the host (rules inside the image do not apply to the host kernel):

```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", MODE="0666"' | sudo tee /etc/udev/rules.d/51-kinect.rules
sudo udevadm control --reload && sudo udevadm trigger
```

If `gspca_kinect` is loaded, unload it. It blocks `libfreenect` from opening the camera:

```bash
sudo modprobe -r gspca_kinect
```

Let RViz use the host display:

```bash
xhost +local:docker
```

If your user is not UID/GID 1000, set `USER_UID` and `USER_GID` in `docker-compose.yml`.

## Start the container

```bash
docker compose build
docker compose up -d
docker compose exec kinect bash
```

Inside the container:

```bash
source /opt/ros/humble/setup.bash
cd ~/ros2_ws
colcon build
source install/setup.bash
```

## Run

Direct node. Topics are published at the root (`/image_raw`, `/depth/image_raw`, `/camera_info`, `/depth/camera_info`):

```bash
ros2 run kinect_ros2 kinect_ros2_node
```

With visualization. These launches put the node in the `kinect` namespace:

```bash
ros2 launch kinect_ros2 pointcloud.launch.py
ros2 launch kinect_ros2 showimage.launch.py
```

Camera check without ROS:

```bash
freenect-glview
```

## Record a bag

With the direct node:

```bash
ros2 bag record -o ~/bags/kinect \
  /camera_info /depth/camera_info /depth/image_raw /image_raw \
  /points /tf /tf_static
```

With a launch file, prefix the camera topics with `/kinect`. Bags live in `bags/` and are not committed.

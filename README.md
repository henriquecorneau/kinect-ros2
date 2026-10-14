# kinect-ros2

Container Docker com ROS 2 Humble e um nó para o Kinect v1 (Xbox 360), baseado no [libfreenect](https://github.com/OpenKinect/libfreenect).

A imagem instala o `libfreenect` a partir do código-fonte e as dependências ROS do workspace. O código do pacote fica montado em `ros2_ws`, então o build com `colcon` é feito dentro do container.

## Requisitos

- Docker e Docker Compose
- Kinect v1 conectado por USB
- No host, permissão de acesso ao USB (a regra dentro da imagem não vale para o kernel do host):

```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="045e", MODE="0666"' | sudo tee /etc/udev/rules.d/51-kinect.rules
sudo udevadm control --reload && sudo udevadm trigger
```

Se o módulo `gspca_kinect` estiver carregado, descarregue-o. Ele impede o `libfreenect` de abrir a câmera:

```bash
sudo modprobe -r gspca_kinect
```

Para o RViz usar a tela do host:

```bash
xhost +local:docker
```

Se o seu usuário não for UID/GID 1000, ajuste `USER_UID` e `USER_GID` no `docker-compose.yml`.

## Subir o container

```bash
docker compose build
docker compose up -d
docker compose exec kinect bash
```

Dentro do container:

```bash
source /opt/ros/humble/setup.bash
cd ~/ros2_ws
colcon build --cmake-args -Dlibfreenect_DIR=/opt/libfreenect/build
source install/setup.bash
```

O `libfreenect` não instala `libfreenectConfig.cmake` em `/usr/local`. O CMake precisa do diretório de build acima.

## Rodar

Nó direto. Os tópicos saem na raiz (`/image_raw`, `/depth/image_raw`, `/camera_info`, `/depth/camera_info`):

```bash
ros2 run kinect_ros2 kinect_ros2_node
```

Com visualização. O launch coloca o nó no namespace `kinect`:

```bash
ros2 launch kinect_ros2 pointcloud.launch.py
ros2 launch kinect_ros2 showimage.launch.py
```

Teste rápido da câmera, sem ROS:

```bash
freenect-glview
```

## Gravar um bag

Com o nó direto:

```bash
ros2 bag record -o ~/bags/kinect \
  /camera_info /depth/camera_info /depth/image_raw /image_raw \
  /points /tf /tf_static
```

Com o launch (`namespace:=kinect`), prefixe os tópicos de câmera com `/kinect`. Bags ficam em `bags/` e não entram no git.

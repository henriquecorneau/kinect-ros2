cmake_minimum_required(VERSION 3.8)
project(kinect_ros2)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Inclui diretórios do projeto e do cv_bridge
include_directories(
  include
  ${cv_bridge_INCLUDE_DIRS}
)

# Dependências
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_components REQUIRED)
find_package(ament_index_cpp REQUIRED)
find_package(OpenCV REQUIRED)
find_package(libfreenect REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(cv_bridge REQUIRED)
find_package(image_transport REQUIRED)
find_package(camera_info_manager REQUIRED)
find_package(depth_image_proc REQUIRED)
find_package(std_msgs REQUIRED)

# Biblioteca principal
add_library(kinect_ros2_component SHARED
  src/kinect_ros2_component.cpp
)

target_compile_definitions(kinect_ros2_component
  PRIVATE "COMPOSITION_BUILDING_DLL"
)

ament_target_dependencies(kinect_ros2_component
  rclcpp
  rclcpp_components
  ament_index_cpp
  sensor_msgs
  std_msgs
  cv_bridge
  image_transport
  camera_info_manager
  depth_image_proc
  OpenCV
)

target_link_libraries(kinect_ros2_component
  freenect
  ${OpenCV_LIBS}
)

rclcpp_components_register_nodes(kinect_ros2_component "kinect_ros2::KinectRosComponent")

# Nó executável
add_executable(kinect_ros2_node
  src/kinect_ros2_node.cpp
)

target_link_libraries(kinect_ros2_node
  kinect_ros2_component
)

ament_target_dependencies(kinect_ros2_node
  rclcpp
)

# Instalações
install(TARGETS
  kinect_ros2_component
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(TARGETS
  kinect_ros2_node
  DESTINATION lib/${PROJECT_NAME}
)

install(
  DIRECTORY cfg launch rviz
  DESTINATION share/${PROJECT_NAME}
)

ament_package()

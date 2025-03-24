# ROS & ROS2 Docker containers with Nvidia GPU
This repository provides Dockerfiles and a convenient Makefile to build and manage Docker containers tailored for **ROS (Robot Operating System)** and **ROS2** development with **NVIDIA GPU and CUDA support**.

Supported ROS distributions:

- **ROS:** `melodic`, `noetic`
- **ROS2:** `foxy`, `humble`

## Features
- **NVIDIA GPU & CUDA support** via NVIDIA Container Toolkit
- **X11 GUI forwarding** to host
- **Serial communication** support
- **Video input** access
- **Host networking**
- **Mounted volumes** for `ros_ws/src` and `data` for persistent development

## Prerequisites
Make sure you have the following installed on your system:
- [Docker](https://docs.docker.com/get-docker/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Build the Docker image
Initially, you need to build the Docker image with the desired ROS distribution.**
### Build
To build the image, run the following command:
```bash
make build ROS_DISTRO=<ros_distro> USER_NAME=<user_name>
```
#### Arguments
- `ROS_DISTRO`: `melodic`, `noetic`, `foxy` or `humble`. Default is `noetic`.
- `USER_NAME`: Name of the user to be created in the container. Default is `user`.

#### Notes
- The command will prompt for the password for container user. It is optional and can be left empty.
- UID and GID match the host user to avoid permission issues.
- The above command will build the image with the tag `ros-<ros_distro>-image`.

## Container Management
After building the image, you can manage the container using the following commands.  
_Note: Use the same ROS_DISTRO and USER_NAME as when building the image._

### Run
To run the container, run the following command:
```bash
make run ROS_DISTRO=<ros_distro> USER_NAME=<user_name>
```

#### Notes
- The above command will create a container with the tag `ros-<ros_distro>-container`.
- The container will be started and attached to the terminal and will not be stopped or removed when the terminal is closed.

### Attach
To attach to the container, run the following command:
```bash
make attach ROS_DISTRO=<ros_distro>
```

### Exec a shell
To open a shell in the container, run the following command:
```bash
make exec ROS_DISTRO=<ros_distro>
```

### Stop
To stop the container, run the following command:
```bash
make stop ROS_DISTRO=<ros_distro>
```

### Start
To start the container, run the following command:
```bash
make start ROS_DISTRO=<ros_distro>
```

### Rebuild
To rebuild the image, run the following command:
```bash
make rebuild ROS_DISTRO=<ros_distro>
```

### Clean
To remove the container and image, run the following command:
```bash
make clean ROS_DISTRO=<ros_distro>
```
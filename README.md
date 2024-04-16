# ROS Container
This repository contains Dockerfiles and a Makefile to build a Docker container for developing ROS applications. The supported ROS versions are Noetic and Humble. The container features the following:
- Mounts ros_ws/src and data directories as volumes
- Forwards X11 display to the host
- Supports serial communication
- Supports video input
- Allows access to the host's network

## Setup

### Build
To build the container, run the following command:
```bash
make build ROS_DISTRO=<ros_distro> USER_NAME=<user_name>
```
- `<ros_distro>` is either `noetic` or `humble`. Default is `noetic`.
- `<user_name>` is the name of the user to be created in the container. Default is `user`.

#### Notes
- The command will prompt for the password for the user to be created in the container. It is optional and can be left empty.
- The user will be created with the same user id and group id as the host user. This is to avoid permission issues for X11 display and mounted volumes.
- The above command will build the image with the tag `ros-<ros_distro>-image`.

**After a Docker image with a specific ROS distro is built, the following commands can be used to manage the image and the container.**
_Note: The arguments used in the following commands should be the same as the ones used to build the corresponding image._

### Run
To run the container, run the following command:
```bash
make run ROS_DISTRO=<ros_distro> USER_NAME=<user_name>
```

#### Notes
- The above command will create a container with the tag `ros-<ros_distro>-container`.
- The container will be started and attached to the terminal. The container will not be stopped or removed when the terminal is closed.

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
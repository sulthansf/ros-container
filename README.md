# ROS Container
This repository contains Dockerfiles and a Makefile to build a Docker container for developing ROS applications. The supported ROS versions are Noetic and Humble. The container features the following:
- Mounts ros_ws directory to the container as a volume
- Forwards X11 display to the host
- Supports serial communication
- Supports video input
- Allows access to the host's network

## Setup

### Build
To build the container, run the following command:
```bash
make build ROS_DISTRO=<ros_distro> USER_NAME=<user_name> USER_PASSWORD=<user_password>
```
`<ros_distro>` is either `noetic` or `humble`. Default is `noetic`.\
`<user_name>` is the name of the user to be created in the container. Default is `user`.\
`<user_password>` is the password of the user to be created in the container and is optional. There is no default password.

**After a Docker image with a specific ROS distro is built, the following commands can be used to manage the image and the container.**
_Note: All the below commands take the `ROS_DISTRO` argument. It should correspond to the ROS distro of the image or the container to be managed. Default is `noetic`._

### Run
To run the container, run the following command:
```bash
make run ROS_DISTRO=<ros_distro>
```
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
# Define arguments with default values
ROS_DISTRO 		:= noetic
USER_NAME 		:= user

# Define variables
IMAGE_TAG 		:= ros-$(ROS_DISTRO)-image
CONTAINER_TAG 	:= ros-$(ROS_DISTRO)-container
USER_UID 		:= $(shell id -u)
USER_GID 		:= $(shell id -g)

# Check if NVIDIA GPU is available
NVIDIA_GPU		:= $(shell (docker info | grep Runtimes | grep nvidia 1> /dev/null && command -v nvidia-smi 1>/dev/null 2>/dev/null && nvidia-smi | grep Processes 1>/dev/null 2>/dev/null) && echo '--runtime nvidia --gpus all' || echo '')

# Define supported ROS distros
override SUPPORTED_ROS_DISTROS := melodic noetic
# Define supported ROS2 distros
override SUPPORTED_ROS2_DISTROS := foxy humble

# Set Dockerfile path using ROS distro
ifneq ($(filter $(ROS_DISTRO),$(SUPPORTED_ROS_DISTROS)),)
	DOCKERFILE_PATH := Dockerfile.ros
else ifneq ($(filter $(ROS_DISTRO),$(SUPPORTED_ROS2_DISTROS)),)
	DOCKERFILE_PATH := Dockerfile.ros2
else
	DOCKERFILE_PATH := None
endif

# Build the Docker image
build:
	@if [ "$(DOCKERFILE_PATH)" = "None" ]; then \
		echo "Unsupported/invalid ROS distro: $(ROS_DISTRO). Supported ROS distros: $(SUPPORTED_ROS_DISTROS) $(SUPPORTED_ROS2_DISTROS)"; \
		exit 1; \
	fi
	@echo -n "Enter $(USER_NAME) password (optional, press ENTER to continue): "; \
	/bin/bash -c 'read -s USER_PASSWORD; echo; \
	docker build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
        --build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_PASSWORD=$$USER_PASSWORD \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-t $(IMAGE_TAG) \
		-f $(DOCKERFILE_PATH) .'

# Run the Docker container
run:
	docker run \
		--net=host \
		--name $(CONTAINER_TAG) \
		--restart unless-stopped \
		-e DISPLAY=${DISPLAY} \
		-e NVIDIA_DRIVER_CAPABILITIES=all ${NVIDIA_GPU} \
		-v /tmp/.X11-unix/:/tmp/.X11-unix \
		-v ~/.rviz/:/home/$(USER_NAME)/.rviz \
		-v ~/.Xauthority:/home/$(USER_NAME)/.Xauthority:ro \
		-v $(PWD)/ros_ws/src:/home/$(USER_NAME)/ros_ws/src \
		-v $(PWD)/data:/home/$(USER_NAME)/data \
	    -it $(IMAGE_TAG)

# Execute a command inside the running container
exec:
	docker exec -it $(CONTAINER_TAG) bash

# Attach to the running container
attach:
	docker attach $(CONTAINER_TAG)

# Stop the running container
stop:
	-docker stop $(CONTAINER_TAG)

# Start the stopped container
start:
	docker start $(CONTAINER_TAG)

# Remove the stopped container
rm:
	-docker rm $(CONTAINER_TAG)

# Remove the image
rmi:
	-docker rmi $(IMAGE_TAG)

# Stop and remove the container and image
clean: stop rm rmi

# Restart the Docker container
restart: stop start

# Rerun the Docker container
rerun: stop rm run

# Rebuild the Docker image
rebuild: clean build

# Default target
all: build run

# Help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  build		Build the Docker image"
	@echo "  run		Run the Docker container"
	@echo "  exec		Attach to a new bash session inside the running container"
	@echo "  attach	Attach to the running container"
	@echo "  stop		Stop the running container"
	@echo "  start		Start the stopped container"
	@echo "  rm		Remove the stopped container"
	@echo "  rmi		Remove the image"
	@echo "  clean		Stop and remove the container and image"
	@echo "  restart	Restart the Docker container"
	@echo "  rerun		Rerun the Docker container"
	@echo "  rebuild	Rebuild the Docker image"
	@echo "  all		Default target: build run"
	@echo "  help		Display this help message"
	@echo ""
	@echo "Variables:"
	@echo "  ROS_DISTRO		ROS distro (default: noetic)"
	@echo "  IMAGE_TAG		Docker image name (default: ros-$(ROS_DISTRO)-image)"
	@echo "  CONTAINER_TAG	Docker container name (default: ros-$(ROS_DISTRO)-container)"
	@echo "  USER_NAME		Username inside the container (default: user)"
	@echo "  USER_PASSWORD		Password for the user (default is empty)"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run"
	@echo "  make build run"
	@echo "  make build run ROS_DISTRO=humble USER_NAME=robot USER_PASSWORD=robot"
	@echo "  make rebuild run ROS_DISTRO=humble USER_NAME=robot USER_PASSWORD=robot"
	@echo "  make clean ROS_DISTRO=humble"

.PHONY: build run exec attach stop start rm rmi clean restart rerun rebuild all help
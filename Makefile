# Define arguments with default values
ROS_DISTRO 		= noetic
USER_NAME 		= user

# Define variables
IMAGE_TAG 		= ros-$(ROS_DISTRO)-image
CONTAINER_TAG 	= ros-$(ROS_DISTRO)-container
USER_UID 		= $(shell id -u)
USER_GID 		= $(shell id -g)

# Set Dockerfile path using ROS distro
ifeq ($(ROS_DISTRO), noetic)
	DOCKERFILE_PATH := Dockerfile-noetic
else ifeq ($(ROS_DISTRO), humble)
	DOCKERFILE_PATH := Dockerfile-humble
else
	DOCKERFILE_PATH := None
endif

# Build the Docker image
build:
	@if [ "$(DOCKERFILE_PATH)" = "None" ]; then \
		echo "Unsupported/invalid ROS distro: $(ROS_DISTRO). Only noetic and humble are supported"; \
		exit 1; \
	fi
	@echo -n "Enter $(USER_NAME) password (optional, press ENTER to continue): "; \
	/bin/bash -c 'read -s USER_PASSWORD; echo; \
	docker build \
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
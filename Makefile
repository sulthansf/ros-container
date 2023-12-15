# Define variables
ROS_DISTRO 		?= noetic
IMAGE_NAME 		?= ros-$(ROS_DISTRO)-image
CONTAINER_NAME 	?= ros-$(ROS_DISTRO)-container
USER_NAME 		?= user
USER_PASSWORD 	?=

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
	docker build \
        --build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_PASSWORD=$(USER_PASSWORD) \
		-t $(IMAGE_NAME) \
		-f $(DOCKERFILE_PATH) .

# Run the Docker container
run:
	docker run \
		--net=host \
		--name $(CONTAINER_NAME) \
		--hostname $(CONTAINER_NAME) \
		--add-host $(CONTAINER_NAME):127.0.0.1 \
		--restart unless-stopped \
		-e DISPLAY=${DISPLAY} \
		-v /tmp/.X11-unix/:/tmp/.X11-unix \
		-v ~/.rviz/:/home/$(USER_NAME)/.rviz \
		-v ~/.Xauthority:/home/$(USER_NAME)/.Xauthority:ro \
		-v $(PWD)/ros_ws/src:/home/$(USER_NAME)/ros_ws/src \
	    -it $(IMAGE_NAME)

# Execute a command inside the running container
exec:
	docker exec -it $(CONTAINER_NAME) bash

# Attach to the running container
attach:
	docker attach $(CONTAINER_NAME)

# Stop the running container
stop:
	docker stop $(CONTAINER_NAME)

# Start the stopped container
start:
	docker start $(CONTAINER_NAME)

# Stop and remove the container and image
clean:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(IMAGE_NAME)

# Rebuild the Docker image
rebuild: clean build

# Default target
all: build run
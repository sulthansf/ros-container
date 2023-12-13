# Define variables 
IMAGE_NAME 		?= ros-image
CONTAINER_NAME 	?= ros-container
ROS_DISTRO 		?= noetic
USER_NAME 		?= user

# Build the Docker image
build:
	docker build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
        --build-arg USER_NAME=$(USER_NAME) \
		-t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run \
		--net=host \
		--name $(CONTAINER_NAME) \
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

# Rebuild the Docker image and recreate the container
rebuild: clean build run

# Default target
all: build run
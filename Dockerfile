# Set the base image
ARG ROS_DISTRO=noetic

# Use the official ROS_DISTRO desktop image
FROM osrf/ros:$ROS_DISTRO-desktop

# Arguments
ARG USER_NAME=user

# Create a user with USER_NAME and give sudo privileges
RUN useradd -m -s /bin/bash $USER_NAME && \
    usermod -aG dialout $USER_NAME && \
    usermod -aG video $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

# Copy the requirements.txt file
COPY requirements.txt /tmp/requirements.txt

# Install the required packages
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-catkin-tools

# Install Python packages
RUN pip3 install -r /tmp/requirements.txt

# Set the user
USER $USER_NAME

# Set the working directory
WORKDIR /home/$USER_NAME

# COPY the ros_ws directory
COPY --chown=$USER_NAME:$USER_NAME ros_ws /home/$USER_NAME/ros_ws

# Build the package
RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && \
                  cd /home/$USER_NAME/ros_ws && \
                  catkin build"

# Add the ROS setup scripts to bashrc
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc && \
    echo "source /home/$USER_NAME/ros_ws/devel/setup.bash" >> ~/.bashrc
# Set the base image
ARG ROS_DISTRO=noetic

# Use the official ROS_DISTRO desktop image
FROM osrf/ros:$ROS_DISTRO-desktop

# Arguments
ARG USER_NAME=user
ARG DIR_NAME=ros-container

# Create a user with USER_NAME and give sudo privileges
RUN useradd -m -s /bin/bash $USER_NAME && \
    usermod -aG dialout $USER_NAME && \
    usermod -aG video $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

# Set the user
USER $USER_NAME

# Copy the contents of the current directory to the container
COPY . /home/$USER_NAME/$DIR_NAME

# Set the working directory
WORKDIR /home/$USER_NAME/$DIR_NAME

# Change the ownership of the home directory
RUN sudo chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

# Install the required packages
RUN sudo apt-get update && sudo apt-get install -y \
    python3-pip \
    python3-catkin-tools

# Install Python packages
RUN pip3 install -r requirements.txt

# Build the package
RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && \
                  cd /home/$USER_NAME/$DIR_NAME/ros_ws && \
                  catkin build"

# Add the ROS setup scripts to bashrc
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc && \
    echo "source /home/$USER_NAME/$DIR_NAME/ros_ws/devel/setup.bash" >> ~/.bashrc
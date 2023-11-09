#!/bin/bash

# Detect WSL vs Native Linux
if grep -qi microsoft /proc/version; then
  # echo "Ubuntu on Windows"
  isWSL=true
  catkinRoot = "/mnt/c/"
else
  # echo "Native Linux"
  isWSL=false
  catkinRoot = "~/"
fi

# Detect Linux version codename
distro=$(lsb_release -c -s)
if [ "$distro" = "focal" ]; then
  echo "Running on Ubuntu 20.04 - Focal Fossa"
  ROS_DISTRO="noetic"
elif [ "$distro" = "jammy" ]; then
  echo "Running on Ubuntu 21.10 - Jammy Jellyfish"
  ROS_DISTRO="humble"
else
  echo "Unknown Linux version"
fi

# add to /etc/sudoers file
echo "Adding user to sudoers for no password"
echo $USER "ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# System setup
echo "Update"
yes | sudo apt-get update

echo "Upgrade"
yes | sudo apt-get upgrade

echo "Installing Terminator"
yes | sudo apt install terminator

echo "Installing tmux"
yes | sudo apt-get install tmux

echo "Installing pip and other python packages"
yes | sudo apt-get install python3-pip 
yes | pip3 install opencv-python
yes | pip3 install numpy
yes | pip3 install matplotlib
yes | pip3 install pandas
yes | pip3 install opencv-contrib-python
yes | pip3 install scipy
yes | pip3 install casadi
yes | pip3 install scikit-learn
yes | pip3 install optuna
yes | pip3 install optuna-dashboard
yes | pip3 install optuna-fast-fanova gunicorn


# Install software only if OS is Native Linux
if ! $isWSL; then
    echo "Setting up SSH Server, net tools, GIT"
    yes | sudo apt-get install openssh-server net-tools git

    echo "Github Credential Save"
    git config --global credential.helper store

    echo "Installing VSCode"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    yes | sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    yes | sudo apt install apt-transport-https
    sudo apt-get update
    yes | sudo apt install code # or code-insiders

    echo " Installing Syncthing"	
    echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
    curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
    sudo apt update
    sudo apt install syncthing
    sudo systemctl enable syncthing@$USER.service
    sudo systemctl start syncthing@$USER.service

    echo "Installing Gparted"
    yes | sudo apt install gparted

    echo "Installing VLC"
    yes | sudo apt install vlc
    yes | sudo apt-get install exfat-fuse exfat-utils
fi


# ROS Setup
echo "Installing ROS $ROS_DISTRO"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
yes | sudo apt install curl # if you haven't already installed curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y ros-$ROS_DISTRO-desktop-full
sudo apt-get install -y ros-$ROS_DISTRO-navigation ros-$ROS_DISTRO-teb-local-planner* ros-$ROS_DISTRO-ros-control 
sudo apt-get install -y ros-$ROS_DISTRO-ros-controllers ros-$ROS_DISTRO-gazebo-ros-control ros-$ROS_DISTRO-ackermann-msgs 
sudo apt-get install -y ros-$ROS_DISTRO-serial ros-$ROS_DISTRO-rosserial*
sudo apt-get install -y ros-$ROS_DISTRO-rosbridge-suite ros-$ROS_DISTRO-foxglove-bridge

yes | sudo pip3 install -U catkin_tools
yes | sudo apt-get install libqt5serialport5-dev
yes | sudo apt-get install python3-rosdep


# ROS catkin WS Setup
source /opt/ros/$ROS_DISTRO/setup.bash
cd $catkinRoot
mkdir -p catkin_$ROS_DISTRO/src
cd catkin_$ROS_DISTRO/
catkin build;

sudo rosdep init;
rosdep update;

sudo cp bash_aliases.sh  ~/.bash_aliases
source ~/.bashrc 
# source ~/.bash_aliases



# # Install software only if OS is Native Linux
# if ! $isWSL; then
#     echo "Installing Conda"
#     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#     chmod +x Miniconda3-latest-Linux-x86_64.sh
#     bash Miniconda3-latest-Linux-x86_64.sh
# fi



# user to sudoers for no password
# sudo visudo
# <name> ALL=(ALL) NOPASSWD: ALL
# %sys ALL=(ALL) NOPASSWD: ALL


# sudo cp ./bash_aliases.sh  ~/.bash_aliases

# Detect WSL vs Native Linux
if grep -qi microsoft /proc/version; then
  # echo "Ubuntu on Windows"
  isWSL=true
  catkinRoot="/mnt/c"
else
  # echo "Native Linux"
  isWSL=false
  catkinRoot="~"
fi

# Detect Linux version codename
distro=$(lsb_release -c -s)
if [ "$distro" = "focal" ]; then
  echo "Running on Ubuntu 20.04 - Focal Fossa"
  export ROS_DISTRO="noetic"
elif [ "$distro" = "jammy" ]; then
  echo "Running on Ubuntu 22.04 - Jammy Jellyfish"
  export ROS_DISTRO="humble"
  export ROS_DOMAIN_ID=200
  export ROS_LOCALHOST_ONLY=0
else
  echo "Unknown Linux version"
fi

# ROS Setup
source /opt/ros/$ROS_DISTRO/setup.bash

# ROS Aliases

if [ "$distro" = "focal" ]; then
	alias cdset_catkin="cd $catkinRoot/catkin_$ROS_DISTRO/ && clear"
	alias srcset_catkin="source $catkinRoot/catkin_$ROS_DISTRO/devel/setup.bash"
	alias rset_catkin="(
	if cdset_catkin && catkin build; then 
		source devel/setup.bash &&
		clear &&
		echo 'ROS make and source completed.'
	else
		echo 'ROS make failed.'
	fi
	)"
	

	# alias xtf_messages="2> >(grep -v TF_REPEATED_DATA buffer_core)"

elif [ "$distro" = "jammy" ]; then
	source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
  	alias cdset_catkin="cd $catkinRoot/catkin_$ROS_DISTRO/ && clear"
	alias srcset_catkin="source $catkinRoot/catkin_$ROS_DISTRO/install/setup.bash"
	alias rset_catkin="(
	if cdset_catkin && colcon build --symlink-install; then 
		srcset_catkin &&
		clear &&
		echo 'ROS make and source completed.'
	else
		echo 'ROS make failed.'
	fi
	)"
else
  echo "Unknown Linux version"
fi

srcset_catkin


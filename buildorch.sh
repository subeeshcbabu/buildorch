#!/bin/sh
# The Init Script for Node and NPM Install and Configurations
#
#
echo "************************ Start Init *************************"
## CONSTANTS and Parameters
node_default_ver=v0.10.25
bash_profile=$HOME/.bash_profile

## Functions

##
## Initialize the Bash profile
##
function initBashProfile {
	echo "Initialize the bash profile"
	
	if [ -f "$bash_profile" ]; then
  		echo ".bash_profile exists"
	else
  		touch $bash_profile
	fi

	source $bash_profile
}

##
## @param command	- The command for version check
## @param ver		- The required version
##
function validateVersion {
	command=$1
	ver=$2
	out=`$command`
	res=0
	
	check_ver=`echo "$out" | grep "$ver"`
	if [ -z "$check_ver" ]; then
		# InValid
		res=1
	fi
	echo "$res"
}

##
## Install the node and npm using NVM module
##
function installNode {

	node_ver=$node_default_ver
	# Read the user requested version
	if [ ! -z "$NODE_VERSION" ]; then
		node_ver=$NODE_VERSION 
	fi
	
	# validate the existing version
	if [[ $(validateVersion "node -v" "$node_ver") = 0 ]]; then
		echo "Installed node version: $node_ver"
	elif [[ $(validateVersion "nvm ls $node_ver" "$node_ver") = 0 ]]; then
		echo "Installed node version: `nvm ls $node_ver`"
		nvm use $node_ver
	else
		echo "node version to install: $node_ver"
		# Install Node using NVM - https://github.com/creationix/nvm
		curl https://raw.github.com/creationix/nvm/master/install.sh | /bin/sh
		source $bash_profile
		nvm install $node_ver
		nvm use $node_ver
		node_dir=$HOME/.nvm/$node_ver
		node_exec_path=$node_dir/bin
		if [ -f "$node_exec_path/node" ]; then
			echo "Successfully Installed node and npm"
		else
			echo "Failed to install the node version $node_ver using NVM"
			#TODO what to do if the NVM Install fails? Exit the CI Build?
			exit 1
		fi
	fi

}

##
## Set the NPM Configurations
##
function configureNPM {

	if [ ! -z "$NPM_REGISTRY" ]; then
		echo "Set the npm config registry to $NPM_REGISTRY"
		npm config set registry $NPM_REGISTRY
	fi

	if [ ! -z "$NPM_CACHE" ]; then
		echo "Set the npm config cache to $NPM_CACHE"
		npm config set cache $NPM_CACHE
	fi

	if [ ! -z "$NPM_TMP" ]; then
		echo "Set the npm config tmp to $NPM_TMP"
		npm config set tmp $NPM_TMP
	fi


	if [ ! -z "$PYTHON_PATH" ]; then
		echo "Set the npm config python to $PYTHON_PATH"
		npm config set python $PYTHON_PATH
	fi
}

initBashProfile
installNode

echo "node exec path - `which node`"
echo "node version `node -v`"
echo "npm exec path `which npm`"
echo "npm version `npm -v`"

configureNPM




echo "************************ End Init *************************"
exit 0

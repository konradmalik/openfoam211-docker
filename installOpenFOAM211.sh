#----------------------------------*-sh-*--------------------------------------
# =========                 |
# \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
#  \\    /   O peration     |
#   \\  /    A nd           | Copyright (C) 2016-2017 OpenCFD Ltd. 
#    \\/     M anipulation  |
#------------------------------------------------------------------------------
# License
#     This file is part of OpenFOAM.
#
#     OpenFOAM is free software: you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
#     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#     FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#     for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.
#
# File
#     installOpenFOAM
#
# Description
#     this script will
#     1) Pull openfoam211 from docker hub if it does not exist in the local
#        environment 
#     2) Create a container with the name openfoam211
#     3) Image is loaded with the post-processing tool : paraview/paraFoam
#     4) Image comes with pre-installed utilities:
#        Midnight Commander, gnuplot 
#     5) This script has been tested up to docker version 1.12
#
#     Note: Docker daemon should be running before  launching script 
#
#------------------------------------------------------------------------------

username="$USER"
user="$(id -u)"
home="${1:-$HOME}"

imageName="konradmalik/openfoam211:latest"
containerName="openfoam211"   
displayVar="$DISPLAY"

# List container name :
echo "*******************************************************"
echo "Following Docker containers are present on your system:"
echo "*******************************************************"
docker ps -a 


# Create docker container for OpenFOAM operation   
echo "*******************************************************"
echo ""
echo "Creating Docker OpenFOAM container ${containerName}"

docker run  -it -d --name ${containerName} --user=${user}   \
    -e USER=${username}                                     \
    -e QT_X11_NO_MITSHM=1                                   \
    -e DISPLAY=${displayVar}                                \
    -e QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb                \
    --workdir="${home}"                                     \
    --volume="${home}:${home}"                              \
    --volume="/etc/group:/etc/group:ro"                     \
    --volume="/etc/passwd:/etc/passwd:ro"                   \
    --volume="/etc/shadow:/etc/shadow:ro"                   \
    --volume="/etc/sudoers:/etc/sudoers:ro"                 \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro"             \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix                  \
    ${imageName}


echo "Container ${containerName} was created."

echo "*******************************************************"
echo "Run the ./startOpenFOAM script to launch container"
echo "*******************************************************"

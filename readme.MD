# OpenFoam 2.1.1 in docker
###### Please note that this repo reuses publicly available scripts and the following instruction created by OpenCFD. Scripts and the instruction were modified according to my needs and to run OpenFoam 2.1.1.

### This instruction assumes that you have a working docker on your system.

## How-to
###### Note that you may need to mark the install and start scripts as executable.

#### 1. Run the installOpenFOAM211 script.
This will download an image from my repo and setup a container.

#### 2. To run OpenFoam run the "startOpenFOAM211" script.

#### 3. "Getting started" instruction from OpenFOAM website.
Use it to check if everything is working well.

##### Getting Started
Create a project directory within the $HOME/OpenFOAM directory named <USER>-2.1.1 (e.g. chris-2.1.1 for user chris and OpenFOAM version 2.1.1) and create a directory named run within it, e.g. by typing:

```bash
mkdir -p $FOAM_RUN
```
Copy across the backward facing step example, generate the mesh with blockMesh and run the steady flow, incompressible solver simpleFoam

```bash
cd $FOAM_RUN
cp -r $FOAM_TUTORIALS/incompressible/simpleFoam/pitzDaily .
cd pitzDaily
blockMesh
simpleFoam
paraFoam
```

FROM ubuntu:12.04

RUN apt-get update
RUN apt-get install -y wget
RUN sh -c "wget -O - http://dl.openfoam.org/gpg.key | apt-key add -"
RUN sh -c "echo deb http://dl.openfoam.org/ubuntu precise main > /etc/apt/sources.list.d/openfoam.list"
RUN apt-get update
RUN apt-get install -y openfoam211
RUN apt-get install -y paraviewopenfoam3120
RUN apt-get install -y nano
RUN apt-get install -y sudo
RUN apt-get install -y git
RUN apt-get install -y mc
RUN apt-get install -y gnuplot

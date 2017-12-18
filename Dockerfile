FROM ubuntu:12.04

RUN apt-get update && apt-get install -y wget
RUN sh -c "wget -O - http://dl.openfoam.org/gpg.key | apt-key add - && echo deb http://dl.openfoam.org/ubuntu precise main > /etc/apt/sources.list.d/openfoam.list"
RUN apt-get update && apt-get install -y openfoam211 paraviewopenfoam3120
RUN apt-get install -y nano sudo git mc gnuplot tmux make

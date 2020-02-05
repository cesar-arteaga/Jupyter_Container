# README

This container is for deploying a Jupyter Notebooks instance that is ready for use in analysis. This instance of Jupyter deploys with a Python 2, Python 3 and R kernel along with various libraries used in data analysis/visualization.
Instructions for installation

If you are familiar with building Docker images out of Dockerfiles, skip to the Jupyter Container section.

   Download and install Docker for Desktop (You will need to create a docker hub account to do this).
    Create a directory in your local machine to keep the Dockerfile and requirements in. For example, my files are in Users/carteaga/jupyter_docker_files
    Copy all the files (minus the README) from wasp/docker/jupyter into this new directory you've created.
    From your terminal, enter the directory where you've copied all these files and run the command docker build . (Yes, that period is part of the command). This command will tell Docker to create an image based on the Dockerfile. The creation of this image will take about 40 minutes or so and will finish with a prompt that says something like Successfully built 37ae3715dc45 . This random combination of letters and numbers is your image id .

# Jupyter Container

After building the image, the docker container should be ran using the command: docker run -p 8888:8888 <docker image id>. Once the container starts, it will instantly open Jupyter and provide you with an ip address. Copy and paste this ip address to your browser and you'll have access to Jupyter. Next, we'll see how to mount a directory to store our notebooks.
Mounting a Local Directory

In order to have Jupyter Notebook 'see' your local files, you must mount the desired directory.

   Create a directory on your local machine where you'll like to keep your notebooks. For example, I'm going to place mine in my Deskptop: mkdir ~/Desktop/example_notebooks
    Now, when you run your Docker container, you'll want to do it with the following command: docker run -p 8888:888 -v <directory where you want your notebooks>:<home directory for jupyter> <image id> . For example, I would run: docker run -p 8888:8888 -v ~/Desktop/example_notebooks:/home/archer/notebooks 37ae3715dc45

# Adding Packages

If you'd like to install additional Python packages, add those to the requirements.txt file and rebuild the image. Thanks to multi-stage building, this rebuild shouldn't take very long. If you'd like to add additional R packages, those must be written into the Dockerfile.

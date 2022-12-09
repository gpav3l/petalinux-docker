# petalinux-docker

Copy petalinux-v2020.2-final-installer.run file to this folder. Then run:

`docker build --build-arg PETA_VERSION=2020.2 --build-arg PETA_RUN_FILE=petalinux-v2020.2-final-installer.run -t petalinux:2020.2 .`

After installation, launch, open terminal, cd to folder with project and launch image by calling:
`docker run -ti --rm --net="host" -e GIT_ACCESS=<user>:<token> -v <path_to_repos>/home/vivado/repos $PWD:/home/vivado/project petalinux:2020.2 /bin/bash` 

For Windows 10 (Power Shell)
`docker run -ti --rm --net="host" -e GIT_ACCESS=<user>:<token> -v <path_to_repos>/home/vivado/repos -v ${PWD}:/home/vivado/project petalinux:2020.2 /bin/bash`

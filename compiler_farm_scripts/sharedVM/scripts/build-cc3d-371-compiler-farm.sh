#!/bin/bash

function run_and_watch_status {
    # first argument is a task descriptor and is mandatory
    # the remaining arguments make up a command to execute
    
    #executing the command
    "${@:2}"
    # querrying its status
    status=$?
    echo "STATUS=$status"
    if [ $status -ne 0 ]; then
        echo "error with $1"
        exit $status
    fi
    return $status    

}

export VERSION=3.7.1
echo "THIS IS VERSION ${VERSION} "


export CC3D_GIT_DIR=~/CC3D_GIT
export CC3D_BINARIES_DIR=/media/sf_sharedVM/binaries/${VERSION}/linux
eval CC3D_GIT_DIR=$CC3D_GIT_DIR
export number_of_cpus=8
export install_path=~/install_projects_${VERSION}/${VERSION}
eval install_path=$install_path

# get binaries repository
# mkdir $CC3D_BINARIES_DIR
# cd $CC3D_BINARIES_DIR
# svn checkout http://www.compucell3d.org/BinDoc/cc3d_binaries/binaries/3.7.0/linux .
# svn update

export CC3D_BUILD_SCRIPTS_GIT_DIR=~/CC3D_BUILD_SCRIPTS_GIT
eval CC3D_BUILD_SCRIPTS_GIT_DIR=$CC3D_BUILD_SCRIPTS_GIT_DIR

cd $CC3D_BUILD_SCRIPTS_GIT_DIR
git checkout master
git pull

cd $CC3D_GIT_DIR
git checkout $VERSION
git pull

cd $CC3D_BUILD_SCRIPTS_GIT_DIR/linux

time run_and_watch_status BUILDING_CC3D_371_COMPILER_FARM_SCRIPT  ./build-debian-cc3d-371.sh -s=$CC3D_GIT_DIR -p=$install_path -c=$number_of_cpus

cd $CC3D_BUILD_SCRIPTS_GIT_DIR/linux/DebianPackageBuilder

# remove old deb packages
rm -rf ${install_path}_deb/*

python ./deb-pkg-builder-371.py -d $install_path -i ${install_path}_deb -v ${VERSION}


mkdir -p ${CC3D_BINARIES_DIR}
#removing old debian packages
# rm -rf ${CC3D_BINARIES_DIR}/* 

cd ${install_path}_deb

cp *.deb $CC3D_BINARIES_DIR



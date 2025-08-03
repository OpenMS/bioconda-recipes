#!/bin/sh

# useless default include directory that is silently added by the compiler packages "to help"...
# it is not even added with -isystem https://github.com/AnacondaRecipes/aggregate/blob/master/clang/activate-clang%2B%2B.sh#L87
USELESS="-I${PREFIX}/include"
export CXXFLAGS=${CXXFLAGS//${USELESS}/}

# Not sure if those are needed 
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
#export DYLD_LIBRARY_PATH=${PREFIX}/lib


echo "Current directory: $(pwd)"
echo "SRC_DIR: $SRC_DIR"

# Save current directory
CURRENT_DIR=$(pwd)

# Go to source directory

cd $SRC_DIR
ls -la

# Check if there's only a single directory (excluding . and ..) and cd to it if found

# Find the directory containing THIRDPARTY and run git submodule command
echo "Searching for THIRDPARTY directory..."
THIRDPARTY_PARENT=$(find "$SRC_DIR" -name "THIRDPARTY" -type d 2>/dev/null | head -1)
if [ -n "$THIRDPARTY_PARENT" ]; then
    THIRDPARTY_PARENT_DIR=$(dirname "$THIRDPARTY_PARENT")
    echo "Found THIRDPARTY at: $THIRDPARTY_PARENT"
    echo "Parent directory: $THIRDPARTY_PARENT_DIR"
    cd "$THIRDPARTY_PARENT_DIR"
    echo "Running git submodule command from: $(pwd)"
    git submodule update --init THIRDPARTY
else
    echo "THIRDPARTY directory not found, searching for .gitmodules file..."
    GITMODULES_FILE=$(find "$SRC_DIR" -name ".gitmodules" -type f 2>/dev/null | head -1)
    if [ -n "$GITMODULES_FILE" ]; then
        GITMODULES_DIR=$(dirname "$GITMODULES_FILE")
        echo "Found .gitmodules at: $GITMODULES_FILE"
        echo "Git repository directory: $GITMODULES_DIR"
        cd "$GITMODULES_DIR"
        echo "Running git submodule command from: $(pwd)"
        git submodule update --init THIRDPARTY
    else
        echo "Warning: Neither THIRDPARTY directory nor .gitmodules file found!"
        echo "Attempting git submodule command from current directory: $(pwd)"
        git submodule update --init THIRDPARTY || echo "Git submodule command failed"
    fi
fi



cd $CURRENT_DIR
mkdir -p build
cd build


if [[ $(uname -s) == Darwin ]]; then
  RPATH='@loader_path/../lib'
else
  ORIGIN='$ORIGIN'
  export ORIGIN
  RPATH='$${ORIGIN}/../lib'
fi

# not sure if needed. CMake should take care of that.
LDFLAGS='-Wl,-rpath,${RPATH}'
# Note: Cmake could not find Qt6Config.cmake on fedora without adding those prefix paths

cmake .. \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="d36094e" \
  -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_PREFIX_PATH=${PREFIX}:${CONDA_PREFIX}:"${CONDA_PREFIX}/lib/cmake/Qt6/" \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${RPATH} \
  -DCMAKE_INSTALL_NAME_DIR="@rpath" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
  -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DWITH_GUI=OFF \
  -DWITH_PARQUET=ON \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64" \
  -DBUILD_EXAMPLES=OFF

# limit concurrent build jobs due to memory usage on CI
make -j1 OpenMS TOPP
# The subpackages will do the installing of the parts
#make install

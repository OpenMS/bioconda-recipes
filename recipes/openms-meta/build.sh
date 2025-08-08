#!/bin/sh

# useless default include directory that is silently added by the compiler packages "to help"...
# it is not even added with -isystem https://github.com/AnacondaRecipes/aggregate/blob/master/clang/activate-clang%2B%2B.sh#L87
USELESS="-I${PREFIX}/include"
export CXXFLAGS=${CXXFLAGS//${USELESS}/}

# Not sure if those are needed 
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
#export DYLD_LIBRARY_PATH=${PREFIX}/lib
# All we need to do is check out the OPENMS find binary script and figure out how to make it actually find it...

# We're currently in openms (I think), and want to be in openms/THIRDPARTY

if [ -d "THIRDPARTY" ]; then
  cd THIRDPARTY
else
  mkdir THIRDPARTY
  cd THIRDPARTY
fi
# Now we're in openms/THIRDPARTY

if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    fi
fi

curl -L -o THIRDPARTY-release-3.4.0.tar.gz https://api.github.com/repos/OpenMS/THIRDPARTY/tarball/release/3.4.0
tar -xzf THIRDPARTY-release-3.4.0.tar.gz
cd OpenMS-THIRDPARTY-*/Linux/x86_64/

# tree at ${THIRDPARTY_PREFIX} shows:
# ├── Comet
# │ ├── comet.exe
# │ ├── README.md
# │ └── README.txt
# ├── MaRaCluster
# │ └── maracluster
# ├── Percolator
# │ └── percolator
# ├── Sage
# │ ├── LICENSE
# │ ├── README.md
# │ └── sage
# ├── SpectraST
# │   ├── README
# │   └── spectrast
# └── XTandem
#     └── tandem.exe

# Now we have to MANUALLY add this to PATH since cmake's find_program only searches well defined paths, not prefixes.
# See how in third_party_tests.cmake, we have find_program(${varname} ${binaryname} PATHS ENV PATH)? It just means cmake looks in PATH.
to_export_linux="${PWD}/Comet/comet.exe:${PWD}/MaRaCluster/maracluster:${PWD}/Percolator/percolator:${PWD}/Sage/sage:${PWD}/SpectraST/spectrast:${PWD}/XTandem/tandem.exe"
cd ../../All
to_export_all="${PWD}/ThermoRawFileParser/ThermoRawFileParser.exe:${PWD}/LuciPHOr2/luciphor2.jar:${PWD}/MSGFPlus/MSGFPlus.jar" # no idea where msfragger jar is...
export PATH=${to_export_linux}:${to_export_all}:$PATH
echo $PATH  # Debug: verify PATH contains the tools
cd $SRC_DIR

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
  -DCMAKE_PREFIX_PATH=${PREFIX}:${CONDA_PREFIX}:"${CONDA_PREFIX}/lib/cmake/Qt6/":${THIRDPARTY_PREFIX} \
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

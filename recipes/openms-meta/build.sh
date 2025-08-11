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

# @jpfeuffer below is my attempt at trying to figure out why build.ninja wasn't fully generated. 
# I was under the impression that it was because src/tests/topp/THIRDPARTY/third_party_tests.cmake wasn't including the thirdparty modules, so here's my attempt at curling them from the internet. 
# Not sure that that was the actual reason though

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


# On Unix, find_program mimics the shell’s path search and requires the file to be executable, so it won’t find files without the executable
# bit set. But on Windows, find_program looks at file extensions like .exe, .com, etc., and does not need the executable bit.

chmod +x Comet/comet.exe MaRaCluster/maracluster Percolator/percolator Sage/sage SpectraST/spectrast XTandem/tandem.exe

to_export_linux="${PWD}/Comet:${PWD}/MaRaCluster:${PWD}/Percolator:${PWD}/Sage:${PWD}/SpectraST:${PWD}/XTandem"
cd ../../All
chmod +x LuciPHOr2/* MSGFPlus/* ThermoRawFileParser/* # let's just set all executable for now. Doesn't hurt. 
# this is not necessary for jars and dlls (luciphor/msgfplus)
# check out the implementation in the test cmake file

# output of tree .

# ├── LuciPHOr2
# │   ├── LICENSE.txt
# │   ├── luciphor2.jar
# │   └── README.txt
# ├── MSFragger
# │   ├── License.txt
# │   └── README.MD
# ├── MSGFPlus
# │   ├── LICENSE.txt
# │   ├── Mods.txt
# │   ├── MSGFPlus.jar
# │   ├── README.md
# │   └── README.txt
# └── ThermoRawFileParser
#     ├── AWS.Logger.Core.dll
#     ├── AWS.Logger.Core.pdb
#     ├── AWSSDK.CloudWatchLogs.dll
#     ├── AWSSDK.CloudWatchLogs.pdb
#     ├── AWSSDK.Core.dll
#     ├── AWSSDK.Core.pdb
#     ├── AWSSDK.S3.dll
#     ├── AWSSDK.S3.pdb
#     ├── IronSnappy.dll
#     ├── LICENSE
#     ├── log4net.config
#     ├── log4net.dll
#     ├── MathNet.Numerics.dll
#     ├── Mono.Options.dll
#     ├── Mono.Unix.dll
#     ├── Mono.Unix.dll.config
#     ├── Namotion.Reflection.dll
#     ├── Newtonsoft.Json.dll
#     ├── NJsonSchema.dll
#     ├── NUnit3.TestAdapter.dll
#     ├── NUnit3.TestAdapter.pdb
#     ├── nunit.engine.api.dll
#     ├── nunit.engine.core.dll
#     ├── nunit.engine.dll
#     ├── nunit.framework.dll
#     ├── OpenMcdf.dll
#     ├── OpenMcdf.Extensions.dll
#     ├── packages
#     │   └── Mono.Unix.7.1.0-final.1.21458.1
#     │       └── lib
#     │           └── net45
#     │               └── Mono.Unix.dll.config
#     ├── Parquet.dll
#     ├── runtimes
#     │   ├── android-arm
#     │   │   └── libMono.Unix.so
#     │   ├── android-arm64
#     │   │   └── libMono.Unix.so
#     │   ├── android-x64
#     │   │   └── libMono.Unix.so
#     │   ├── android-x86
#     │   │   └── libMono.Unix.so
#     │   ├── linux-arm
#     │   │   └── libMono.Unix.so
#     │   ├── linux-arm64
#     │   │   └── libMono.Unix.so
#     │   ├── linux-x64
#     │   │   └── libMono.Unix.so
#     │   ├── osx-arm64
#     │   │   └── libMono.Unix.dylib
#     │   └── osx-x64
#     │       └── libMono.Unix.dylib
#     ├── System.Buffers.dll
#     ├── System.IO.FileSystem.AccessControl.dll
#     ├── System.Memory.dll
#     ├── System.Numerics.Vectors.dll
#     ├── System.Runtime.CompilerServices.Unsafe.dll
#     ├── System.Security.AccessControl.dll
#     ├── System.Security.Principal.Windows.dll
#     ├── System.Text.Encoding.CodePages.dll
#     ├── System.ValueTuple.dll
#     ├── testcentric.engine.metadata.dll
#     ├── ThermoFisher.CommonCore.Data.dll
#     ├── ThermoFisher.CommonCore.RawFileReader.dll
#     ├── THERMO_LICENSE
#     ├── ThermoRawFileParser.exe
#     ├── ThermoRawFileParser.exe.config
#     ├── ThermoRawFileParser.pdb
#     └── zlib.net.dll

to_export_all="${PWD}/ThermoRawFileParser:${PWD}/LuciPHOr2:${PWD}/MSGFPlus" # no idea where msfragger jar is...
echo "PATH after adding third party tools:"
echo $PATH  # Debug: verify PATH contains the tools

# That worked! Now let's go get the rest of them: MSFragger, Novor, CometAdapter.

cd $SRC_DIR/THIRDPARTY
curl -L -o novor_academic_latest.zip https://github.com/BioContainers/software-archive/releases/download/NovoR/novor_academic_latest.zip

# Check if unzip is available, install if not
if ! command -v unzip &> /dev/null; then
    echo "unzip not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y unzip
    elif command -v yum &> /dev/null; then
        yum install -y unzip
    else
        echo "Error: Cannot install unzip - no package manager found"
        exit 1
    fi
fi

# Extract to novor directory
mkdir -p novor
unzip -q novor_academic_latest.zip -d novor
to_export_novor="${PWD}/novor/lib"

cd $SRC_DIR/THIRDPARTY

# MsFragger


export PATH=${to_export_linux}:${to_export_all}:${to_export_novor}:$PATH


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
  -G Ninja 
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
ninja -j1 OpenMS TOPP
# The subpackages will do the installing of the parts
#ninja install

#!/bin/bash
# In addition to the installed lib dir we want to set the path to the share
# when libopenms is used
# TODO does this propagate to dependent packages?
mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/libopenms.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/libopenms.sh

# Installs one CMake install component of the build that build.sh made.
install_component() {
  if [[ "$target_platform" == osx-* ]]; then
    # Conda adds the $PREFIX/lib RPATH already in LDFLAGS. We could remove it there before building.
    # For now just ignore the meaningless warning.
    cmake -DCOMPONENT="$1" -P build/cmake_install.cmake 2>&1 | grep -v "would duplicate path"
  else
    cmake -DCOMPONENT="$1" -P build/cmake_install.cmake
  fi
}

# The installed OpenMS package is layered (see cmake/install_macros.cmake in OpenMS):
# the core layer (libOpenMS, libOpenSwathAlgo) in the components library/cmake/
# OpenMS_headers, and on top of it the CLI layer -- libOpenMS_CLI, the TOPP tool
# framework (TOPPBase, ToolHandler, ...) that every TOPP tool of the `openms` output
# links against -- in library_cli/cmake_cli/OpenMS_CLI_headers.
#
# Both layers belong in this package: `openms` pins it exactly, so its tools resolve
# libOpenMS_CLI from here at runtime, and a consumer that builds TOPP-style tools gets
# the headers and the exported CMake targets (find_package(OpenMS COMPONENTS CLI)) of
# both layers. Leaving the CLI layer out here is what broke the `openms` package after
# the library split: its tools failed to start with
#   error while loading shared libraries: libOpenMS_CLI.so
# The GUI layer is not built (-DWITH_GUI=OFF in build.sh) and so has no components.
install_component library
install_component library_cli

cmake -DCOMPONENT="OpenMS_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenMS_CLI_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenSwathAlgo_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="thirdparty_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="share" -P build/cmake_install.cmake
cmake -DCOMPONENT="cmake" -P build/cmake_install.cmake
cmake -DCOMPONENT="cmake_cli" -P build/cmake_install.cmake

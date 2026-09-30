#!/bin/bash
# Every TOPP tool links the TOPP tool framework library (libOpenMS_CLI), which is its own
# layer of the installed package since OpenMS 3.6 (cmake/install_macros.cmake: core -> CLI -> GUI,
# one pair of install components each). cmake_install.cmake installs exactly the component it
# is handed and honours no component dependencies, so "library_cli" has to be named here;
# "Applications" alone gives tools that fail with "error while loading shared libraries:
# libOpenMS_CLI.so". The CLI layer belongs to this package, not to libopenms: libopenms is the
# core layer that pyopenms builds against (as the pyOpenMS wheels do).
# This package also ships the layer's development files: the tool framework headers
# (OpenMS_CLI_headers, e.g. OpenMS/APPLICATIONS/TOPPBase.h) and its exported CMake targets
# (cmake_cli, lib/cmake/OpenMS/OpenMSCLITargets.cmake), which OpenMSConfig.cmake from libopenms
# loads when present, so find_package(OpenMS CONFIG REQUIRED COMPONENTS CLI) works.
for component in library_cli OpenMS_CLI_headers cmake_cli Applications; do
  if [[ "$target_platform" == osx-* ]]; then
    # Conda adds the $PREFIX/lib RPATH already in LDFLAGS. We could remove it there before building.
    # For now just ignore the meaningless warning.
    cmake -DCOMPONENT="${component}" -P build/cmake_install.cmake 2>&1 | grep -v "would duplicate path"
  else
    cmake -DCOMPONENT="${component}" -P build/cmake_install.cmake
  fi
done

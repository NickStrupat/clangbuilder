# Author: Force Charlie
# Copyright (C) 2018. Force Charlie. All Rights Reserved.
cmake_minimum_required(VERSION 3.2)
project(ClangbuilderUI)


if( CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR AND NOT MSVC_IDE )
  message(FATAL_ERROR "In-source builds are not allowed.
CMake would overwrite the makefiles distributed with Rhizo.
Please create a directory and run cmake from there, passing the path
to this source directory as the last argument.
This process created the file `CMakeCache.txt' and the directory `CMakeFiles'.
Please delete them.")
endif()

include(CPack)


set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
if(NOT DEFINED CLANGBUILDERUI_VERSION_MAJOR)
  set(CLANGBUILDERUI_VERSION_MAJOR 1)
endif()
if(NOT DEFINED CLANGBUILDERUI_VERSION_MINOR)
  set(CLANGBUILDERUI_VERSION_MINOR 0)
endif()
if(NOT DEFINED CLANGBUILDERUI_VERSION_PATCH)
  set(CLANGBUILDERUI_VERSION_PATCH 3)
endif()

if (NOT PACKAGE_VERSION)
  set(PACKAGE_VERSION
    "${CLANGBUILDERUI_VERSION_MAJOR}.${CLANGBUILDERUI_VERSION_MINOR}.${CLANGBUILDERUI_VERSION_PATCH}")
endif()

set(CPACK_PACKAGE_NAME "ClangbuilderUI")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "ClangbuilderUI")
set(CPACK_PACKAGE_VERSION_MAJOR ${CLANGBUILDERUI_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CLANGBUILDERUI_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CLANGBUILDERUI_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION ${PACKAGE_VERSION})
set(CPACK_PACKAGE_VENDOR "ClangbuilderUI")
set(CPACK_PACKAGE_CONTACT "Force Charlie")

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)


add_executable(ClangbuilderUI WIN32
  ClangbuilderUI.cpp
  ClangbuilderUI.manifest
  ClangbuilderUI.rc
  MainWindow.cpp
  MessageWindow.cpp
  cmVSSetupHelper.cxx
  stdafx.cpp
  VisualStudioSearch.cpp
  WindowsUtil.cpp
)

add_definitions(
  -D_UNICODE
  -DUNICODE
)

target_link_libraries(ClangbuilderUI
  d2d1
  dwrite
  Pathcch
  shcore
  Winmm
  comctl32
  ole32.lib
  comsupp.lib
)

install(TARGETS "ClangbuilderUI"
	DESTINATION bin
)
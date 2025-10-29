cmake_minimum_required(VERSION 3.20)
project(ChaosMod CXX)

# ====================================
# Version Info
# ====================================
file(STRINGS ${PROJECT_SOURCE_DIR}/../version.txt MOD_VERSION)
configure_file(${PROJECT_SOURCE_DIR}/InfoTEMPLATE.h.in ${PROJECT_SOURCE_DIR}/Info.h @ONLY)

# ====================================
# Source Files
# ====================================
# Root source files
file(GLOB ROOT_SRC 
    ${PROJECT_SOURCE_DIR}/*.cpp
)

# Recursively get all effect and component sources
file(GLOB_RECURSE EFFECT_SRC 
    ${PROJECT_SOURCE_DIR}/Components/*.cpp 
    ${PROJECT_SOURCE_DIR}/Effects/*.cpp
    ${PROJECT_SOURCE_DIR}/Memory/*.cpp 
    ${PROJECT_SOURCE_DIR}/Util/*.cpp
)

# External trigger files (NEW)
set(EXTERNAL_TRIGGER_SRC
    ${PROJECT_SOURCE_DIR}/ExternalTrigger.cpp
    ${PROJECT_SOURCE_DIR}/EffectDatabase.cpp
)

# Patterns vendor
file(GLOB PATTERNS_SRC ${PROJECT_SOURCE_DIR}/../vendor/Patterns/Patterns.cpp)

# Combine all sources
set(ALL_SOURCES 
    ${ROOT_SRC} 
    ${EFFECT_SRC} 
    ${EXTERNAL_TRIGGER_SRC}
    ${PATTERNS_SRC}
)

# ====================================
# Create Library
# ====================================
add_library(ChaosMod MODULE 
    ${ALL_SOURCES}
    ChaosMod.rc
)

# Set output to .asi instead of .dll
set_target_properties(ChaosMod PROPERTIES 
    SUFFIX ".asi"
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

# Precompiled headers
target_precompile_headers(ChaosMod PRIVATE stdafx.h)

# ====================================
# Compiler Definitions
# ====================================
target_compile_definitions(ChaosMod PRIVATE
    $<$<CONFIG:Debug>:CHAOSDEBUG>
    NDEBUG
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    _CRT_SECURE_NO_WARNINGS
    UNICODE
    _UNICODE
    SOL_ALL_SAFETIES_ON
    SOL_DEFAULT_PASS_ON_ERROR
)

# ====================================
# Include Directories
# ====================================
target_include_directories(ChaosMod PRIVATE
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/../vendor
    ${PROJECT_SOURCE_DIR}/../vendor/lua/include
    ${PROJECT_SOURCE_DIR}/../vendor/httplib          # cpp-httplib
    ${PROJECT_SOURCE_DIR}/../vendor/nlohmann         # nlohmann/json
    ${PROJECT_SOURCE_DIR}/../vendor/shv/include
    ${PROJECT_SOURCE_DIR}/../vendor/minhook/include
)

# ====================================
# Dependencies
# ====================================
# ScriptHookV
if(EXISTS "${PROJECT_SOURCE_DIR}/../vendor/shv/CMakeLists.txt")
    add_subdirectory(${PROJECT_SOURCE_DIR}/../vendor/shv shv)
else()
    message(WARNING "shv directory missing or not initialized - building without advanced SHV features")
endif()

# MinHook
if(EXISTS "${PROJECT_SOURCE_DIR}/../vendor/minhook/CMakeLists.txt")
    add_subdirectory(${PROJECT_SOURCE_DIR}/../vendor/minhook minhook)
else()
    message(WARNING "minhook directory missing or not initialized - building without hooking features")
endif()

# Lua
target_link_directories(ChaosMod PRIVATE 
    ${PROJECT_SOURCE_DIR}/../vendor/lua
)

# ====================================
# Link Libraries
# ====================================
set(LINK_LIBS
    lua54
    winmm
    d3dcompiler
    xinput
)

# Conditionally add shv and minhook if available
if(EXISTS "${PROJECT_SOURCE_DIR}/../vendor/shv/CMakeLists.txt")
    list(APPEND LINK_LIBS shv)
endif()

if(EXISTS "${PROJECT_SOURCE_DIR}/../vendor/minhook/CMakeLists.txt")
    list(APPEND LINK_LIBS minhook)
endif()

target_link_libraries(ChaosMod PRIVATE ${LINK_LIBS})

# ====================================
# Debug Panel Support (Optional)
# ====================================
option(WITH_DEBUG_PANEL_SUPPORT "Enable debug panel websocket support" OFF)

if(WITH_DEBUG_PANEL_SUPPORT)
    message(STATUS "Debug panel support enabled")
    
    target_compile_definitions(ChaosMod PRIVATE WITH_DEBUG_PANEL_SUPPORT)
    
    target_include_directories(ChaosMod PRIVATE 
        ${PROJECT_SOURCE_DIR}/../vendor/IXWebSocket
    )
    
    set(USE_ZLIB OFF CACHE BOOL "Disable zlib in IXWebSocket")
    add_subdirectory(${PROJECT_SOURCE_DIR}/../vendor/IXWebSocket ixwebsocket)
    
    target_link_libraries(ChaosMod PRIVATE
        ixwebsocket
        wsock32
        ws2_32
    )
endif()

# ====================================
# Compiler-Specific Settings
# ====================================
if(MSVC)
    target_compile_options(ChaosMod PRIVATE
        /W3                 # Warning level 3
        /MT                 # Static runtime library (not DLL)
        /wd4244             # Disable warning C4244: conversion from 'double' to 'float'
        /wd4018             # Disable warning C4018: signed/unsigned mismatch  
        /wd4267             # Disable warning C4267: conversion from 'size_t' to 'type'
        /wd4265             # Disable warning C4265: class has virtual functions, but destructor is not virtual
        /Zi                 # Debug info
        /GT                 # Fiber-safe TLS
        /bigobj             # Large object files
        /MP                 # Multi-processor compilation
        /permissive-        # Standards conformance
    )
    
    target_link_options(ChaosMod PRIVATE
        /DEBUG              # Generate debug info
        /OPT:REF            # Eliminate unreferenced functions
        /OPT:ICF            # Identical COMDAT folding
        /NODEFAULTLIB:\"msvcrt.lib\"  # Don't link default runtime library
    )
    
    # Set Visual Studio working directory
    set_target_properties(ChaosMod PROPERTIES 
        VS_DEBUGGER_WORKING_DIRECTORY "$<TARGET_FILE_DIR:ChaosMod>"
    )
else()
    # MinGW/GCC settings
    target_compile_options(ChaosMod PRIVATE
        -municode
        -Wa,-mbig-obj
        -flarge-source-files
        -Wall
        -Wextra
        -Werror
        -Wno-unused-parameter
        -Wno-missing-field-initializers
        -Wno-unused-variable
    )
    
    target_link_options(ChaosMod PRIVATE
        -static
        -static-libgcc
        -static-libstdc++
    )
endif()

# ====================================
# Post-Build Commands
# ====================================
# Copy to GTA V directory if path is set
if(DEFINED ENV{GTA5_DIR})
    add_custom_command(TARGET ChaosMod POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:ChaosMod>
            "$ENV{GTA5_DIR}/scripts/"
        COMMENT "Copying ChaosMod.asi to GTA V scripts folder"
    )
endif()

# ====================================
# Installation
# ====================================
install(TARGETS ChaosMod
    RUNTIME DESTINATION .
    LIBRARY DESTINATION .
)

install(FILES 
    ${PROJECT_SOURCE_DIR}/../config.ini
    DESTINATION .
)
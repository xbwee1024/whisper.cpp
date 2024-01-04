cmake_minimum_required(VERSION 3.0)

# Library versioning (used in Mac Python bindings)x
set(SOVERSION 2)


###################
# Swig Settings
###################
include(FindSWIG)
# This module finds an installed SWIG. It sets the following variables:
# SWIG_FOUND - set to true if SWIG is found
# SWIG_DIR - the directory where swig is installed
# SWIG_EXECUTABLE - the path to the swig executable
# SWIG_VERSION   - the version number of the swig executable

find_package(SWIG 2.0)
if (NOT SWIG_FOUND)
    message(STATUS "SWIG 2.0 NOT found")
    return()
else ()
    if (SWIG_VERSION VERSION_GREATER_EQUAL 4.0)
        set(doxygen_switch "-doxygen")
    endif ()
endif (NOT SWIG_FOUND)

set(DEPENDS whisper)

if (ANDROID)
    list(APPEND DEPENDS log android)
endif()

###################
# Java Bindings
###################
if (NOT EXISTS ${CMAKE_SOURCE_DIR}/swig/java/whisper-java.cpp)
    find_package(JNI)
    if (NOT JNI_INCLUDE_DIRS)
        message(STATUS "Java Native Interface NOT found. Java bindings will NOT be compiled.")
    endif ()

    find_package(Java)
    if (NOT JAVA_COMPILE)
        message(STATUS "Java compiler NOT found. Java bindings will NOT be generated.")
        set(JAVAC_FAIL ON BOOL)
    endif ()

    if (JNI_INCLUDE_DIRS AND NOT JAVAC_FAIL)
        set(DO_JAVA_BINDINGS ON BOOL)
        message(STATUS "JAVA_COMPILE: ${JAVA_COMPILE}")
        message(STATUS "JNI_INCLUDE_DIRS: ${JNI_INCLUDE_DIRS}")
        message(STATUS "Java bindings will be compiled")
    endif ()
else ()
    message(STATUS "Warning: Java bindings NOT found. Generate using -DRUN_SWIG=ON.")
endif ()

if (DO_JAVA_BINDINGS)

    list(APPEND DEPENDS ${JNI_LIBRARIES})

    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/swig/java/whisper-java.cpp
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/swig/java/io/github/xbwee/whisper
            COMMAND ${SWIG_EXECUTABLE} -java -package io.github.xbwee.whisper -c++ ${doxygen_switch} -small -O -templatereduce -naturalvar -I${CMAKE_SOURCE_DIR} -o ${CMAKE_BINARY_DIR}/swig/java/whisper-java.cpp -outdir ${CMAKE_BINARY_DIR}/swig/java/io/github/xbwee/whisper ${CMAKE_SOURCE_DIR}/swig/whisper.i
            COMMAND ${JAVA_COMPILE} ARGS ${CMAKE_BINARY_DIR}/swig/java/io/github/xbwee/whisper/*.java
            COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/swig/java ${JAVA_ARCHIVE} cf libwhisper.jar io
            COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/swig/java/io/github/xbwee/whisper/*.class
            # COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/swig/java/libwhisper.jar ${CMAKE_SOURCE_DIR}/swig/java
            # COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/swig/java ${CMAKE_SOURCE_DIR}/swig/java
            # COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/swig/java
                MAIN_DEPENDENCY whisper.i
            )

    add_library(bindings_java MODULE ${CMAKE_BINARY_DIR}/swig/java/whisper-java.cpp)
    target_compile_options(bindings_java PRIVATE -fexceptions)
    set_target_properties(bindings_java PROPERTIES OUTPUT_NAME whisper_java)
    target_link_libraries(bindings_java ${DEPENDS})
    target_include_directories(bindings_java PRIVATE ${JNI_INCLUDE_DIRS})
    target_include_directories(bindings_java PRIVATE ${CMAKE_SOURCE_DIR})

    if (APPLE)
        set_target_properties(bindings_java PROPERTIES SUFFIX ".dylib")
    endif ()
    if ("${JAVA_INSTDIR}" STREQUAL "")
        if (ANDROID)
            set(JAVA_INSTDIR lib/${ANDROID_ABI})
        else ()
            set(JAVA_INSTDIR lib)
        endif ()
    endif ()
    install(TARGETS bindings_java
            LIBRARY DESTINATION "${JAVA_INSTDIR}"
            COMPONENT bindings_java)
    install(FILES ${CMAKE_BINARY_DIR}/swig/java/libwhisper.jar
            DESTINATION lib
            COMPONENT bindings_java)
endif ()


###################
# Python
###################
cmake_minimum_required(VERSION 3.5)
project(jqcore)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
if(NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "")
    set(CMAKE_BUILD_TYPE
        "Release"
        CACHE STRING "" FORCE)
    message(WARNING "Set build type to default: ${CMAKE_BUILD_TYPE}")
else()
    message(STATUS "Your build type: ${CMAKE_BUILD_TYPE}")
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Og -g")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Og -g")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

include_directories(
    BEFORE
    ${PROJECT_BINARY_DIR}
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/src
)
set(HEADER_ROOT "${PROJECT_SOURCE_DIR}/src")
file(GLOB_RECURSE HEADERS src/*.h)
file(GLOB_RECURSE SOURCES src/*.c)
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # https://github.com/dlfcn-win32/dlfcn-win32
    list(APPEND SOURCES patch/dlfcn.c)
    include_directories(${PROJECT_SOURCE_DIR}/patch)
endif()
add_library(${PROJECT_NAME} ${SOURCES} ${HEADERS})
install(
    TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
foreach(file ${HEADERS})
    get_filename_component(dir ${file} DIRECTORY)
    string(
        REGEX
        REPLACE "${HEADER_ROOT}"
                ""
                dir
                ${dir})
    install(FILES ${file} DESTINATION "include/${PROJECT_NAME}/${dir}")
endforeach()

option(BUILD_EXAMPLES "Build examples." ON)
if(BUILD_EXAMPLES)
    file(GLOB SRCS examples/*.c*)
    foreach(src ${SRCS})
        string(
            REGEX
            REPLACE "(^.*/|.c.*$)"
                    ""
                    exe
                    ${src})
        add_executable(${exe} ${src})
        target_link_libraries(
            ${exe}
            ${PROJECT_NAME}
            m
        )
        # https://google.github.io/benchmark/platform_specific_build_instructions.html
        if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
            target_link_libraries(${exe} shlwapi)
        elseif(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
            target_link_libraries(${exe} dl)
        endif()
        install(TARGETS ${exe} RUNTIME DESTINATION bin)
    endforeach(src)
endif()

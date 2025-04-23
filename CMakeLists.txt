cmake_minimum_required(VERSION 3.15)
project(TessA)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup")

add_compile_definitions(GLEW_STATIC)

add_subdirectory(3rdparty)
add_subdirectory(src)

set(GLEW_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/3rdparty/glew/include")
set(GLEW_LIB_DIR "${CMAKE_SOURCE_DIR}/3rdparty/glew/lib/Release/x64")

target_include_directories(${PROJECT_NAME} PUBLIC ${GLEW_INCLUDE_DIR})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/3rdparty/imgui)

target_link_directories(${PROJECT_NAME} PUBLIC ${GLEW_LIB_DIR})

target_link_libraries(${PROJECT_NAME} PUBLIC glm SDL2::SDL2 glew32s glu32 opengl32 imgui)

add_custom_target(bar
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/shaders
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/shaders ${CMAKE_BINARY_DIR}/shaders
        COMMENT "copying ${CMAKE_SOURCE_DIR}/shaders to ${CMAKE_BINARY_DIR}/shaders"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )

add_dependencies(${PROJECT_NAME} bar)

#add_executable(${PROJECT_NAME} WIN32 main.cpp)

#target_precompile_headers(${PROJECT_NAME} PUBLIC <vector> <string> <vector> <unordered_map> <glm/glm.hpp>)

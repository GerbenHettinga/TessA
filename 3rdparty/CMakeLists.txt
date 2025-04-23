add_library(glm INTERFACE)
add_subdirectory(SDL EXCLUDE_FROM_ALL)

target_include_directories(glm INTERFACE glm)

add_library(imgui STATIC)

target_include_directories(imgui PUBLIC imgui)

#set(GLEW_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/3rdparty/glew/include")
#set(GLEW_LIB_DIR "${CMAKE_SOURCE_DIR}/3rdparty/glew/lib/Release/x64")

target_sources(imgui PRIVATE 
  imgui/imgui.h
  imgui/imgui.cpp

  imgui/imgui_demo.cpp
  imgui/imgui_draw.cpp
  imgui/imgui_widgets.cpp
  imgui/imgui_tables.cpp
  imgui/backends/imgui_impl_opengl3.cpp
  imgui/backends/imgui_impl_sdl2.cpp
  )

target_link_libraries(imgui PUBLIC SDL2::SDL2)

#target_include_directories(stb_image INTERFACE stb_image)
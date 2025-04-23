file(GLOB_RECURSE SOURCE_FILES *.cpp)
file(GLOB_RECURSE HEADER_FILES *.h)


## Create main executable
add_executable(${PROJECT_NAME} ${HEADER_FILES} ${SOURCE_FILES})

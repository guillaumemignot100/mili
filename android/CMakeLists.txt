# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(milibris_reader_library VERSION 0.0.1 LANGUAGES CXX)

add_library(milibris_reader SHARED
  "src/main/cpp/milibris_reader_android.cpp"
)

target_include_directories(milibris_reader PRIVATE
  "../src"
)

find_library(log-lib log)
target_link_libraries(milibris_reader ${log-lib})

set_target_properties(milibris_reader PROPERTIES
  PUBLIC_HEADER ../src/milibris_reader.h
  OUTPUT_NAME   "milibris_reader"
)

target_compile_definitions(milibris_reader PUBLIC DART_SHARED_LIB)

# Support Android 15 16k page size
target_link_options(milibris_reader PRIVATE "-Wl,-z,max-page-size=16384")

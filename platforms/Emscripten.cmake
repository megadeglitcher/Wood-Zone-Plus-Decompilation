cmake_minimum_required(VERSION 3.7)

project(RetroEngine)

add_executable(RetroEngine ${RETRO_FILES})

# we can really use use all for emscripten.
# only manual dependency actually needed is just
# theora - no need for another folder
set(DEP_PATH all)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")

set(EMSCRIPTEN_FLAGS
    -sUSE_SDL=2
    -sUSE_SDL_IMAGE=1
    -sUSE_OGG=1
    -sUSE_VORBIS=1
    -DRETRO_USING_OPENGL=1
    -DRETRO_USE_NETWORKING=0
    -O3
)

set(emsc_link_options
    -sTOTAL_MEMORY=64MB
    -sALLOW_MEMORY_GROWTH=1
    -sUSE_SDL=2
    -sUSE_SDL_IMAGE=1
    -sUSE_OGG=1
    -sUSE_VORBIS=1
    -sLEGACY_GL_EMULATION=1
    -sEMULATE_FUNCTION_POINTER_CASTS
    -sFORCE_FILESYSTEM=1
    -sELIMINATE_DUPLICATE_FUNCTIONS=1
    -sEXPORTED_FUNCTIONS=['_main','_RSDK_Initialize','_RSDK_Configure']
    -lm
    -lidbfs.js
    -flto
)

target_compile_options(RetroEngine PRIVATE ${EMSCRIPTEN_FLAGS})
target_link_options(RetroEngine PRIVATE ${emsc_link_options})

if(RETRO_MOD_LOADER)
    set_target_properties(RetroEngine PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
endif()

set_target_properties(RetroEngine PROPERTIES
    OUTPUT_NAME "RSDKv4" 
    SUFFIX ".js"
)

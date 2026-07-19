add_library(asteroid-horizon main.cpp resources.qrc)
set_target_properties(asteroid-horizon PROPERTIES PREFIX "")

target_link_libraries(asteroid-horizon PUBLIC
    Asteroid::AsteroidApp6)

install(TARGETS asteroid-horizon
    DESTINATION ${CMAKE_INSTALL_LIBDIR})

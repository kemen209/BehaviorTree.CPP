list(APPEND CMAKE_PREFIX_PATH "${CMAKE_BINARY_DIR}")

if(BTCPP_GROOT_INTERFACE)
    find_package(ZeroMQ REQUIRED)
    # Use the Conan-provided libzmq target which is properly configured
    list(APPEND BTCPP_EXTRA_LIBRARIES libzmq)
    message(STATUS "ZeroMQ_LIBRARIES: libzmq (Conan target)")
endif()

if(BTCPP_SQLITE_LOGGING)
    find_package(SQLite3 REQUIRED)
    list(APPEND BTCPP_EXTRA_LIBRARIES sqlite3)
    list(APPEND BTCPP_EXTRA_INCLUDE_DIRS ${SQLite3_INCLUDE_DIRS})
    message(STATUS "SQLite3_LIBRARIES: sqlite3")
    message(STATUS "SQLite3_INCLUDE_DIRS: ${SQLite3_INCLUDE_DIRS}")
endif()

# Add system libraries for Windows
if(WIN32)
    list(APPEND BTCPP_EXTRA_LIBRARIES iphlpapi ws2_32)
endif()


set( BTCPP_LIB_DESTINATION     lib )
set( BTCPP_INCLUDE_DESTINATION include )
set( BTCPP_BIN_DESTINATION     bin )

mark_as_advanced(
    BTCPP_EXTRA_LIBRARIES
    BTCPP_LIB_DESTINATION
    BTCPP_INCLUDE_DESTINATION
    BTCPP_BIN_DESTINATION )

macro(export_btcpp_package)

    install(EXPORT ${PROJECT_NAME}Targets
        FILE "${PROJECT_NAME}Targets.cmake"
        DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
        NAMESPACE BT::
        )
    export(PACKAGE ${PROJECT_NAME})

    include(CMakePackageConfigHelpers)

    configure_package_config_file(
        "${PROJECT_SOURCE_DIR}/cmake/Config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
        )

    install(
        FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
        )
endmacro()

cmake_minimum_required(VERSION 3.10.2)

project(enx_security LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define a criação da biblioteca compartilhada (.so)
add_library(enx_security SHARED
            enx_security.cpp)

# Biblioteca de log do Android (útil para debug se necessário)
find_library(log-lib log)

target_link_libraries(enx_security
                      ${log-lib})
                      
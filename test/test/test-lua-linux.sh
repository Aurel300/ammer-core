#!/bin/bash
export LD_LIBRARY_PATH=$(luarocks config --lua-libdir):bin/lua
lua bin/lua/test.lua

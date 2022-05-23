#!/bin/bash

rm -rf bin/cpp-static/src/ammer/externs

haxe build-cpp-static.hxml \
    && haxe build-cs.hxml \
    && haxe build-hl.hxml \
    && haxe build-hlc.hxml \
    && haxe build-java.hxml \
    && haxe build-jvm.hxml \
    && haxe build-lua.hxml \
    && haxe build-neko.hxml \
    && haxe build-nodejs.hxml \
    && haxe build-python.hxml

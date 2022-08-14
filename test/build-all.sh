#!/bin/bash

rm -rf bin/cpp-static/src/ammer/externs

true \
    && haxe build/build-cpp-static.hxml \
    && haxe build/build-cs.hxml \
    && haxe build/build-hl.hxml \
    && haxe build/build-hlc.hxml \
    && haxe build/build-java.hxml \
    && haxe build/build-jvm.hxml \
    && haxe build/build-lua.hxml \
    && haxe build/build-neko.hxml \
    && haxe build/build-nodejs.hxml \
    && haxe build/build-python.hxml

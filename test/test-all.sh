#!/bin/bash

true \
    && echo "cpp-static ... " && test/test-cpp-static.sh \
    && echo "cs ... " && test/test-cs.sh \
    && echo "hl ... " && test/test-hl.sh \
    && echo "hlc ... " && test/test-hlc.sh \
    && echo "java ... " && test/test-java.sh \
    && echo "jvm ... " && test/test-jvm.sh \
    && echo "lua ... " && test/test-lua.sh \
    && echo "neko ... " && test/test-neko.sh \
    && echo "nodejs ... " && test/test-nodejs.sh \
    && echo "python ... " && test/test-python.sh

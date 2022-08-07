#!/bin/bash

true \
    && echo "cpp-static ... " && ./test-cpp-static.sh \
    && echo "cs ... " && ./test-cs.sh \
    && echo "hl ... " && ./test-hl.sh \
    && echo "hlc ... " && ./test-hlc.sh \
    && echo "java ... " && ./test-java.sh \
    && echo "jvm ... " && ./test-jvm.sh \
    && echo "lua ... " && ./test-lua.sh \
    && echo "neko ... " && ./test-neko.sh \
    && echo "nodejs ... " && ./test-nodejs.sh \
    && echo "python ... " && ./test-python.sh

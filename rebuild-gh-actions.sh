#!/bin/bash

GH_ACTION_PATH="ammer-gh-action"
if [[ ! -e "$GH_ACTION_PATH" ]]; then
    echo "ammer-gh-action directory not found: git checkout https://github.com/HaxeAmmer/ammer-gh-action"
    exit 1
fi

TEMPLATE_PATH=`realpath "$GH_ACTION_PATH/templates"`

rm -rf .github/workflows
mkdir -p .github/workflows
pushd .github/workflows-partial
for f in *.yml; do
    TARGET_NAME="${f%.yml}"
    TARGET_NAME="${TARGET_NAME#test-}"
    echo "$TARGET_NAME ..."

    # header
    echo "# generated with $0, do not edit directly" > "../workflows/$f"
    if [[ "$TARGET_NAME" == "hl" ]]; then
        echo "name: Test hl, hlc" >> "../workflows/$f"
    elif [[ "$TARGET_NAME" == "java" ]]; then
        echo "name: Test java, jvm" >> "../workflows/$f"
    else
        echo "name: Test $TARGET_NAME" >> "../workflows/$f"
    fi
    cat "$TEMPLATE_PATH/header-0.yml" >> "../workflows/$f"

    # environment
    echo "      CI_HAXE_VERSION: '4.2.5'" >> "../workflows/$f"
    if [[ "$TARGET_NAME" == "eval" ]]; then
        echo "      PLATFORM: mac" >> "../workflows/$f"
        echo "      OPAMYES: 1" >> "../workflows/$f"
    fi

    # OS
    if [[ "$TARGET_NAME" == "cs" ]]; then
        # TODO: re-enable windows-latest (issue #11)
        cat "$TEMPLATE_PATH/header-1/macos-ubuntu.yml" >> "../workflows/$f"
    elif [[ "$TARGET_NAME" == "lua" ]]; then
        # TODO: re-enable windows-latest (issue #13)
        cat "$TEMPLATE_PATH/header-1/macos-ubuntu.yml" >> "../workflows/$f"
    elif [[ "$TARGET_NAME" == "eval" ]]; then
        # TODO: other systems
        cat "$TEMPLATE_PATH/header-1/macos.yml" >> "../workflows/$f"
    else
        cat "$TEMPLATE_PATH/header-1/all.yml" >> "../workflows/$f"
    fi

    # Haxe setup
    if [[ "$TARGET_NAME" != "eval" ]]; then
        cat "$TEMPLATE_PATH/haxe.yml" >> "../workflows/$f"
    fi

    # platform setup
    cat "$TEMPLATE_PATH/platform-setup/$TARGET_NAME.yml" >> "../workflows/$f"

    # compile and test
    cat "$f" >> "../workflows/$f"
done
popd

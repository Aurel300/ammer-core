# `ammer-core`

`ammer-core` is the foundation for [`ammer`](https://github.com/Aurel300/ammer). It is a [Haxe](https://haxe.org/) macro library which allows Haxe code to call C code and vice versa with a unified interface. The table below shows the CI status for each supported target on major operating systems.

Documentation is mainly to be found in the source code, although there is a [high-level overview](https://aurel300.github.io/ammer/core.html) in the `ammer` manual.

| Target        | Linux | macOS | Windows | CI status |
| ------------- |:-----:|:-----:|:-------:| ---------:|
| `cpp-static`  | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-cpp-static.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-cpp-static.yml) |
| `cs`          | ✔️     | ✔️     | [#11](https://github.com/Aurel300/ammer-core/issues/11) | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-cs.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-cs.yml) |
| `eval`        | -     | ✔️     | -       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-eval.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-eval.yml) |
| `hl`, `hlc`   | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-hl.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-hl.yml) |
| `java`, `jvm` | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-java.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-java.yml) |
| `lua`         | ✔️     | ✔️     | [#13](https://github.com/Aurel300/ammer-core/issues/13) | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-lua.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-lua.yml) |
| `neko`        | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-neko.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-neko.yml) |
| `nodejs`      | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-nodejs.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-nodejs.yml) |
| `python`      | ✔️     | ✔️     | ✔️       | [![](https://github.com/Aurel300/ammer-core/actions/workflows/test-python.yml/badge.svg)](https://github.com/Aurel300/ammer-core/actions/workflows/test-python.yml) |

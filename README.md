# Matrix Rain in Zig

![Matrix Rain](https://raw.githubusercontent.com/ParadoxPD/matrix-rain-in-zig/main/assets/output.gif)


`Zig Version - 0.14` 
### How to build the project

```bash
$ zig init 
$ zig fetch --save git+https://github.com/raylib-zig/raylib-zig#devel
```

```batch
@echo off
zig build --prefix ./build
```

To run the project : 

```batch
@echo off
zig build --prefix ../build run --summary all
```


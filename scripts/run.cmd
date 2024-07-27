@echo off

if exist ..\\build\\app.exe (
    del ..\\build\\app.exe 
) 

zig build-exe ..\\src\\root.zig
ren ..\\root.exe app.exe
move ..\\app.exe .\\build
del ..\\root.exe.obj
del ..\\root.pdb
..\\build\\app
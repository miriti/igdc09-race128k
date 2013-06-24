del exe\*.exe
dcc32 -E"exe" race.dpr -$D- -$L- -$T- -$I- -$O+ -$G- -$C-
del *.~*
del *.obj
del *.dcu
del *.dof
del *.cfg
upx -9 exe\race.exe
exe\race.exe
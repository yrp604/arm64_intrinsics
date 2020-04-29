# Path to binaryninja install
BINJAPATH = $(LOCALAPPDATA)\Vector35\BinaryNinja
BINJACORE = $(BINJAPATH)\binaryninjacore.lib
BINJAAPI  = ..\binaryninja-api
# Path to prebuilt libbinaryninjaapi.a
BINJA_API_A = $(BINJAAPI)\bin\libbinaryninjaapi.lib

# Path to binaryninjaapi.h and json
INC = -I$(BINJAAPI)

PLUGIN_DIR = "$(APPDATA)\Binary Ninja\plugins"

CC = cl
CFLAGS = /EHsc /DWIN32 /W3 /Zi /nologo
LD = link
LDFLAGS = /nologo /DLL /debug:full

LIBS = /L$(BINJAPATH) /lbinaryninjacore

TARGET = arm64_intrinsics.dll

all: $(TARGET)

src/msr.h: msr.py
	python msr.py
	clang-format -i src/msr.h || cd .

src/arm64_intrinsics.cpp.obj: src/arm64_intrinsics.cpp src/msr.h
	$(CC) $(CFLAGS) $(INC) /c /Fo$@ $**

$(TARGET): src/arm64_intrinsics.cpp.obj
	$(LD) $(LDFLAGS) $(BINJACORE) $(BINJA_API_A) $** /out:$@

.PHONY: fmt
fmt:
	clang-format -i src/arm64_intrinsics.cpp

install: $(TARGET)
	copy $(TARGET) $(PLUGIN_DIR)

uninstall:
	-del $(PLUGIN_DIR)\$(TARGET)

.PHONY: clean
clean:
	-del src\*.obj
	-del src\msr.h
	-del arm64_intrinsics.dll
	-del arm64_intrinsics.lib
	-del *.pdb
	-del *.exp
	-del *.ilk

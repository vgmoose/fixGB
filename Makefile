TARGET := fixGB
DEBUG   = 0
AUDIO_FLOAT = 1

OBJECTS :=
OBJECTS +=alhelpers.o
OBJECTS +=apu.o
OBJECTS +=audio.o
OBJECTS +=cpu.o
OBJECTS +=input.o
OBJECTS +=main.o
OBJECTS +=mbc.o
OBJECTS +=mem.o
OBJECTS +=ppu.o

FLAGS    += -Wall -Wextra -msse -mfpmath=sse -ffast-math
FLAGS    += -Werror=implicit-function-declaration
DEFINES  += -DFREEGLUT_STATIC
INCLUDES += -I.

ifeq ($(AUDIO_FLOAT),1)
FLAGS += -DAUDIO_FLOAT=1
endif

ifeq ($(DEBUG),1)
FLAGS += -O0 -g
else
FLAGS   += -O3
LDFLAGS += -s
endif

ifeq ($(ZIPSUPPORT),1)
FLAGS += -DZIPSUPPORT=1
LDFLAGS += -lminizip
endif

ifeq ($(FILESELECT),1)
STATIC_NFD := ./fileselect/nativefiledialog/build/lib/Release/x64/libnfd.a
INCLUDES += -Ifileselect/nativefiledialog/src/include
FLAGS += -DFILESELECT=1

NFD_PLATFORM :=

ifeq ($(OS),Windows_NT)
	NFD_PLATFORM = gmake_windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		LDFLAGS += $(shell pkg-config --cflags --libs gtk+-3.0)
		NFD_PLATFORM = gmake_linux
	endif
	ifeq ($(UNAME_S),Darwin)
		NFD_PLATFORM = gmake_macosx
		INCLUDES += -I/usr/local/Cellar/openal-soft/1.21.1/include
		LDFLAGS +=  -framework OpenGL -framework GLUT -framework Cocoa -L/usr/local/Cellar/openal-soft/1.21.1/lib -L/opt/X11/lib/
	endif
endif

OBJECTS += $(STATIC_NFD)
endif


CFLAGS += $(FLAGS) $(DEFINES) $(INCLUDES)

LDFLAGS += $(CFLAGS) -lglut -lopenal -lGL -lGLU -lm

all: $(TARGET)
$(TARGET): $(OBJECTS)
	$(CC) $^ -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -f $(TARGET) $(OBJECTS)

ifeq ($(FILESELECT),1)
$(STATIC_NFD):
	$(MAKE) -C fileselect/nativefiledialog/build/$(NFD_PLATFORM)
endif

.PHONY: clean test

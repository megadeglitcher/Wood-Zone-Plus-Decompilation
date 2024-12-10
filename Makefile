RETRO_NETWORKING		?= 1
RETRO_USE_HW_RENDER		?= 1


.DEFAULT_GOAL := all

NAME		=  WZ+
SUFFIX		=
PKGCONFIG	=  pkg-config
DEBUG		?= 0
STATIC		?= 1
VERBOSE		?= 0
PROFILE		?= 0
STRIP		?= strip
DEFINES		=

# =============================================================================
# Detect default platform if not explicitly specified
# =============================================================================

ifeq ($(OS),Windows_NT)
	PLATFORM ?= Windows
else
	UNAME_S := $(shell uname -s)

	ifeq ($(UNAME_S),Linux)
		PLATFORM ?= Linux
	endif

	ifeq ($(UNAME_S),Darwin)
		PLATFORM ?= macOS
	endif

endif

ifdef EMSCRIPTEN
	PLATFORM = Emscripten
endif

PLATFORM ?= Unknown

# =============================================================================

OUTDIR = bin/$(PLATFORM)
OBJDIR = obj/$(PLATFORM)

include Makefile_cfgs/Platforms/$(PLATFORM).cfg

# =============================================================================

ifeq ($(DEBUG),1)
	CXXFLAGS += -g
	STRIP = :
else
	CXXFLAGS += -O3
endif


ifeq ($(STATIC),1)
	CXXFLAGS += -static
endif

CXXFLAGS_ALL = `$(PKGCONFIG) --cflags --static sdl2 vorbisfile vorbis theoradec`
LIBS_ALL = `$(PKGCONFIG) --libs --static sdl2 vorbisfile vorbis theoradec`

CXXFLAGS_ALL += $(CXXFLAGS) \
			   -DBASE_PATH='"$(BASE_PATH)"' \
			   --std=c++17 \
			   -fsigned-char

LDFLAGS_ALL = $(LDFLAGS)
LIBS_ALL += -pthread $(LIBS)

ifeq ($(PROFILE),1)
	CXXFLAGS_ALL += -pg -g -fno-inline-functions -fno-inline-functions-called-once -fno-optimize-sibling-calls -fno-default-inline
endif

ifeq ($(VERBOSE),0)
	CC := @$(CC)
	CXX := @$(CXX)
endif


INCLUDES  += \
	-I./RSDKv4/ \
	-I./RSDKv4/NativeObjects/ \
	-I./dependencies/all/asio/asio/include/ \
	-I./dependencies/all/stb-image/ \
	-I./dependencies/all/tinyxml2/ \
	-I./dependencies/all/theoraplay/

INCLUDES += $(LIBS)

# Main Sources
SOURCES = \
	RSDKv4/Animation	\
	RSDKv4/Audio		\
	RSDKv4/Collision	\
	RSDKv4/Debug		\
	RSDKv4/Drawing		\
	RSDKv4/Ini			\
	RSDKv4/Input		\
	RSDKv4/Math			\
	RSDKv4/ModAPI		\
	RSDKv4/Networking	\
	RSDKv4/Object		\
	RSDKv4/Palette		\
	RSDKv4/Reader		\
	RSDKv4/Renderer		\
	RSDKv4/RetroEngine	\
	RSDKv4/Scene		\
	RSDKv4/Scene3D		\
	RSDKv4/Script		\
	RSDKv4/Sprite		\
	RSDKv4/String		\
	RSDKv4/Text			\
	RSDKv4/Userdata		\
	RSDKv4/Video		\
	RSDKv4/main			\
	RSDKv4/NativeObjects/All					\
	dependencies/all/theoraplay/theoraplay		\
	dependencies/all/tinyxml2/tinyxml2			\
	RSDKv4/fcaseopen							\
#	RSDKv4/NativeObjects/AchievementDisplay		\
#	RSDKv4/NativeObjects/AchievementsButton		\
#	RSDKv4/NativeObjects/AchievementsMenu		\
#	RSDKv4/NativeObjects/BackButton				\
#	RSDKv4/NativeObjects/CWSplash				\
#	RSDKv4/NativeObjects/CreditText				\
#	RSDKv4/NativeObjects/DialogPanel			\
#	RSDKv4/NativeObjects/FadeScreen				\
#	RSDKv4/NativeObjects/InstructionsScreen		\
#	RSDKv4/NativeObjects/LeaderboardsButton		\
#	RSDKv4/NativeObjects/MenuBG					\
#	RSDKv4/NativeObjects/MenuControl			\
#	RSDKv4/NativeObjects/ModInfoButton			\
#	RSDKv4/NativeObjects/ModsButton				\
#	RSDKv4/NativeObjects/ModsMenu				\
#	RSDKv4/NativeObjects/MultiplayerButton		\
#	RSDKv4/NativeObjects/MultiplayerHandler		\
#	RSDKv4/NativeObjects/MultiplayerScreen		\
#	RSDKv4/NativeObjects/OptionsButton			\
#	RSDKv4/NativeObjects/OptionsMenu			\
#	RSDKv4/NativeObjects/PauseMenu				\
#	RSDKv4/NativeObjects/PlayerSelectScreen		\
#	RSDKv4/NativeObjects/PushButton				\
#	RSDKv4/NativeObjects/RecordsScreen			\
#	RSDKv4/NativeObjects/RetroGameLoop			\
#	RSDKv4/NativeObjects/SaveSelect				\
#	RSDKv4/NativeObjects/SegaIDButton			\
#	RSDKv4/NativeObjects/SegaSplash				\
#	RSDKv4/NativeObjects/SettingsScreen			\
#	RSDKv4/NativeObjects/StaffCredits			\
#	RSDKv4/NativeObjects/StartGameButton		\
#	RSDKv4/NativeObjects/SubMenuButton			\
#	RSDKv4/NativeObjects/TextLabel				\
#	RSDKv4/NativeObjects/TimeAttack				\
#	RSDKv4/NativeObjects/TimeAttackButton		\
#	RSDKv4/NativeObjects/TitleScreen			\
#	RSDKv4/NativeObjects/VirtualDPad			\
#	RSDKv4/NativeObjects/VirtualDPadM			\
#	RSDKv4/NativeObjects/ZoneButton

ifeq ($(RSDK_USE_NETWORKING), 0)
	CXXFLAGS_ALL += -DRETRO_USE_MOD_LOADER=$(RSDK_USE_NETWORKING)
endif

ifeq ($(RETRO_USE_HW_RENDER), 0)
	CXXFLAGS_ALL += -RETRO_USING_OPENGL=$(RETRO_USE_HW_RENDER)
endif

PKGSUFFIX ?= $(SUFFIX)

BINPATH = $(OUTDIR)/$(NAME)$(SUFFIX)
PKGPATH = $(OUTDIR)/$(NAME)$(PKGSUFFIX)

OBJECTS += $(addprefix $(OBJDIR)/, $(addsuffix .o, $(SOURCES)))

$(shell mkdir -p $(OUTDIR))
$(shell mkdir -p $(OBJDIR))

$(OBJDIR)/%.o: %.c
	@mkdir -p $(@D)
	@echo -n Compiling $<...
	$(CXX) -c $(CXXFLAGS_ALL) $(INCLUDES) $(DEFINES) $< -o $@
	@echo " Done!"

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(@D)
	@echo -n Compiling $<...
	$(CXX) -c $(CXXFLAGS_ALL) $(INCLUDES) $(DEFINES) $< -o $@
	@echo " Done!"

$(BINPATH): $(OBJDIR) $(OBJECTS)
	@echo -n Linking...
	$(CXX) $(CXXFLAGS_ALL) $(LDFLAGS_ALL) $(OBJECTS) -o $@ $(LIBS_ALL)
	@echo " Done!"
	$(STRIP) $@

ifeq ($(BINPATH),$(PKGPATH))
all: $(BINPATH)
else
all: $(PKGPATH)
endif

clean:
	rm -rf $(OBJDIR) && rm -rf $(BINPATH)
	strip Linux/WZ+
	mv WZ+ "WZ+ (Make)"
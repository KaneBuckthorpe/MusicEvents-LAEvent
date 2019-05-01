ARCHS := armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MusicEvents
MusicEvents_FILES = Event.xm
MusicEvents_LIBRARIES = activator
MusicEvents_CFLAGS = -fobjc-arc
MusicEvents_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

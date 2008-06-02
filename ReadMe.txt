
### cocos2d port to iPhone ###


===========================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0, Beta 6 release

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.3, iPhone OS 2.0, Beta 6 release

===========================================================================
PACKAGING LIST:

AppController.h
AppController.m
UIApplication's delegate class, i.e. the central controller of the application.

AudioSupport/Audio_Internal.h
This file is included for support purposes and isn't necessary for understanding this sample.

AudioSupport/SoundEngine.h
AudioSupport/SoundEngine.cpp
This C API is a sound engine intended for games and applications that want to do more than casual UI sounds playback e.g. background music track, multiple sound effects, stereo panning... while ensuring low-latency response at the same time.

GameView.h
GameView.m
Subclass of EAGLView that forwards taps to the application's controller.

OpenGLSupport/EAGLView.h
OpenGLSupport/EAGLView.m
Convenience class that wraps the CAEAGLLayer from CoreAnimation into a UIView subclass.

OpenGLSupport/OpenGL_Internal.h
This file is included for support purposes and isn't necessary for understanding this sample.

OpenGLSupport/Texture2D.h
OpenGLSupport/Texture2D.m
Convenience class that allows to create OpenGL 2D textures from images, text or raw data.

cocos2d/*
cocos2d files

main.m
This file is included for support purposes and isn't necessary for understanding this sample.

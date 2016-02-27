Cocos2D-ObjC
============

**PLEASE READ BEFORE POSTING AN ISSUE!**  
If in doubt, please post questions and comments in the forum  
[The Official Forum][3]  

This way, more users can learn from your experince.  
  
  
=====
Please note, that the official site has moved. Please update your bookmarks  
[The Official Site][1]  
[The Official Forum][3]  

[Cocos2D-ObjC][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iOS, Mac and Android.
It is based on the [Cocos2D][2] design, but instead of using Python it uses Swift and / or Objective-C.

Cocos2D-ObjC is:

  * Fast
  * Free
  * Lightweight
  * Modular
  * Easy to use
  * Community Supported


Creating New Projects
---------------------
For creating new projects you should use an official [Cocos2D Installer][5].

There is a rich GUI editor for Cocos2D app named SpriteBuilder. SpriteBuilder is, just like Cocos2D, free and open source. You can get SpriteBuilder from [spritebuilder.com](http://spritebuilder.com) or from the Mac App Store. Projects created using SpriteBuilder contains the complete Cocos2D source code, and after the project has been created using SpriteBuilder is optional.

SpriteBuilder also allows you to update the Cocos2D version in your project, to newest version, making it trivial to always keep you project updated to latest Cocos2D version.

You can find the full Cocos2D documentation and user guide at our [documentation page](http://cocos2d-objc.org/docs/).

**Important:**
Since 3.5 Cocos2D changed ideology a bit. First of all, Android support is gone. It happened due to Apportable company bankraptcy, they were providing the UIKit implementation for Android, but it broken since XCode 7.2. Android support is unlikely to be back. Now Cocos2D is fully open-oriented with rich Metal support and other cool features that are available only on Apple platform.

All releases will be incremental now. Even if backwards compatibility will broke it will be a matter of changing a few lines in code. Backwards compatibility are guaranteed for now.

**Changelog for 3.5 (Sits in README for clearing things up):**
   * Hacky templates are gone, official installer is introduced
   * Cocos2D is now running on native resolutions on all devices. 
   * XIB Launch screen are used by default.
   * All android-relative and caused-by-android code is gone.
   * Image assets support (enables user to load images with native content scale and also makes your app really small in size due to App Thinning technology).
   * 3D Touch support.
   * App thinning support.
   * CCTouch are gone, touch dispatching is gone too, so perfomance on this is much better. Native touches are now used instead.
   * CCTransition are now meant to be overriden. Creating custom trunstions is easy as ever. Small refactoring required - Rename CCTransition to CCDefaultTransition everywhere.
   * ObjectAL is not shipped in bundle with Cocos2D anymore, because it is marked as deprecated by Apple. You are free to choose now, which sound engine you prefer.
   * Chipmunk physics is an option now. There are still a lot of love paid for Box2D. You are not forced to use particular physics engine anymore. Chipmunk is still available and integrated, but served as extension.
   * CCLayoutBox takes transformations into account.
   * Mac compilation out-of-the-box is back.
   * TVOS support introduced.
   * Metal rendering back and is now working.
   * All tile map code is now an extension. There are a lot of better frameworks which can be used instead of cocos2d native tilemap code.
   * CCScrollView sends delegate messages while animating too.
   * A lot of nodes now moved to extension. Such as CCParallaxNode, CCPackages, CCParticles, CCClippingNode, CCMotionStreak etc. 
   * Cocos2D can be now used as a drop-in solution, no more husling with XCode subprojects etc.
   * Start-up code is reconsidireted. Unfortunately, we still have to use CCAppDelegate, but it will be gone in next release. `startScene` method is gone. Why? Because now you can stack scenes in the start-up, this allowing you, for example, launch a level from 3D touch shortcut with a stack level of two, and put `MainScene` into stack level 1. This won't break your app in any way, allowing all of buttons like "Home", "Back" etc working without any new code.
   * CCEffects are now served as extension.
   * SSZipArchive dependency is gone in default bundle.
   * SpriteBuilder is an option now. If you don't want to use it, there will be no related files.
   * CCTableView is improved.
   * New control is introduced in -ui: CCPotentioMeter.
   * Repo is generally cleaned.
   * Bug fixed for Siri dictation.
   * CCWarnings are fixed.
   * CCRenderTexture shader is now forwarded to sprite.

Features
-------------
   * Scene management (workflow)
   * Transitions between scenes
   * Sprites and Sprite Sheets
   * Effects: Lens, Ripple, Waves, Liquid, etc. *(Served as extension)*
   * Actions (behaviours):
     * Trasformation Actions: Move, Rotate, Scale, Fade, Tint, etc.
     * Composable actions: Sequence, Spawn, Repeat, Reverse
     * Ease Actions: Exp, Sin, Cubic, Elastic, etc.
     * Misc actions: CallFunc, OrbitCamera, Follow, Tween
   * Basic menus and buttons
   * Integrated with [Chipmunk][4] physics engine *(Served as extension)*
   * Particle system *(Served as extension)*
   * Fonts:
     * Fast font rendering using Fixed and Variable width fonts
     * Support for .ttf fonts
   * Tile Map support: Orthogonal, Isometric and Hexagonal *(Served as extension)*
   * Parallax scrolling *(Served as extension)*
   * Motion Streak *(Served as extension)*
   * Render To Texture *(Served as extension)*
   * Touch/Accelerometer on iOS
   * Touch/Mouse/Keyboard on Mac
   * Sound Engine support based on OpenAL *(Served as extension)*
   * Integrated Slow motion/Fast forward
   * Fast textures: PVR compressed and uncompressed textures
   * Point based: RetinaDisplay mode compatible
   * Language: Objective-C / Swift
   * Open Source Commercial Friendly: Compatible with open and closed source projects
   * Image assets support
   * TVOS support
   * App thinning support
   * 3D touch support
   * OpenGL ES 2.0 or Metal (iOS) / OpenGL 2.1 (Mac) based


Build Requirements
------------------

Mac OS X 10.9 (or newer), Xcode 7.0 (or newer)


Runtime Requirements
--------------------
  * iOS 6.0 (7.0 for Swift) or newer for iOS games
  * Snow Leopard (v10.6) or newer for Mac games


Running Tests
--------------------

1. Select the test you want from Xcode Scheme chooser

2. Then click on `Xcode → Product → Run`


Forum
-----
  * [Cocos2D-ObjC Forum][3]


Download from Github
--------------------

    $ git clone --recursive https://github.com/cocos2d/cocos2d-objc.git
    $ cd cocos2d-objc

[1]: http://cocos2d-objc.org "Cocos2D-ObjC Official Site"
[2]: http://www.cocos2d.org "cocos2d"
[3]: http://forum.cocos2d-objc.org "Cocos2D-ObjC Official Forum"
[4]: http://www.chipmunk-physics.net
[5]: https://github.com/s1ddok/CCProjectGenerator

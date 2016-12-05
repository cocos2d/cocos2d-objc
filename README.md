Cocos2D-ObjC
============

Want pure x-platform Swift? 
===============================

We experience rewrite in [this repository](https://github.com/s1ddok/Fiber2D).

**PLEASE READ BEFORE POSTING AN ISSUE!**  
If in doubt, please post questions and comments in the forum  
[The Official Forum][3]  

This way, more users can learn from your experince.  
  
  
=====
Please note, that the official site has moved. Please update your bookmarks  
[The Official Site][1]  
[The Official Forum][3]  

[Cocos2D-ObjC][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iOS, Mac and tvOS.
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

Documentation
---------------------
You can find the full Cocos2D documentation and user guide at our [documentation page](http://cocos2d-objc.org/docs/).

Important:
---------------------
Version 3.5 is introduced.
[See release notes](https://github.com/cocos2d/cocos2d-objc/wiki/Cocos2D-3.5-Release-notes)

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

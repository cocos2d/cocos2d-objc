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
  * Easy to use
  * Community Supported


Creating New Projects
---------------------
We are in the process of adding a stand alone installer to Cocos2D-Objc. A temporary template can be found [here][5]

An alternative approach, is to use SpriteBuilder: 

New Cocos2D projects can be created with SpriteBuilder. SpriteBuilder is, just like Cocos2D, free and open source. You can get SpriteBuilder from [spritebuilder.com](http://spritebuilder.com) or from the Mac App Store. Projects created using SpriteBuilder contains the complete Cocos2D source code, and after the project has been created using SpriteBuilder is optional.

SpriteBuilder also allows you to update the Cocos2D version in your project, to newest version, making it trivial to always keep you project updated to latest Cocos2D version.

You can find the full Cocos2D documentation and user guide at our [documentation page](http://cocos2d-objc.org/docs/).

Features
-------------
   * Scene management (workflow)
   * Transitions between scenes
   * Sprites and Sprite Sheets
   * Effects: Lens, Ripple, Waves, Liquid, etc.
   * Actions (behaviours):
     * Trasformation Actions: Move, Rotate, Scale, Fade, Tint, etc.
     * Composable actions: Sequence, Spawn, Repeat, Reverse
     * Ease Actions: Exp, Sin, Cubic, Elastic, etc.
     * Misc actions: CallFunc, OrbitCamera, Follow, Tween
   * Basic menus and buttons
   * Integrated with [Chipmunk][4] physics engine
   * Particle system
   * Fonts:
     * Fast font rendering using Fixed and Variable width fonts
     * Support for .ttf fonts
   * Tile Map support: Orthogonal, Isometric and Hexagonal
   * Parallax scrolling
   * Motion Streak
   * Render To Texture
   * Touch/Accelerometer on iOS
   * Touch/Mouse/Keyboard on Mac
   * Sound Engine support (CocosDenshion library) based on OpenAL
   * Integrated Slow motion/Fast forward
   * Fast textures: PVR compressed and uncompressed textures
   * Point based: RetinaDisplay mode compatible
   * Language: Objective-C
   * Open Source Commercial Friendly: Compatible with open and closed source projects
   * OpenGL ES 2.0 (iOS) / OpenGL 2.1 (Mac) based


Build Requirements
------------------

Mac OS X 10.6 (or newer), Xcode 4.2 (or newer)


Runtime Requirements
--------------------
  * iOS 6.0 or newer for iOS games
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
[5]: https://github.com/slembcke/UnofficialCocos2DTemplate

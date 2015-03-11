Cocos2D-SpriteBuilder
=====================

[Cocos2D-SpriteBuilder][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iOS, Mac and Android.
It is based on the [Cocos2D][2] design, but instead of using Python it uses Swift or Objective-C.

Cocos2D-SpriteBuilder is:

  * Fast
  * Free
  * Easy to use
  * Community Supported


Creating New Projects
---------------------

New Cocos2D projects are created with SpriteBuilder. SpriteBuilder is, just like Cocos2D, free and open source. You can get SpriteBuilder from [spritebuilder.com](http://spritebuilder.com) or from the Mac App Store. Projects created using SpriteBuilder contains the complete Cocos2D source code, and after the project has been created using SpriteBuilder is optional.

SpriteBuilder also allows you to update the Cocos2D version in your project, to newest version, making it trivial to always keep you project updated to latest Cocos2D version.

You can find the full Cocos2D documentation and user guide at our [documentation page](http://cocos2d.spritebuilder.com/docs).

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
  * [Cocos2D-SpriteBuilder Forum][3]


Download from Github
--------------------

    $ git clone --recursive https://github.com/cocos2d/cocos2d-spritebuilder.git
    $ cd cocos2d-spritebuilder

[1]: http://cocos2d.spritebuilder.com "Cocos2D-SpriteBuilder"
[2]: http://www.cocos2d.org "cocos2d"
[3]: http://forum.cocos2d-swift.org "Cocos2D-SpriteBuilder forum"
[4]: http://www.chipmunk-physics.net

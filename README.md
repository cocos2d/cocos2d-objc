Cocos2D Swift
=============

[Cocos2D-Swift][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iOS, Mac and Android.
It is based on the [Cocos2D][2] design, but instead of using Python it uses Swift or Objective-C.

Cocos2D Swift is:

  * Fast
  * Free
  * Easy to use
  * Community Supported


Creating New Projects
---------------------

New Cocos2D projects are created with SpriteBuilder. SpriteBuilder is, just like Cocos2D, free and open source. You can get SpriteBuilder from [spritebuilder.com](http://spritebuilder.com) or from the Mac App Store. Projects created using SpriteBuilder contains the complete Cocos2D source code, and after the project has been created using SpriteBuilder is optional.

You can find the full Cocos2D documentation and user guide at our [documentation page](http://www.cocos2d-swift.org/docs).

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
   * Integrated with [Chipmunk][6] physics engine
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
  * [Cocos2D User Forum][4]


Download from Github
--------------------

    $ git clone git://github.com/cocos2d/cocos2d-iphone.git
    $ cd cocos2d-iphone
    $ git checkout develop-v3
    $ git submodule update --init


[1]: http://www.cocos2d-iphone.org "cocos2d for iPhone"
[2]: http://www.cocos2d.org "cocos2d"
[3]: http://www.cocos2d-iphone.org/wiki/doku.php/faq#i_found_a_bug_i_have_an_enhancement_proposal_what_should_i_do "contributing to cocos2d"
[4]: http://forum.cocos2d-swift.org "cocos2d for iPhone forum"
[5]: https://github.com/cocos2d/cocos2d-iphone/archive/develop-v3.zip
[6]: http://www.chipmunk-physics.net

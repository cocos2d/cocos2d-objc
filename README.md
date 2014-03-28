<img src="http://www.cocos2d-iphone.org/blog/wp-content/uploads/2014/03/angry_small.png">

cocos2d for iPhone
==================

[cocos2d for iPhone][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iPod Touch, iPhone, iPad and Mac OS X.
It is based on the [cocos2d][2] design, but instead of using Python it uses Objective-C.

cocos2d for iPhone is:

  * Fast
  * Free
  * Easy to use
  * Community Supported


Templates Installation
-----------------------

1. Download the code from [Github][5]

2. Run the install script by executing `./install.sh` in Terminal  
   (for more help and usage execute `./install.sh -h`)  

    ```bash
    Example:    
    $ cd cocos2d-iphone # change directory to cocos2d-iphone
    $ ./install.sh 	# execute the template installer script
    ```

3. And then open `Xcode → New → New Project → cocos2d v3.x`

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
  * iOS 5.0 or newer for iOS games
  * Snow Leopard (v10.6) or newer for Mac games


Running Tests
--------------------

1. Select the test you want from Xcode Scheme chooser

2. Then click on `Xcode → Product → Run`


Contributing to the Project
--------------------------------

Did you find a bug? Do you have feature request? Do you want to merge a feature?

  * [contributing to cocos2d][3]

Forum
-----
  * [cocos2d for iphone forum][4]


Download from Github
--------------------

    $ git clone git://github.com/cocos2d/cocos2d-iphone.git
    $ cd cocos2d-iphone
    $ git checkout develop-v3
    $ git submodule update --init


[1]: http://www.cocos2d-iphone.org "cocos2d for iPhone"
[2]: http://www.cocos2d.org "cocos2d"
[3]: http://www.cocos2d-iphone.org/wiki/doku.php/faq#i_found_a_bug_i_have_an_enhancement_proposal_what_should_i_do "contributing to cocos2d"
[4]: http://www.cocos2d-iphone.org/forum "cocos2d for iPhone forum"
[5]: https://github.com/cocos2d/cocos2d-iphone/archive/develop-v3.zip
[6]: http://www.chipmunk-physics.net

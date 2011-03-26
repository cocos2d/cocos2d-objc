cocos2d for iPhone
==================

[cocos2d for iPhone][1] is a framework for building 2D games, demos, and other
graphical/interactive applications for iPod Touch, iPhone, iPad and Mac.
It is based on the [cocos2d][2] design but instead of using python it, uses objective-c.


Main features
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
   * Integrated with physics engines: Box2d and Chipmunk
   * Particle system
   * Fonts:
     * Fast font rendering using Fixed and Variable width fonts
     * Support for .ttf fonts
   * Texture Atlas support
   * Tile Map support: Orthogonal, Isometric and Hexagonal
   * Parallax scrolling
   * Motion Streak
   * Render To Texture
   * High Score server (cocosLive library)
   * Touch/Accelerometer on iOS
   * Touch/Mouse/Keyboard on Mac
   * Portrait and Landscape mode on iOS
   * Sound Engine support (CocosDenshion library) based on OpenAL
   * Integrated Pause/Resume
   * Integrated Slow motion/Fast forward
   * Fast textures: PVR compressed and uncompressed textures
   * Point based: iPhone4 + RetinaDisplay mode compatible
   * Language: objective-c
   * Open Source: Compatible with open and closed source projects
   * OpenGL ES 1.1 (iOS) / OpenGL 1.5 based (Mac)


This library does not work with the toolchain, but it should be easy to port it to it.


Build Requirements
------------------

Mac OS X 10.6, Xcode 3.2.3 (or newer)


Runtime Requirements
--------------------
  * iOS 3.0 or newer for iOS games
  * Snow Leopard (v10.5) or newer for Mac games


Files and Folders
-----------------

  * cocos2d/  
     core files and folders of cocos2d
  * cocoslive/  
     high score client library
  * CocosDenshion/  
     sound engine library
  * tests/  
     tests, demo examples
  * templates/
     folder that contains the Xcode templates
  * experimental/  
     experimental stuff
  * external/  
     3rd party libraries used by cocos2d or any other project.
     * Chipmunk/: physics library
     * Box2d/: physics library
     * TouchJSON/: JSON parser
     * Tremor/: OGG audio decoder


How to run the tests
--------------------

Xcode -> View -> Customize toolbar  
Then, drag "Active Target" and "Active Executable" to your top project tool bar.
Select the test you want to view in both drop downs and hit Build and Go.

How to start a new game
-----------------------

Run the 'install-templates.sh' script:
    $ cd cocos2d-iphone
    $ ./install-templates.sh -u -f
And then open XCode -> New Project -> User Templates -> cocos2d


How to contribute to the project
--------------------------------

Did you find a bug ? Do you have feature request ? Do you want to merge a feature ?

  * [contributing to cocos2d][3]


[1]: http://www.cocos2d-iphone.org "cocos2d for iPhone"
[2]: http://www.cocos2d.org "cocos2d"
[3]: http://www.cocos2d-iphone.org/wiki/doku.php/faq#i_found_a_bug_i_have_an_enhancement_proposal_what_should_i_do "contributing to cocos2d"

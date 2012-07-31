/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2011      Zynga Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

var cc = cc = cc || {};

/**
 @brief    The cocos2d Application.

 The reason for implement as private inheritance is to hide some interface call by CCDirector.
 */
cc.AppDelegate = cc.Application.extend({
    ctor:function () {
        this._super();
    },
    /**
     @brief    Implement for initialize OpenGL instance, set source path, etc...
     */
    initInstance:function () {
        return true;
    },

    /**
     @brief    Implement CCDirector and CCScene init code here.
     @return true    Initialize success, app continue.
     @return false   Initialize failed, app terminate.
     */
    applicationDidFinishLaunching:function () {
        // initialize director
        var pDirector = cc.Director.getInstance();

        // enable High Resource Mode(2x, such as iphone4) and maintains low resource on other devices.
//     pDirector->enableRetinaDisplay(true);

        // turn on display FPS
        pDirector.setDisplayFPS(true);

        // pDirector->setDeviceOrientation(kCCDeviceOrientationLandscapeLeft);

        // set FPS. the default value is 1.0/60 if you don't call this
        pDirector.setAnimationInterval(1.0 / 60);

        // create a scene. it's an autorelease object
        var pScene = SysMenu.scene();
        //var pScene = GameLayer.scene();

        // run
        pDirector.runWithScene(pScene);
        return true;
    },

    /**
     @brief  The function be called when the application enter background
     @param  the pointer of the application
     */
    applicationDidEnterBackground:function () {
        cc.Director.getInstance().pause();
    },

    /**
     @brief  The function be called when the application enter foreground
     @param  the pointer of the application
     */
    applicationWillEnterForeground:function () {
        cc.Director.getInstance().resume();
    }
});

//
// http://www.cocos2d-iphone.org
// http://www.cocos2d-html5.org
// http://www.cocos2d-x.org
//
// Javascript + cocos2d actions tests
//

//require("jsb_constants.js");

director = cc.Director.getInstance();

cc.log("**** 1 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

//
// Simple subclass
//

cc.LayerGradient.extend = function (prop) {
    var _super = this.prototype;

    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
    fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;

    // Copy the properties over onto the new prototype
    for (var name in prop) {
        // Check if we're overwriting an existing function
        prototype[name] = typeof prop[name] == "function" &&
            typeof _super[name] == "function" && fnTest.test(prop[name]) ?
            (function (name, fn) {
                return function () {
                    var tmp = this._super;

                    // Add a new ._super() method that is the same method
                    // but on the super-class
                    this._super = _super[name];

                    // The method only need to be bound temporarily, so we
                    // remove it when we're done executing
                    var ret = fn.apply(this, arguments);
                    this._super = tmp;

                    return ret;
                };
            })(name, prop[name]) :
            prop[name];
    }

    // The dummy class constructor
    function Class() {
        // All construction is actually done in the init method
        if (!initializing && this.ctor)
            this.ctor.apply(this, arguments);
    }

    // Populate our constructed prototype object
    Class.prototype = prototype;

    // Enforce the constructor to be what we expect
    Class.prototype.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;

    return Class;
};

cc.log("**** 3 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

//
// Base Layer
//
var BaseLayer = cc.LayerGradient.extend({

    ctor:function () {
                                
        var p = new cc.LayerGradient();
        __associateObjWithNative(this, p);
        this.init(cc.c4b(0, 0, 0, 255), cc.c4b(0, 128, 255, 255));

        cc.log("**** 1 ****");
        __jsc__.dumpRoot();
        __jsc__.garbageCollect();
    },

    onEnter:function () {
        // DO NOT CALL this._super()
//        this._super();

        cc.log("**** 7 ****");
        __jsc__.dumpRoot();
        __jsc__.garbageCollect();
    },

});

cc.log("**** 4 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

//------------------------------------------------------------------
//
// Playground 
//
//------------------------------------------------------------------
var Playground = BaseLayer.extend({
    onEnter:function () {
        this._super();

        cc.log("Playground onEnter");
    },

    title:function () {
        return "Testing Accelerometer";
    },

    subtitle:function () {
        return "See console on device";
    },
    code:function () {
        return "";
    }
});


cc.log("**** 5 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();

var scene = cc.Scene.create();
var layer = new Playground();
scene.addChild( layer );
director.runWithScene( scene );

cc.log("**** 5 ****");
__jsc__.dumpRoot();
__jsc__.garbageCollect();


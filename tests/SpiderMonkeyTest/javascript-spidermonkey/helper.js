// cocos2d Helper
//function ccp(x, y)
//{
//	var floats = new Float32Array(2);
//	floats[0] = x;
//	floats[1] = y;
//
//	return floats;
//}

function ccc3(r, g, b)
{
	var colors = new Uint8Array(3)
	colors[0] = r;
	colors[1] = g;
	colors[2] = b;

	return colors;
}

function ccc4b(r, g, b, a)
{
	var colors = new Uint8Array(4)
	colors[0] = r;
	colors[1] = g;
	colors[2] = b;
	colors[3] = a;

	return colors;
}

function ccc4f(r, g, b, a)
{
	var colors = new Float32Array(4)
	colors[0] = r;
	colors[1] = g;
	colors[2] = b;
	colors[3] = a;

	return colors;
}

// From: http://stackoverflow.com/questions/332422/how-do-i-get-the-name-of-an-objects-type-in-javascript
function type(obj){
    return Object.prototype.toString.call(obj).match(/^\[object (.*)\]$/)[1]
}
/* Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 */
// Inspired by base2 and Prototype
// var cc = cc = cc || {};

function copy_properties( parent, child ) {
	for( name in parent ) {
		child[name] = parent[name];
	}
	child['_super'] = parent;
}

(function () {
    var initializing = false, fnTest = /xyz/.test(function () {
        xyz;
    }) ? /\b_super\b/ : /.*/;

    // Create a new Class that inherits from this Class
	Object.prototype.extend = function (prop) {
        var _super = this.prototype;

        // Instantiate a base Class (but only create the instance,
        // don't run the init constructor)
        initializing = true;
        var prototype = new this();

        var t = type(prototype);
        if( t == 'Object' ) {
            prototype['__nativeObject'] = _super;
        } else {
            prototype['__nativeObject'] = prototype;
        }
        initializing = false;

        // Copy the properties over onto the new prototype
        for (var name in prop) {
            // Check if we're overwriting an existing function
            prototype[name] = typeof prop[name] == "function" &&
                typeof _super[name] == "function" && fnTest.test(prop[name]) ?
                (function (name, fn) {
                    return function () {
                        var tmp = this._super;

                        // Add a new ._super() method that is the same method
                        // but on the super-Class
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

        // The dummy Class constructor
        function Class() {
            // All construction is actually done in the init method
			if (!initializing && this.ctor) {
                this.ctor.apply(this, arguments);
			}
        }

        // Populate our constructed prototype object
        Class.prototype = prototype;

        // Enforce the constructor to be what we expect
        Class.prototype.constructor = Class;

        // And make this Class extendable
        Class.extend = arguments.callee;

        //add implementation method
        Class.implement = function (prop) {
            for (var name in prop) {
                prototype[name] = prop[name];
            }
        };

        return Class;
    };
})();


//
// Google "subclasses"
// borrowed from closure library
//
var goog = goog || {}; // Check to see if already defined in current scope
goog.inherits = function (childCtor, parentCtor) {
	/** @constructor */
	function tempCtor() {};
	tempCtor.prototype = parentCtor.prototype;
	childCtor.superClass_ = parentCtor.prototype;
	childCtor.prototype = new tempCtor();
	childCtor.prototype.constructor = childCtor;

	// Copy "static" method, but doesn't generate subclasses.
//	for( var i in parentCtor ) {
//		childCtor[ i ] = parentCtor[ i ];
//	}
};
goog.base = function(me, opt_methodName, var_args) {
	var caller = arguments.callee.caller;
	if (caller.superClass_) {
		// This is a constructor. Call the superclass constructor.
		ret =  caller.superClass_.constructor.apply( me, Array.prototype.slice.call(arguments, 1));

		// XXX: SpiderMonkey bindings extensions
		__associateObjWithNative( me, ret );
		return ret;
	}

	var args = Array.prototype.slice.call(arguments, 2);
	var foundCaller = false;
	for (var ctor = me.constructor;
		 ctor; ctor = ctor.superClass_ && ctor.superClass_.constructor) {
		if (ctor.prototype[opt_methodName] === caller) {
			foundCaller = true;
		} else if (foundCaller) {
			return ctor.prototype[opt_methodName].apply(me, args);
		}
	}

	// If we did not find the caller in the prototype chain,
	// then one of two things happened:
	// 1) The caller is an instance method.
	// 2) This method was not called by the right caller.
	if (me[opt_methodName] === caller) {
		return me.constructor.prototype[opt_methodName].apply(me, args);
	} else {
		throw Error(
					'goog.base called from a method of one name ' +
					'to a method of a different name');
	}
};

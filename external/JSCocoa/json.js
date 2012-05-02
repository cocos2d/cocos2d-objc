
	// String JSON method
	String.prototype.toJSON = function () { return this }

	// Javascript JSON methods for native classes
	//	These need to return Javascript values, not boxed ObjC objects
	class_add_js_function(NSNumber,		'toJSON', function ()	{ return this.valueOf() } )
	class_add_js_function(NSDate,		'toJSON', function ()	{ return String(this.description) } )
	class_add_js_function(NSArray,		'toJSON', function ()	{ 
				var r = []
				for (var i=0; i<this.length; i++)
					r.push(this[i].toJSON())
				return r
			} )
	class_add_js_function(NSDictionary,	'toJSON', function ()	{ 
				var r = {}
				var keys = Object.keys(this)
				for (var i=0; i<keys.length; i++)
					r[keys[i]] = this[keys[i]].toJSON()
				return r
			} )

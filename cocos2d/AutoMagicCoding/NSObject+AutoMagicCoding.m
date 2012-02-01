//
//  NSObject+AutoMagicCoding.m
//  AutoMagicCoding
//  ( https://github.com/psineur/NSObject-AutomagicCoding/ )
//
//   31.08.11.
//  Copyright 2011 Stepan Generalov.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "NSObject+AutoMagicCoding.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "UIKit/UIKit.h"
#import "CoreGraphics/CoreGraphics.h"

#define NSPoint CGPoint
#define NSSize CGSize
#define NSRect CGRect

#define NSPointFromString CGPointFromString
#define NSSizeFromString CGSizeFromString
#define NSRectFromString CGRectFromString

#define pointValue CGPointValue
#define sizeValue CGSizeValue
#define rectValue CGRectValue

#define NSStringFromPoint NSStringFromCGPoint
#define NSStringFromSize NSStringFromCGSize
#define NSStringFromRect NSStringFromCGRect

#define NSVALUE_ENCODE_POINT(__P__) [NSValue valueWithCGPoint:__P__]
#define NSVALUE_ENCODE_SIZE(__S__) [NSValue valueWithCGSize:__S__]
#define NSVALUE_ENCODE_RECT(__R__) [NSValue valueWithCGRect:__R__]

#else

#define NSVALUE_ENCODE_POINT(__P__) [NSValue valueWithPoint:__P__]
#define NSVALUE_ENCODE_SIZE(__S__) [NSValue valueWithSize:__S__]
#define NSVALUE_ENCODE_RECT(__R__) [NSValue valueWithRect:__R__]

#endif

NSString *const AMCVersion = @"1.1";
NSString *const AMCEncodeException = @"AMCEncodeException";
NSString *const AMCDecodeException = @"AMCDecodeException";
NSString *const AMCKeyValueCodingFailureException = @"AMCKeyValueCodingFailureException";

@implementation NSObject (AutoMagicCoding)

+ (BOOL) AMCEnabled
{
    return NO;
}

#pragma mark Decode/Create/Init

+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict
{
    if (![aDict isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *className = [aDict objectForKey: kAMCDictionaryKeyClassName];
    if( ![className isKindOfClass:[NSString class]] )
        return nil;
    
    Class rClass = NSClassFromString(className);
    if ( rClass && [rClass instancesRespondToSelector:@selector(initWithDictionaryRepresentation:) ] )
    {
        id instance = [[[rClass alloc] initWithDictionaryRepresentation: aDict] autorelease];
        return instance;
    }
    
    return nil;
}

- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    // NSObject#init simply returns self, so we don't need to call any init here.
    // See NSObject Class Reference if you don't trust me ;)
    
    @try
    {
        
    if (aDict)
    {
        NSArray *keysForValues = [self AMCKeysForDictionaryRepresentation];
        for (NSString *key in keysForValues)
        {
            id value = [aDict valueForKey: key];
            if (value)
            {
                AMCFieldType fieldType = [self AMCFieldTypeForValueWithKey: key];
                objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
                if ( kAMCFieldTypeStructure == fieldType)
                {
                    NSValue *structValue = [self AMCDecodeStructFromString: (NSString *)value withName: AMCPropertyStructName(property)];
                    [self setValue: structValue forKey: key];
                }
                else
                {
                    id class = AMCPropertyClass(property);
                    value = AMCDecodeObject(value, fieldType, class);
                    [self setValue:value forKey: key];
                }
            }
        }
    }
        
    }
    
    @catch (NSException *exception) {
        [self release];
        
#ifdef AMC_NO_THROW
        return nil;
#else
        @throw exception;
#endif
    }
    
    return self;
}

- (void) loadValueForKey:(NSString *)key fromDictionaryRepresentation: (NSDictionary *) aDict
{
    @try
    {
        if (aDict && key)
        {
            id value = [aDict valueForKey: key];
            if (value)
            {
                AMCFieldType fieldType = [self AMCFieldTypeForValueWithKey: key];
                objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
                if ( kAMCFieldTypeStructure == fieldType)
                {
                    NSValue *structValue = [self AMCDecodeStructFromString: (NSString *)value withName: AMCPropertyStructName(property)];
                    [self setValue: structValue forKey: key];
                }
                else
                {
                    id class = AMCPropertyClass(property);
                    value = AMCDecodeObject(value, fieldType, class);
                    [self setValue:value forKey: key];
                }
            }
        }
    }
    
    @catch (NSException *exception) {
        
#ifdef AMC_NO_THROW
#else
        @throw exception;
#endif
    }
}

#pragma mark Encode/Save

- (NSDictionary *) dictionaryRepresentation
{
    NSArray *keysForValues = [self AMCKeysForDictionaryRepresentation];
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithCapacity:[keysForValues count] + 1];
    
    @try
    {
        for (NSString *key in keysForValues)
        {
            // Save our current isa, to restore it after using valueForKey:, cause
            // it can corrupt it sometimes (sic!), when getting ccColor3B struct via 
            // property/method. (Issue #19)
            Class oldIsa = isa;
            
            // Get value with KVC as usual.
            id value = [self valueForKey: key];
            
            if (oldIsa != isa)
            {
#ifdef AMC_NO_THROW
                NSLog(@"ATTENTION: isa was corrupted, valueForKey: %@ returned %@ It can be garbage!", key, value);
                
#else 
                NSException *exception = [NSException exceptionWithName: AMCKeyValueCodingFailureException 
                                                                 reason: [NSString stringWithFormat:@"ATTENTION: isa was corrupted, valueForKey: %@ returned %@ It can be garbage!", key, value]
                                                               userInfo: nil ];
                @throw exception;
#endif
                
                // Restore isa.
                isa = oldIsa;
            }
            
            AMCFieldType fieldType = [self AMCFieldTypeForValueWithKey: key]; 
            
            if ( kAMCFieldTypeStructure == fieldType)
            {
                objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
                value = [self AMCEncodeStructWithValue: value withName: AMCPropertyStructName(property)];
            }
            else
            {
                value = AMCEncodeObject(value, fieldType);
            }
            
            // Scalar or struct - simply use KVC.                       
            [aDict setValue:value forKey: key];
        }
        
        [aDict setValue:[self className] forKey: kAMCDictionaryKeyClassName];
    }
    @catch (NSException *exception) {
#ifdef AMC_NO_THROW
        return nil;
#else
        @throw exception;
#endif
    }
    
    return aDict;
}


#pragma mark Info for Serialization

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    // Array that will hold properties names.
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: 0];
    
    // Go through superClasses from self class to NSObject to get all inherited properties.
    id curClass = [self class];
    while (1) 
    {        
        // Stop on NSObject.
        if (curClass && curClass == [NSObject class])
            break;
        
        // Use objc runtime to get all properties and return their names.
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(curClass, &outCount);
        
        // Reverse order of curClass properties, cause we will return reversed array.
        for (int i = outCount - 1; i >= 0; --i)
        {
            objc_property_t curProperty = properties[i];
            const char *name = property_getName(curProperty);
            
            NSString *propertyKey = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            [array addObject: propertyKey];        
        }
        
        if (properties)
            free(properties);
        
        // Next.
        curClass = [curClass superclass];        
    }
    
    id result = [[array reverseObjectEnumerator] allObjects];
    
    return result;
}

- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey
{
    // isAutoMagicCodingEnabled == YES? Then it's custom object.
    objc_property_t property = class_getProperty([self class], [aKey cStringUsingEncoding:NSUTF8StringEncoding]);
    id class = AMCPropertyClass(property);
    
    if ([class AMCEnabled])
        return kAMCFieldTypeCustomObject;
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }
    
    // Is it a structure?
    NSString *structName = AMCPropertyStructName(property);
    if (structName)
        return kAMCFieldTypeStructure;
    
    // Otherwise - it's a scalar or PLIST-Compatible object (i.e. NSString)
    return kAMCFieldTypeScalar;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (NSString *) className
{
    const char* name = class_getName([self class]);
    
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

+ (NSString *) className
{
    const char* name = class_getName([self class]);
    
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

#endif

#pragma mark Structure Support

- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName 
{    
    // valueForKey: never returns CGPoint, CGRect, etc - it returns NSPoint, NSRect stored in NSValue instead.
    // This is why here was made no difference between struct names such CGP
    
    if ([structName isEqualToString:@"CGPoint"] || [structName isEqualToString:@"NSPoint"])
    {
        NSPoint p = NSPointFromString(value);
        
        return NSVALUE_ENCODE_POINT(p);
    }
    else if ([structName isEqualToString:@"CGSize"] || [structName isEqualToString:@"NSSize"])
    {
        NSSize s = NSSizeFromString(value);
        
        return NSVALUE_ENCODE_SIZE(s);
    }
    else if ([structName isEqualToString:@"CGRect"] || [structName isEqualToString:@"NSRect"])
    {
        NSRect r = NSRectFromString(value);
        
        return NSVALUE_ENCODE_RECT(r);
    }
   
    if (!structName)
        structName = @"(null)";
    NSException *exception = [NSException exceptionWithName: AMCDecodeException 
                                                     reason: [NSString stringWithFormat:@"AMCDecodeException: %@ is unsupported struct.", structName]
                                                   userInfo: nil ];
    
    @throw exception;
    
    return nil;
}

- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName
{
    // valueForKey: never returns CGPoint, CGRect, etc - it returns NSPoint, NSRect stored in NSValue instead.
    // This is why here was made no difference between struct names such CGPoint & NSPoint.
    
    if ( [structName isEqualToString:@"CGPoint"] || [structName isEqualToString:@"NSPoint"])
    {
        NSPoint point = [structValue pointValue];
        
        return NSStringFromPoint(point);
    }
    else if ( [structName isEqualToString:@"CGSize"] || [structName isEqualToString:@"NSSize"])
    {
        NSSize size = [structValue sizeValue];
        
        return NSStringFromSize(size);
    }
    else if ( [structName isEqualToString:@"CGRect"] || [structName isEqualToString:@"NSRect"])
    {
        NSRect rect = [structValue rectValue];
        
        return NSStringFromRect(rect);
    }
    
    if (!structName)
        structName = @"(null)";
    NSException *exception = [NSException exceptionWithName: AMCEncodeException 
                                                     reason: [NSString stringWithFormat:@"AMCEncodeException: %@ is unsupported struct.", structName] 
                                                   userInfo: nil ];
    
    @throw exception;
    
    return nil;
}

@end


#pragma mark Helper Functions

id AMCPropertyClass (objc_property_t property)
{
    if (!property)
        return nil;
    
    const char *attributes = property_getAttributes(property);
    char *classNameCString = strstr(attributes, "@\"");
    if ( classNameCString )
    {
        classNameCString += 2; //< skip @" substring
        NSString *classNameString = [NSString stringWithCString:classNameCString encoding:NSUTF8StringEncoding];
        NSRange range = [classNameString rangeOfString:@"\""];
        
        classNameString = [classNameString substringToIndex: range.location];
        
        id class = NSClassFromString(classNameString);
        return class;
    }
    
    return nil;
}

NSString *AMCPropertyStructName(objc_property_t property)
{
    if (!property)
        return nil;
    
    const char *attributes = property_getAttributes(property);
    char *structNameCString = strstr(attributes, "T{");
    if ( structNameCString )
    {
        structNameCString += 2; //< skip T{ substring
        NSString *structNameString = [NSString stringWithCString:structNameCString encoding:NSUTF8StringEncoding];
        NSRange range = [structNameString rangeOfString:@"="];
        
        structNameString = [structNameString substringToIndex: range.location];
        
        return structNameString;
    }
    
    return nil;
}

BOOL classInstancesRespondsToAllSelectorsInProtocol(id class, Protocol *p )
{
    unsigned int outCount = 0;
    struct objc_method_description *methods = NULL;
    
    methods = protocol_copyMethodDescriptionList( p, YES, YES, &outCount);
    
    for (unsigned int i = 0; i < outCount; ++i)
    {
        SEL selector = methods[i].name;
        if (![class instancesRespondToSelector: selector])
        {
            if (methods)
                free(methods);
            methods = NULL;
            
            return NO;
        }
    }
        
    if (methods)
        free(methods);
    methods = NULL;
    
    return YES;
}

id AMCDecodeObject (id value, AMCFieldType fieldType, id collectionClass )
{
    switch (fieldType) 
    {
            
        // Object as it's representation - create new.
        case kAMCFieldTypeCustomObject:
        {
            id object = [NSObject objectWithDictionaryRepresentation: (NSDictionary *) value];
            
            // Here was following code:
            // if (object)
            //    value = object;
            //
            // It was replaced with this one:
            
            value = object;
            
            // To pass -testIntToObjectDecode added in b5522b23a4b484359dca32ddfd38e9dff51bc853
            // In that test dictionaryRepresentation was modified and NSNumber (kAMCFieldTypeScalar)
            // was set to field with type kAMCFieldTypeCustomObject.
            // So there was NSNumber object set instead of Bar in that test.
            // It's possible to modify dictionaryRepresentation so, that one custom object
            // will be set instead of other custom object, but if -objectWithDictionaryRepresentation 
            // returns nil - that definetly can't be set as customObject.
            
        }
        break;
            
            
        case kAMCFieldTypeCollectionArray:
        case kAMCFieldTypeCollectionArrayMutable:
        {
            // Create temporary array of all objects in collection.
            id <AMCArrayProtocol> srcCollection = (id <AMCArrayProtocol> ) value;
            NSMutableArray *dstCollection = [NSMutableArray arrayWithCapacity:[srcCollection count]];
            for (unsigned int i = 0; i < [srcCollection count]; ++i)
            {
                id curEncodedObjectInCollection = [srcCollection objectAtIndex: i];
                id curDecodedObjectInCollection = AMCDecodeObject( curEncodedObjectInCollection, AMCFieldTypeForEncodedObject(curEncodedObjectInCollection), nil );
                [dstCollection addObject: curDecodedObjectInCollection];
            }
            
            // Get Collection Array Class from property and create object
            id class = collectionClass;
            if (!collectionClass)
            {
                if (kAMCFieldTypeCollectionArray)
                    class = [NSArray class];
                else
                    class = [NSMutableArray class];
            }
            
            id <AMCArrayProtocol> object = (id <AMCArrayProtocol> )[class alloc];
            @try 
            {
            object = [object initWithArray: dstCollection];
            }
            @finally {
                [object autorelease];
            }
            
            if (object)
                value = object;
        }
            break;
            
        case kAMCFieldTypeCollectionHash:
        case kAMCFieldTypeCollectionHashMutable:
        {
            // Create temporary array of all objects in collection.
            NSObject <AMCHashProtocol> *srcCollection = (NSObject <AMCHashProtocol> *) value;
            NSMutableDictionary *dstCollection = [NSMutableDictionary dictionaryWithCapacity:[srcCollection count]];
            for (NSString *curKey in [srcCollection allKeys])
            {
                id curEncodedObjectInCollection = [srcCollection valueForKey: curKey];
                id curDecodedObjectInCollection = AMCDecodeObject( curEncodedObjectInCollection, AMCFieldTypeForEncodedObject(curEncodedObjectInCollection), nil );
                [dstCollection setObject: curDecodedObjectInCollection forKey: curKey];
            }
            
            // Get Collection Array Class from property and create object
            id class = collectionClass;
            if (!collectionClass)
            {
                if (kAMCFieldTypeCollectionArray)
                    class = [NSDictionary class];
                else
                    class = [NSMutableDictionary class];
            }
            
            id <AMCHashProtocol> object = (id <AMCHashProtocol> )[class alloc];
            @try 
            {
            object = [object initWithDictionary: dstCollection];
            }
            @finally {
                [object autorelease];
            }
            
            if (object)
                value = object;
        }            break;     
            
            // Scalar or struct - simply use KVC.
        case kAMCFieldTypeScalar:
            break;                    
        default:
            break;
    }
    
    return value;
}

id AMCEncodeObject (id value, AMCFieldType fieldType)
{
    switch (fieldType) 
    {
            
        // Object as it's representation - create new.
        case kAMCFieldTypeCustomObject:
        {
            if ([value respondsToSelector:@selector(dictionaryRepresentation)])
                value = [(NSObject *) value dictionaryRepresentation];
        }
        break;
            
        case kAMCFieldTypeCollectionArray:
        case kAMCFieldTypeCollectionArrayMutable:
        {
            
            id <AMCArrayProtocol> collection = (id <AMCArrayProtocol> )value;
            NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity: [collection count]];
            
            for (unsigned int i = 0; i < [collection count]; ++i)
            {
                NSObject *curObjectInCollection = [collection objectAtIndex: i];
                NSObject *curObjectInCollectionEncoded = AMCEncodeObject (curObjectInCollection, AMCFieldTypeForObjectToEncode(curObjectInCollection) );
                
                [tmpArray addObject: curObjectInCollectionEncoded];
            }
            
            value = tmpArray;
        }
            break;
            
        case kAMCFieldTypeCollectionHash:
        case kAMCFieldTypeCollectionHashMutable:
        {
            NSObject <AMCHashProtocol> *collection = (NSObject <AMCHashProtocol> *)value;
            NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity: [collection count]];
            
            for (NSString *curKey in [collection allKeys])
            {
                NSObject *curObjectInCollection = [collection valueForKey: curKey];
                NSObject *curObjectInCollectionEncoded = AMCEncodeObject (curObjectInCollection, AMCFieldTypeForObjectToEncode(curObjectInCollection));
                
                [tmpDict setObject:curObjectInCollectionEncoded forKey:curKey];
            }
            
            value = tmpDict;
        }
            break;
            
            
            // Scalar or struct - simply use KVC.
        case kAMCFieldTypeScalar:
            break;                    
        default:
            break;
    }
    
    return value;
}

AMCFieldType AMCFieldTypeForEncodedObject(id object)
{    
    id class = [object class];
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {
        
        // Maybe it's custom object encoded in NSDictionary?
        if ([object respondsToSelector:@selector(objectForKey:)])
        {
            NSString *className = [object objectForKey:kAMCDictionaryKeyClassName];
            if ([className isKindOfClass:[NSString class]])
            {
                id encodedObjectClass = NSClassFromString(className);
                
                if ([encodedObjectClass AMCEnabled])
                    return kAMCFieldTypeCustomObject;
            }
        }        
        
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }
    
    
    return kAMCFieldTypeScalar;
}



AMCFieldType AMCFieldTypeForObjectToEncode(id object)
{    
    id class = [object class];
    
    // Is it custom object with dictionaryRepresentation support?
    if (([[object class] AMCEnabled]
        && ([object respondsToSelector:@selector(dictionaryRepresentation)]))
        )
    {
        return kAMCFieldTypeCustomObject;
    }
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {        
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }    
    
    return kAMCFieldTypeScalar;
}






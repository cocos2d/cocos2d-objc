/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCBLocalizationManager.h"
#import "CCBReader.h"

@implementation CCBLocalizationManager

@synthesize translations = _translations;

+ (id)sharedManager
{
	static dispatch_once_t pred;
	static CCBLocalizationManager *loc = nil;
	dispatch_once(&pred, ^{
		loc = [[self alloc] init];
	});
	return loc;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    [self loadStringsFile:@"Strings.ccbLang"];
    
    return self;
}

- (void) loadStringsFile:(NSString*) file
{
    // Load default localization dictionary
    NSString* path = [[CCFileUtils sharedFileUtils] fullPathForFilename:file];
    
    // Load strings file
    NSDictionary* ser = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Check that format of file is correct
    NSAssert([[ser objectForKey:@"fileType"] isEqualToString:@"SpriteBuilderTranslations"], @"Invalid file format for SpriteBuilder localizations");
    
    // Check that file version is correct
    NSAssert([[ser objectForKey:@"fileVersion"] intValue] == 1, @"Translation file version is incompatible with this reader");
    
    // Load available languages
    NSArray* languages = [ser objectForKey:@"activeLanguages"];
    
    // Determine which language to use
    NSString* userLanguage = NULL;
    
    NSArray* preferredLangs = [NSLocale preferredLanguages];
    for (NSString* preferredLang in preferredLangs)
    {
        // now loop thru languages from our spritebuilder
        for (NSString *localizedLanguage in languages)
        {
            // doing range of string as we might have en-GB set in our phone and that will match our en from the activeLanguages
            if ([preferredLang rangeOfString:localizedLanguage].location != NSNotFound)
            {
                userLanguage = localizedLanguage;
                break;
            }
        }
    }
    
    // Create dictionary for translations
    _translations = [[NSMutableDictionary alloc] init];
    
    // Load translations
    if (userLanguage != NULL)
    {
        NSArray* translations = [ser objectForKey:@"translations"];
        
        for (NSDictionary* translation in translations)
        {
            NSString* key = [translation objectForKey:@"key"];
            NSString* value = [(NSDictionary*)[translation objectForKey:@"translations"] objectForKey:userLanguage];
            
            if (key != NULL && value != NULL)
            {
                [_translations setObject:value forKey:key];
            }
        }
    }
}

- (NSString*) localizedStringForKey:(NSString*)key
{
    NSString* localizedString = [_translations objectForKey:key];
    if (!localizedString) localizedString = key;
    return localizedString;
}


@end

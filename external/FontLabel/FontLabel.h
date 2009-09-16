//
//  FontLabel.h
//  FontLabel
//
//  Created by Kevin Ballard on 5/8/09.
//  Copyright © 2009 Zynga Game Networks
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

@class ZFont;

@interface FontLabel : UILabel {
	void *reserved; // works around a bug in UILabel
	ZFont *zFont;
}
@property (nonatomic, setter=setCGFont:) CGFontRef cgFont __AVAILABILITY_INTERNAL_DEPRECATED;
@property (nonatomic, assign) CGFloat pointSize __AVAILABILITY_INTERNAL_DEPRECATED;
@property (nonatomic, retain, setter=setZFont:) ZFont *zFont;
// -initWithFrame:fontName:pointSize: uses FontManager to look up the font name
- (id)initWithFrame:(CGRect)frame fontName:(NSString *)fontName pointSize:(CGFloat)pointSize;
- (id)initWithFrame:(CGRect)frame zFont:(ZFont *)font;
- (id)initWithFrame:(CGRect)frame font:(CGFontRef)font pointSize:(CGFloat)pointSize __AVAILABILITY_INTERNAL_DEPRECATED;
@end

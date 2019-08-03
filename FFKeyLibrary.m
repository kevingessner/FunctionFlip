//
//  FFKeyLibrary.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 9/3/08.
//  Copyright (c) 2008-2010, Kevin Gessner, http://kevingessner.com
//  
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "FFKeyLibrary.h"
#include "NSDictionary+firstKeyForObject.h"
#import "FFDefs.h"

static NSDictionary *keyDescriptions, *keyCodes, *specialCodes;

@implementation FFKeyLibrary

+ (void)initialize {
	keyDescriptions = @{
						@(NX_KEYTYPE_BRIGHTNESS_DOWN) : @"Brightness Down",
						@(NX_KEYTYPE_BRIGHTNESS_UP) : @"Brightness Up",
						@(KG_BRIGHTNESS_DOWN_KEY) : @"Brightness Down",
						@(KG_BRIGHTNESS_UP_KEY) : @"Brightness Up",
						@(NX_KEYTYPE_ILLUMINATION_TOGGLE) : @"Toggle Illumination",
						@(NX_KEYTYPE_ILLUMINATION_DOWN) : @"Illumination Down",
						@(NX_KEYTYPE_ILLUMINATION_UP) : @"Illumination Up",
						@(NX_KEYTYPE_REWIND) : @"Rewind",
						@(NX_KEYTYPE_PLAY) : @"Play/Pause",
						@(NX_KEYTYPE_FAST) : @"Fast-Forward",
						@(NX_KEYTYPE_MUTE) : @"Mute",
						@(NX_KEYTYPE_SOUND_DOWN) : @"Volume Down",
						@(NX_KEYTYPE_SOUND_UP) : @"Volume Up",
						@(NX_KEYTYPE_VIDMIRROR) : @"Mirror Displays",
						@(KG_EXPOSE_KEY) : @"Exposé",
						@(KG_DASHBOARD_KEY) : @"Dashboard",
						@(KG_LAUNCHPAD_KEY) : @"Launchpad",
						};
	
	keyCodes = @{
				 FF_F1_KEYID : @(KG_KEY_F1),
				 FF_F2_KEYID : @(KG_KEY_F2),
				 FF_F3_KEYID : @(KG_KEY_F3),
				 FF_F4_KEYID : @(KG_KEY_F4),
				 FF_F5_KEYID : @(KG_KEY_F5),
				 FF_F6_KEYID : @(KG_KEY_F6),
				 FF_F7_KEYID : @(KG_KEY_F7),
				 FF_F8_KEYID : @(KG_KEY_F8),
				 FF_F9_KEYID : @(KG_KEY_F9),
				 FF_F10_KEYID : @(KG_KEY_F10),
				 FF_F11_KEYID : @(KG_KEY_F11),
				 FF_F12_KEYID : @(KG_KEY_F12),
				 };
	specialCodes = @{
					 FF_BRIGHTNESS_DOWN_ID_LAPTOP : @(NX_KEYTYPE_BRIGHTNESS_DOWN),
					 FF_BRIGHTNESS_UP_ID_LAPTOP : @(NX_KEYTYPE_BRIGHTNESS_UP),
					 FF_BRIGHTNESS_DOWN_ID_EXTERNAL : @(KG_BRIGHTNESS_DOWN_KEY),
					 FF_BRIGHTNESS_UP_ID_EXTERNAL : @(KG_BRIGHTNESS_UP_KEY),
					 FF_ILLUMINATION_TOGGLE_ID : @(NX_KEYTYPE_ILLUMINATION_TOGGLE),
					 FF_ILLUMINATION_DOWN_ID : @(NX_KEYTYPE_ILLUMINATION_DOWN),
					 FF_ILLUMINATION_UP_ID : @(NX_KEYTYPE_ILLUMINATION_UP),
					 FF_REWIND_ID : @(NX_KEYTYPE_REWIND),
					 FF_PLAYPAUSE_ID : @(NX_KEYTYPE_PLAY),
					 FF_FASTFORWARD_ID : @(NX_KEYTYPE_FAST),
					 FF_MUTE_ID : @(NX_KEYTYPE_MUTE),
					 FF_VOLUME_DOWN_ID : @(NX_KEYTYPE_SOUND_DOWN),
					 FF_VOLUME_UP_ID : @(NX_KEYTYPE_SOUND_UP),
					 FF_VIDEO_MIRROR_ID : @(NX_KEYTYPE_VIDMIRROR),
					 FF_EXPOSE_ID : @(KG_EXPOSE_KEY),
					 FF_DASHBOARD_ID : @(KG_DASHBOARD_KEY),
					 FF_LAUNCHPAD_ID : @(KG_LAUNCHPAD_KEY),
					 };
}

/*
 Some keys (expose, dashboard) come in as regular keys but act like special
 */
+ (BOOL)isRegularKeyLikeSpecialKey:(int)keyCode {
	return (KG_EXPOSE_KEY == keyCode
            || KG_DASHBOARD_KEY == keyCode
            || KG_LAUNCHPAD_KEY == keyCode
            || KG_BRIGHTNESS_DOWN_KEY == keyCode
            || KG_BRIGHTNESS_UP_KEY == keyCode);
}

+ (NSString *)descriptionForSpecialKey:(NSNumber *)key {
	return [keyDescriptions objectForKey:key];
}

+ (NSString *)descriptionForSpecialId:(NSString *)specialId {
	return [keyDescriptions objectForKey:[specialCodes objectForKey:[specialId lowercaseString]]];
}

+ (NSString *)keyIdForKeycode:(NSNumber *)keycode {
	return [keyCodes firstKeyForObject:keycode];
}


+ (NSNumber *)keycodeForKeyId:(NSString *)keyId {
	return [keyCodes objectForKey:keyId];
}

+ (NSNumber *)keycodeForSpecialId:(NSString *)specialId {
	return [specialCodes objectForKey:[specialId lowercaseString]];
}

// keyCodes are sequential hex numbers from FF_F1_KEYID to FF_F12_KEYID
// so use the offset from FF_F1_KEYID to return a string like "F4"
+ (NSString *)descriptionForKeyId:(NSString *)keyId {
	unsigned f1, fkey;
	if(![[NSScanner scannerWithString:FF_F1_KEYID] scanHexInt:&f1]) return @"";
	if(![[NSScanner scannerWithString:keyId] scanHexInt:&fkey]) return @"";
	return [NSString stringWithFormat:@"F%d", (fkey - f1 + 1)];
}

@end

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

#define N(X) [NSNumber numberWithInt:X]

static NSDictionary *keyDescriptions, *keyCodes, *specialCodes;

@implementation FFKeyLibrary

+ (void)initialize {
	keyDescriptions = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"Brightness Down", @"Brightness Up", @"Brightness Down", @"Brightness Up", @"Toggle Illumination", @"Illumination Down", @"Illumination Up", @"Rewind", @"Play/Pause", @"Fast-Forward", @"Mute", @"Volume Down", @"Volume Up", @"Mirror Displays", @"Exposé", @"Dashboard", nil]
										 forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInt:NX_KEYTYPE_BRIGHTNESS_DOWN], [NSNumber numberWithInt:NX_KEYTYPE_BRIGHTNESS_UP], N(KG_BRIGHTNESS_DOWN_KEY), N(KG_BRIGHTNESS_UP_KEY), [NSNumber numberWithInt:NX_KEYTYPE_ILLUMINATION_TOGGLE], [NSNumber numberWithInt:NX_KEYTYPE_ILLUMINATION_DOWN], [NSNumber numberWithInt:NX_KEYTYPE_ILLUMINATION_UP], [NSNumber numberWithInt:NX_KEYTYPE_REWIND], [NSNumber numberWithInt:NX_KEYTYPE_PLAY], [NSNumber numberWithInt:NX_KEYTYPE_FAST], [NSNumber numberWithInt:NX_KEYTYPE_MUTE], [NSNumber numberWithInt:NX_KEYTYPE_SOUND_DOWN], [NSNumber numberWithInt:NX_KEYTYPE_SOUND_UP], [NSNumber numberWithInt:NX_KEYTYPE_VIDMIRROR], [NSNumber numberWithInt:KG_EXPOSE_KEY], [NSNumber numberWithInt:KG_DASHBOARD_KEY], nil]];
	
	keyCodes = [[NSDictionary alloc] initWithObjectsAndKeys:N(KG_KEY_F1), FF_F1_KEYID, N(KG_KEY_F2), FF_F2_KEYID, N(KG_KEY_F3), FF_F3_KEYID, N(KG_KEY_F4), FF_F4_KEYID, N(KG_KEY_F5), FF_F5_KEYID, N(KG_KEY_F6), FF_F6_KEYID, N(KG_KEY_F7), FF_F7_KEYID, N(KG_KEY_F8), FF_F8_KEYID, N(KG_KEY_F9), FF_F9_KEYID, N(KG_KEY_F10), FF_F10_KEYID, N(KG_KEY_F11), FF_F11_KEYID, N(KG_KEY_F12), FF_F12_KEYID, nil];
	specialCodes = [[NSDictionary alloc] initWithObjectsAndKeys:N(NX_KEYTYPE_BRIGHTNESS_DOWN), FF_BRIGHTNESS_DOWN_ID_LAPTOP, N(NX_KEYTYPE_BRIGHTNESS_UP), FF_BRIGHTNESS_UP_ID_LAPTOP, N(KG_BRIGHTNESS_DOWN_KEY), FF_BRIGHTNESS_DOWN_ID_EXTERNAL, N(KG_BRIGHTNESS_UP_KEY), FF_BRIGHTNESS_UP_ID_EXTERNAL, N(NX_KEYTYPE_ILLUMINATION_TOGGLE), FF_ILLUMINATION_TOGGLE_ID, N(NX_KEYTYPE_ILLUMINATION_DOWN), FF_ILLUMINATION_DOWN_ID, N(NX_KEYTYPE_ILLUMINATION_UP), FF_ILLUMINATION_UP_ID, N(NX_KEYTYPE_REWIND), FF_REWIND_ID, N(NX_KEYTYPE_PLAY), FF_PLAYPAUSE_ID, N(NX_KEYTYPE_FAST), FF_FASTFORWARD_ID, N(NX_KEYTYPE_MUTE), FF_MUTE_ID, N(NX_KEYTYPE_SOUND_DOWN), FF_VOLUME_DOWN_ID, N(NX_KEYTYPE_SOUND_UP), FF_VOLUME_UP_ID, N(NX_KEYTYPE_VIDMIRROR), FF_VIDEO_MIRROR_ID, N(KG_EXPOSE_KEY), FF_EXPOSE_ID, N(KG_DASHBOARD_KEY), FF_DASHBOARD_ID, nil];
}

/*
 Some keys (expose, dashboard) come in as regular keys but act like special
 */
+ (BOOL)isRegularKeyLikeSpecialKey:(int)keyCode {
	return (KG_EXPOSE_KEY == keyCode || KG_DASHBOARD_KEY == keyCode || KG_BRIGHTNESS_DOWN_KEY == keyCode || KG_BRIGHTNESS_UP_KEY == keyCode);
}

+ (NSString *)descriptionForSpecialKey:(NSNumber *)key {
	return [keyDescriptions objectForKey:key];
}

+ (NSString *)descriptionForSpecialId:(NSString *)specialId {
	return [keyDescriptions objectForKey:[specialCodes objectForKey:specialId]];
}

+ (NSString *)keyIdForKeycode:(NSNumber *)keycode {
	return [keyCodes firstKeyForObject:keycode];
}


+ (NSNumber *)keycodeForKeyId:(NSString *)keyId {
	return [keyCodes objectForKey:keyId];
}

+ (NSNumber *)keycodeForSpecialId:(NSString *)specialId {
	return [specialCodes objectForKey:specialId];
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

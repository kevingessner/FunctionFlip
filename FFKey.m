//
//  FFKey.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 9/7/08.
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

#import "FFKey.h"
#import "FFKeyboard.h"
#import "FFKeyLibrary.h"

@implementation FFKey

+ (void)initialize {
	[self exposeBinding:@"flipped"];
	[self exposeBinding:@"description"];
}

+ (FFKey *)keyWithKeyId:(NSString *)keyId ofKeyboard:(FFKeyboard *)keyboard; {
	FFKey *key = [[FFKey alloc] initWithKeyId:(NSString *)keyId ofKeyboard:(FFKeyboard *)keyboard];
	return key;
}

- (id)initWithKeyId:(NSString *)_keyId ofKeyboard:(FFKeyboard *)_keyboard; {
	if(self = [super init]) {
		keyId = _keyId;
		keyboard = _keyboard;
	}
	return self;
}

@synthesize keyId;

- (BOOL)flipped {
	return [keyboard isKeyFlipped:self];
}
- (void)setFlipped:(BOOL)flag {
	[keyboard setKey:self isFlipped:flag];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@: %@", [FFKeyLibrary descriptionForKeyId:keyId], [FFKeyLibrary descriptionForSpecialId:[keyboard specialIdForKeyId:keyId]]];
}

@end

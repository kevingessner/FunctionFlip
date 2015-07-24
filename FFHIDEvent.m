//
//  FFHIDEvent.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 10/23/08.
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

#import "FFHIDEvent.h"
#import "DDHidLib.h"
#import "FFKeyboard.h"

@implementation FFHIDEvent

+ (FFHIDEvent *)eventWithDDHidEvent:(DDHidEvent *)event fromKeyboard:(FFKeyboard *)keyboard {
	return [[FFHIDEvent alloc] initWithDDHidEvent:event fromKeyboard:keyboard];
}

- (id)initWithDDHidEvent:(DDHidEvent *)_event fromKeyboard:(FFKeyboard *)_keyboard {
	if(self = [super init]) {
		self.event = _event;
		self.keyboard = _keyboard;
	}
	return self;
}

@synthesize keyboard;
@synthesize event;

- (DDHidElement *)element {
	return [[self.keyboard device] elementForCookie:[self.event elementCookie]];
}

- (BOOL)isFkeyEvent {
	return [self.keyboard hasSpecialFkeys] && (nil != [[self.keyboard fkeyMap] objectForKey:self.keyId]);
}

// hex value of the usage page and usage id of the event
// correlates to keyboard's f-key mapping
- (NSString *)keyId {
	return [NSString stringWithFormat:@"0x%04x%04x", [[self.element usage] usagePage], [[self.element usage] usageId]];
}

- (NSString *)specialId {
	return [self.keyboard specialIdForKeyId:self.keyId];
}

@end

//
//  KGLoginController.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 8/12/08.
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

#import "KGLoginController.h"

#include "LoginItemsAE.h"
#include "FFPreferenceManager.h"
#include "FFHelperAppController.h"

@implementation KGLoginController

- (id)init {
	if(self = [super init]) {
		[[FFPreferenceManager sharedInstance] addObserver:self forKeyPath:KG_LOGIN_KEYPATH options:NSKeyValueObservingOptionNew context:NULL];
		[self setStartsAtLogin:[[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue]];
	}
	return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:KG_LOGIN_KEYPATH]) {
		[self setStartsAtLogin:[[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setStartsAtLogin:(BOOL)flag {
	OSStatus status;
	CFArrayRef loginItems = NULL;
	NSURL *url = [NSURL fileURLWithPath:[FFHelperAppController pathToHelperApp]];
	int existingLoginItemIndex = -1;

	status = LIAECopyLoginItems(&loginItems);

	if (status == noErr) {
		NSEnumerator *enumerator = [(NSArray *)loginItems objectEnumerator];
		NSDictionary *loginItemDict;

		while ((loginItemDict = [enumerator nextObject])) {
			if ([[loginItemDict objectForKey:(NSString *)kLIAEURL] isEqual:url]) {
				existingLoginItemIndex = [(NSArray *)loginItems indexOfObjectIdenticalTo:loginItemDict];
				break;
			}
		}
	}
	
	if (flag && (existingLoginItemIndex == -1))
		LIAEAddURLAtEnd((CFURLRef)url, false);
	else if (!flag && (existingLoginItemIndex != -1))
		LIAERemove(existingLoginItemIndex);

	if(loginItems)
		CFRelease(loginItems);
}

- (BOOL)startsAtLogin {
	return [[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue];
}


@end

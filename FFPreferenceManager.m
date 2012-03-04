//
//  FFPreferenceManager.m
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

#import "FFPreferenceManager.h"

static FFPreferenceManager *sharedInstance = nil;

@implementation FFPreferenceManager

+ (FFPreferenceManager *)sharedInstance {
	if(nil == sharedInstance) {
		sharedInstance = [[FFPreferenceManager alloc] init];
	}
	return sharedInstance;
}

- (id)valueForKey:(NSString *)key {
	CFPreferencesAppSynchronize((CFStringRef)FF_PREFPANE_BUNDLE_IDENTIFIER);
	id value = (id)CFPreferencesCopyAppValue((CFStringRef)key,
        (CFStringRef)FF_PREFPANE_BUNDLE_IDENTIFIER);
//	NSLog(@"ffprefmanager (%@) get: %@, %@", self, key, value);
	return [value autorelease];
}

- (void)setValue:(id)value forKey:(NSString *)key {
	[self willChangeValueForKey:key];
//	NSLog(@"ffprefmanager (%@) set: %@, %@", self, key, value);
	CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, (CFStringRef)FF_PREFPANE_BUNDLE_IDENTIFIER);
	CFPreferencesAppSynchronize((CFStringRef)FF_PREFPANE_BUNDLE_IDENTIFIER);
	[self didChangeValueForKey:key];
}

@end

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

- (BOOL)startsAtLogin {
	return [[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue];
}

-(void) addAppAsLoginItem:(NSString *)appPath {
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];

	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem:(NSString *)appPath {
	CFURLRef url;

	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		UInt32 seedValue;
		NSArray *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(id itemRef in loginItemsArray) {
            //Resolve the item with URL
			if (LSSharedFileListItemResolve((LSSharedFileListItemRef)itemRef, 0, &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath isEqualToString:appPath]){
					LSSharedFileListItemRemove(loginItems, (LSSharedFileListItemRef)itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}


- (void)setStartsAtLogin:(BOOL)flag {
    NSString *appPath = [FFHelperAppController pathToHelperApp];
    if (flag) {
        [self addAppAsLoginItem:appPath];
    } else {
        [self deleteAppFromLoginItem:appPath];
    }
}

@end

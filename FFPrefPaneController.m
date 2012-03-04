//
//  FFPrefPaneController.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 9/2/08.
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

#import "FFDefs.h"
#import "FFPrefPaneController.h"
#import "FFKeyLibrary.h"
#import "FFPreferenceManager.h"
#import "FFKey.h"
#import "FFKeyboard.h"
#import "FFHelperAppController.h"
#import "FFUpdateSheetController.h"
#import "DDHidLib.h"

@interface FFPrefPaneController (Private)

- (void)setStartsAtLogin:(BOOL)flag;

@end

@implementation FFPrefPaneController

- (void) mainViewDidLoad {
	// First load of a new version of the pref-pane
	NSString *lastVersion = (NSString *)[[FFPreferenceManager sharedInstance] valueForKey:@"version"];
	if(!lastVersion || ![lastVersion isEqualToString:[self bundleVersionNumber]]) {
		[self restartHelperApp];
		[[FFPreferenceManager sharedInstance] setValue:[self bundleVersionNumber] forKey:@"version"];
	} else {
		[self performSelector:@selector(updateHelperAppStatus) withObject:nil afterDelay:0.1];
	}
    
    [[FFPreferenceManager sharedInstance] addObserver:self forKeyPath:KG_LOGIN_KEYPATH options:NSKeyValueObservingOptionNew context:NULL];
    [self setStartsAtLogin:[[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue]];
}

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//}

- (IBAction)startStopHelperApp:(id)sender {
	[FFHelperAppController startStopHelperApp];
	[helperAppProgress startAnimation:self];
	[startStopHelperApp setEnabled:NO];
	// give the app a moment to start, then check if it's running.
	[self performSelector:@selector(updateHelperAppStatus) withObject:nil afterDelay:3.0];
}

- (void)restartHelperApp {
	[FFHelperAppController restartHelperApp];
	[helperAppStatus setStringValue:@"Upgrading FunctionFlip..."];
	[helperAppProgress startAnimation:self];
	[startStopHelperApp setEnabled:NO];
	// give the app a moment to start, then check if it's running.
	[self performSelector:@selector(updateHelperAppStatus) withObject:nil afterDelay:4.0];
}


- (void)updateHelperAppStatus {
	if([FFHelperAppController isHelperAppRunning]) {
		[helperAppStatus setStringValue:@"FunctionFlip is running."];
		[startStopHelperApp setTitle:@"Stop FunctionFlip"];
	} else {
		[helperAppStatus setStringValue:@"FunctionFlip is stopped."];
		[startStopHelperApp setTitle:@"Start FunctionFlip"];
	}
	[startStopHelperApp setEnabled:YES];
	[helperAppProgress stopAnimation:self];
}

- (FFPreferenceManager *)ffPreferenceManager {
	return [FFPreferenceManager sharedInstance];
}

// not cached since we want to ask DDHidKeyboard for any new keyboards every time
// could have caching with a check or notifcation of changes, but KISS
- (NSArray *)keyboards {
	NSMutableArray *keyboards = [NSMutableArray arrayWithCapacity:1];
	for(DDHidKeyboard *device in [DDHidKeyboard allKeyboards]) {
		FFKeyboard *keyboard = [FFKeyboard keyboardWithDevice:device];
		if(keyboard) [keyboards addObject:keyboard];
	}
	return keyboards;
}

- (IBAction)showAbout:(id)sender {
	[NSApp beginSheet:aboutSheet modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:@selector(aboutSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)hideAbout:(id)sender {
	[NSApp endSheet:aboutSheet];
}

- (void)aboutSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[aboutSheet orderOut:self];	
}

- (IBAction)openHomePage:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://kevingessner.com/software/functionflip/"]];
}

- (NSString *)bundleVersionNumber {
	return [[[NSBundle bundleWithIdentifier:FF_PREFPANE_BUNDLE_IDENTIFIER] infoDictionary] valueForKey:@"CFBundleVersion"];
}

- (IBAction)checkForUpdate:(id)sender {
	[NSApp beginSheet:updateSheet modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:@selector(updateSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	[updateSheetController beginUpdate];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:FF_UPDATE_URL] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:15.0];
	NSURLResponse *response; // required out-parameter for next line
	NSError *error;
	NSData *versionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if(!versionData) {
        NSLog(@"Couldn't get version: %@", error);
		[updateSheetController updateFailed];
	} else {
        NSString *updateVersion = [[[NSString alloc] initWithData:versionData encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"found version %@", updateVersion);
        if([updateVersion isEqualToString:[self bundleVersionNumber]]) {
			[updateSheetController updateNotAvailable];
		} else {
			[updateSheetController updateAvailable:updateVersion];
		}
	}
}

- (IBAction)hideUpdateSheet:(id)sender {
	[NSApp endSheet:updateSheet];
}

- (void)updateSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[updateSheet orderOut:self];	
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:KG_LOGIN_KEYPATH]) {
		[self setStartsAtLogin:[[[FFPreferenceManager sharedInstance] valueForKey:KG_LOGIN_KEYPATH] boolValue]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
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

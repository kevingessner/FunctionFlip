//
//  FFHelperAppController.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 9/11/08.
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
#import "FFHelperAppController.h"

@implementation FFHelperAppController

+ (void)restartHelperApp {
	if([FFHelperAppController isHelperAppRunning]) {
		[FFHelperAppController terminateHelperApp];
		[FFHelperAppController performSelector:@selector(launchHelperApp) withObject:nil afterDelay:2.0];
	} else {
		[FFHelperAppController launchHelperApp];
	}
}

+ (BOOL)startStopHelperApp {
//	NSLog(@"start/stop...");
	if([FFHelperAppController isHelperAppRunning]) [FFHelperAppController terminateHelperApp];
	else [FFHelperAppController launchHelperApp];
	return [FFHelperAppController isHelperAppRunning];
}

+ (NSString *)pathToHelperApp {
	return [[NSBundle bundleWithIdentifier:FF_PREFPANE_BUNDLE_IDENTIFIER] pathForResource:@"FunctionFlip" ofType:@"app"];
}

+ (void) launchHelperApp {
	NSLog(@"starting %@", [FFHelperAppController pathToHelperApp]);
	NSURL *helperAppURL = [NSURL fileURLWithPath:[FFHelperAppController pathToHelperApp]];

	unsigned options = NSWorkspaceLaunchWithoutAddingToRecents | NSWorkspaceLaunchWithoutActivation | NSWorkspaceLaunchAsync;
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:helperAppURL]
	                withAppBundleIdentifier:nil
	                                options:options
	         additionalEventParamDescriptor:nil
	                      launchIdentifiers:NULL];
}

+ (void) terminateHelperApp {
//	NSLog(@"stopping");
	// Ask the Helper App to terminate
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(),
										 (CFStringRef)FF_TERMINATE_NOTIFICATION,
										 /*object*/ NULL,
										 /*userInfo*/ NULL,
										 /*deliverImmediately*/ false);
}


+ (BOOL)isHelperAppRunning {
	BOOL isRunning = NO;
	ProcessSerialNumber PSN = { kNoProcess, kNoProcess };

	while (GetNextProcess(&PSN) == noErr) {
		NSDictionary *infoDict = (NSDictionary *)CFBridgingRelease(ProcessInformationCopyDictionary(&PSN, kProcessDictionaryIncludeAllInformationMask));
		NSString *bundleID = [infoDict objectForKey:(NSString *)kCFBundleIdentifierKey];
		isRunning = bundleID && [bundleID isEqualToString:FF_HELPER_APP_BUNDLE_IDENTIFIER];

		if (isRunning)
			break;
	}
//	NSLog(@"helper app running? %d", isRunning);
	return isRunning;
}

@end

//
//  FFUpdateSheetController.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 10/28/08.
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

#import "FFUpdateSheetController.h"


@implementation FFUpdateSheetController

- (void)beginUpdate {
	[title setStringValue:@"Checking for update..."];
	[text setHidden:YES];
	[ok setEnabled:NO];
	[cancel setTitle:@"Cancel"];
	[progress startAnimation:self];
	[progress setHidden:NO];
}

- (void)updateAvailable:(NSString *)version {
	[title setStringValue:[NSString stringWithFormat:@"Version %@ Available", version]];
	[text setHidden:NO];
	[text setStringValue:@"Click Get Update to go the FunctionFlip website."];
	[ok setEnabled:YES];
	[cancel setTitle:@"Later"];
	[progress stopAnimation:self];	
	[progress setHidden:YES];
}

- (void)updateNotAvailable {
	[title setStringValue:@"FunctionFlip is up-to-date"];
	[text setHidden:NO];
	[text setStringValue:@"You're using the newest version of FunctionFlip."];
	[ok setEnabled:NO];
	[cancel setTitle:@"Done"];
	[progress stopAnimation:self];	
	[progress setHidden:YES];
}

- (void)updateFailed {
	[title setStringValue:@"Check for update failed"];
	[text setHidden:NO];
	[text setStringValue:@"Could not connect to the update server. Please try again later."];
	[ok setEnabled:NO];
	[cancel setTitle:@"Done"];
	[progress stopAnimation:self];		
	[progress setHidden:YES];
}

@end

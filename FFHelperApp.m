//
//  FFHelperApp.m
//  FunctionFlip
//
//  Created by Kevin Gessner on 6/14/08.
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

#import "FFHelperApp.h"
#include <ApplicationServices/ApplicationServices.h>
#include <IOBluetooth/IOBluetooth.h>
#include "FFKeyLibrary.h"
#include "FFPreferenceManager.h"
#import "DDHidLib.h"
#import "FFHIDEvent.h"
#import "FFKeyboard.h"
#import "USBNotifier.h"

static NSMutableArray *hidEventQueue;
CFMachPortRef eventTap;

// This callback will be invoked every time there is a keystroke.
//
CGEventRef
myCGEventCallback(CGEventTapProxy proxy, CGEventType type,
                  CGEventRef ev, void *refcon)
{
    // On 10.6, the kCGEventTapDisabledByTimeout event seems to come incorrectly. If we get it, reenable the tap.
    // see http://lists.apple.com/archives/quartz-dev/2009/Sep/msg00006.html
    if(type == kCGEventTapDisabledByTimeout) {
        NSLog(@"got kCGEventTapDisabledByTimeout, reenabling tap");
		CGEventTapEnable(eventTap, TRUE);
		return ev;	// NULL also seems to work here...
	}

    NSEvent *e = [NSEvent eventWithCGEvent:ev];
        
	// Paranoid sanity check.
	if ((type != kCGEventKeyDown) && (type != kCGEventKeyUp) && (type != NX_SYSDEFINED))
		return ev;
	if([hidEventQueue count] == 0)
		return ev;
	
	/*
	some keys are "special", but don't come down the pipe as special events. so we grab them here,
	and set a flag for the future
	*/
	BOOL regular_like_special = ( ([e type] == NSKeyDown || [e type] == NSKeyUp) && [FFKeyLibrary isRegularKeyLikeSpecialKey:[e keyCode]] );
	
	// We're getting a special event, or an expose key
	if( ([e type] == NSSystemDefined && [e subtype] == 8) || regular_like_special ) {
		int keyCode, keyState, keyRepeat;
		if(regular_like_special) {
			keyCode = [e keyCode];
			keyState = ([e type] == NSKeyDown);
			keyRepeat = (int)[e isARepeat];
		} else {
			keyCode = (([e data1] & 0xFFFF0000) >> 16);
			int keyFlags = ([e data1] & 0x0000FFFF);
			keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA; // true => keyDown 
			keyRepeat = (keyFlags & 0x1);
		}

		FFHIDEvent *event = [hidEventQueue lastObject];
		if(FF_KEY_UP == keyState) { // since we can get several keyDown key events per HID event, only remove the object on keyUp
			[[event retain] autorelease]; // the event will be released it's removed, so prevent it from vanishing (not sure)
			[hidEventQueue removeLastObject];
		}
		
		if([[[FFPreferenceManager sharedInstance] valueForKey:[NSString stringWithFormat:@"flipped.%@.%@", [event.keyboard.device productName], [event keyId]]] boolValue]) {
			NSNumber *regularKey = [FFKeyLibrary keycodeForKeyId:[event keyId]];
			if(nil != regularKey) {
                CGEventSourceRef sourceRef = CGEventCreateSourceFromEvent(ev);
                CGEventRef newEvent = CGEventCreateKeyboardEvent(sourceRef, [regularKey intValue], keyState);
                CFRelease(sourceRef);
                return newEvent;
			}
		}
	// we're getting a normal key event
	} else if([e type] == NSKeyDown || [e type] == NSKeyUp) {
		FFHIDEvent *event = [hidEventQueue lastObject];
		if([e type] == NSKeyUp) { // since we can get several keyDown key events per HID event, only remove the object on keyUp
			[[event retain] autorelease]; // the event will be released it's removed, so prevent it from vanishing (not sure)
			[hidEventQueue removeLastObject];
		}
		
		if([[[FFPreferenceManager sharedInstance] valueForKey:[NSString stringWithFormat:@"flipped.%@.%@", [event.keyboard.device productName], [event keyId]]] boolValue]) {
			NSNumber *specialKey = [FFKeyLibrary keycodeForSpecialId:[event specialId]];
			if(nil != specialKey) {
				int specialCode = [specialKey intValue];		
				// create a new event, with the new key, but everything else (now including modifiers) the same
				NSEvent *newE;
				// expose/dashboard keys go out as regular key events, with the "special" keycode
				if([FFKeyLibrary isRegularKeyLikeSpecialKey:specialCode]) {
					newE = [NSEvent keyEventWithType:[e type] location:[e locationInWindow] modifierFlags:[e modifierFlags] timestamp:[e timestamp] windowNumber:[e windowNumber] context:[e context] characters:@"" charactersIgnoringModifiers:@"" isARepeat:[e isARepeat] keyCode:specialCode];
				} else {
					newE = [NSEvent otherEventWithType:NSSystemDefined location:[e locationInWindow] modifierFlags:([e modifierFlags] | ([e type] == NSKeyDown ? 0xa00 : 0xb00)) timestamp:[e timestamp] windowNumber:[e windowNumber] context:[e context] subtype:8 data1:(specialCode << 16) + (([e type] == NSKeyDown  ? 0x0a : 0x0b) << 8) data2:-1];
				}
                CGEventRef newEvent = [newE CGEvent];
				CFRetain(newEvent); // newEvent gets released by the event system
				return newEvent;
			}
		}
	}
	
	return ev;
}

static IOBluetoothUserNotificationRef connectionNotification;

@implementation FFHelperApp

+ (void)initialize {
	hidEventQueue = [[NSMutableArray array] retain];
}

/*!
 From 10.9's AXUIElement.h in ApplicationServices.framework:

 @function AXIsProcessTrustedWithOptions
 @abstract Returns whether the current process is a trusted accessibility client.
 @param options A dictionary of options, or NULL to specify no options. The following options are available:
 
 KEY: kAXTrustedCheckOptionPrompt
 VALUE: ACFBooleanRef indicating whether the user will be informed if the current process is untrusted. This could be used, for example, on application startup to always warn a user if accessibility is not enabled for the current process. Prompting occurs asynchronously and does not affect the return value.
 
 @result Returns TRUE if the current process is a trusted accessibility client, FALSE if it is not.
 */
extern Boolean AXIsProcessTrustedWithOptions(CFDictionaryRef options) __attribute__((weak_import));
extern CFStringRef kAXTrustedCheckOptionPrompt __attribute__((weak_import));

- (void)listenForKeyEvents
{
  CFMachPortRef      eventTapTest;
  CGEventMask        eventMask;
  CFRunLoopSourceRef runLoopSource;

  // Create an event tap. We are interested in key presses and system defined keys.  
  eventMask = ((1 << kCGEventKeyDown) | (1 << kCGEventKeyUp));

  if (AXIsProcessTrustedWithOptions != NULL) {
      // 10.9 or higher
      NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanFalse, kAXTrustedCheckOptionPrompt, nil];
      eventTapTest = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, 0,
                                      eventMask, myCGEventCallback, NULL);
      if (!AXIsProcessTrustedWithOptions((CFDictionaryRef)options) || !eventTapTest) {
          NSLog(@"no trust, no tap");
          NSAlert *alert = [[[NSAlert alloc] init] autorelease];
          [alert addButtonWithTitle:@"Open Security & Privacy Preferences"];
          [alert setMessageText:@"FunctionFlip needs your permission to run"];
          [alert setInformativeText:@"Enable FunctionFlip in Security & Privacy preferences -> Privacy -> Accessibility, in System Preferences.  Then restart FunctionFlip."];
          [alert setAlertStyle:NSCriticalAlertStyle];
          [alert runModal];
          [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Security.prefPane"];
          [NSApp terminate:self];
          return;
      }
  } else {
      // 10.8 or before
      // try creating an event tap just for keypresses. if it fails, we need Universal Access.
      eventTapTest = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, 0,
                      eventMask, myCGEventCallback, NULL);
    if (!eventTapTest) {
        NSLog(@"no tap");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"Quit"];
        [alert setMessageText:@"FunctionFlip could not create an event tap."];
        [alert setInformativeText:@"Please enable \"access for assistive devices\" in the Universal Access pane of System Preferences."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [NSApp terminate:self];
        return;
    }
  }
  // disable the test tap
  // causes a crash otherwise (infinite loop with the replacement events, probably)
  if (eventTapTest) CGEventTapEnable(eventTapTest, false);
  
  eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
				  CGEventMaskBit(NX_SYSDEFINED) | eventMask, myCGEventCallback, NULL);

  // Create a run loop source.
  runLoopSource = CFMachPortCreateRunLoopSource(
						kCFAllocatorDefault, eventTap, 0);

  // Add to the current run loop.
  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
		     kCFRunLoopCommonModes);

  // Enable the event tap.
  CGEventTapEnable(eventTap, true);

}

- (void)terminate {
	[NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Preference pane sends this notification to tell us to die
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(terminate) name:FF_TERMINATE_NOTIFICATION object:nil];
	
	[self listenForHIDEvents];
	[self listenForKeyEvents];

    [self listenForHardwareChanges];
}

- (void)listenForHIDEvents {
//    NSLog(@"listing keyboard");
	
	// release queues first, or suffer!
	self.queues = nil;
	self.devices = nil;

	self.devices = [NSMutableArray arrayWithCapacity:1];
	self.queues = [NSMutableArray arrayWithCapacity:1];
	
	DDHidQueue *queue;
	for(DDHidKeyboard *keyboard in [DDHidKeyboard allKeyboards]) {
//        NSLog(@"found keyboard %@", keyboard);
		[self.devices addObject:keyboard];
		[keyboard open];
		queue = [keyboard createQueueWithSize:10];
		[self.queues addObject:queue];
		[queue setDelegate:self];
		[queue addElements:[keyboard elements] recursively:YES];
		[queue startOnCurrentRunLoop];
	}
}

- (void)dealloc {
    IOBluetoothUserNotificationUnregister(connectionNotification);
    [super dealloc];
}

#pragma mark -
#pragma mark keyboard changes

- (void)keyboardListChanged {
	// give the keyboard a moment to be recognized, then start listening
	[self performSelector:@selector(listenForHIDEvents) withObject:nil afterDelay:2.0];
}

static void bluetoothDisconnection(void *userRefCon, IOBluetoothUserNotificationRef inRef, IOBluetoothObjectRef objectRef) {
    [(FFHelperApp *)userRefCon keyboardListChanged];
    IOBluetoothUserNotificationUnregister(inRef);
}

static void bluetoothConnection(void *userRefCon, IOBluetoothUserNotificationRef inRef, IOBluetoothObjectRef objectRef) {
    #pragma unused(inRef)
    [(FFHelperApp *)userRefCon keyboardListChanged];
    IOBluetoothDeviceRegisterForDisconnectNotification(objectRef, bluetoothDisconnection, userRefCon);
}
- (void)listenForHardwareChanges {
    USBNotifier_init(self);
    connectionNotification = IOBluetoothRegisterForDeviceConnectNotifications(bluetoothConnection, self);
}

#pragma mark -

- (void) ddhidQueueHasEvents: (DDHidQueue *) hidQueue
{
	NSUInteger index = [self.queues indexOfObject:hidQueue];
	if(NSNotFound == index) return;
	
	DDHidKeyboard *device = [self.devices objectAtIndex:index];
	if(!device) return;
	
    DDHidEvent * hidEvent;
	FFHIDEvent *event;
	while ((hidEvent = [hidQueue nextEvent]))
    {
		event = [FFHIDEvent eventWithDDHidEvent:hidEvent fromKeyboard:[FFKeyboard keyboardWithDevice:device]];
		if([event isFkeyEvent] && [hidEvent value] == FF_KEY_DOWN) { // only grab the down-stroke of fkeys
			[hidEventQueue addObject:event];
		}
	}
}

@synthesize devices, queues;

@end

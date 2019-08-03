/*
 Shamlessly taken from the (BSD-licensed) HardwareGrowler Extra of the Growl project.
 */
#include "USBNotifier.h"
#import "FFHelperApp.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/usb/USB.h>

//extern void NSLog(CFStringRef format, ...);

static IONotificationPortRef	ioKitNotificationPort;
static CFRunLoopSourceRef		notificationRunLoopSource;
static Boolean					notificationsArePrimed = false;

#pragma mark C Callbacks

static void usbDeviceAdded(void *refCon, io_iterator_t iterator) {
#pragma unused(refCon)
//	NSLog(@"USB Device Added Notification.");
	io_object_t	thisObject;
	while ((thisObject = IOIteratorNext(iterator))) {
		if (notificationsArePrimed) {
			kern_return_t	nameResult;
			io_name_t		deviceNameChars;

			//	This works with USB devices...
			//	but apparently not firewire
			nameResult = IORegistryEntryGetName(thisObject, deviceNameChars);

			CFStringRef deviceName = CFStringCreateWithCString(kCFAllocatorDefault,
															   deviceNameChars,
															   kCFStringEncodingASCII);
			if ((CFStringCompare(deviceName, CFSTR("OHCI Root Hub Simulation"), 0) == kCFCompareEqualTo) ||
				(CFStringCompare(deviceName, CFSTR("UHCI Root Hub Simulation"), 0) == kCFCompareEqualTo)) {
				CFRelease(deviceName);
				deviceName = CFCopyLocalizedString(CFSTR("USB Bus"), "");
			} else if (CFStringCompare(deviceName, CFSTR("EHCI Root Hub Simulation"), 0) == kCFCompareEqualTo) {
				CFRelease(deviceName);
				deviceName = CFCopyLocalizedString(CFSTR("USB 2.0 Bus"), "");
			}

			// NSLog(@"USB Device Attached: %@" , deviceName);
			[(__bridge FFHelperApp *)refCon keyboardListChanged];
			CFRelease(deviceName);
		}

		IOObjectRelease(thisObject);
	}
}

static void usbDeviceRemoved(void *refCon, io_iterator_t iterator) {
#pragma unused(refCon)
//	NSLog(@"USB Device Removed Notification.");
	io_object_t thisObject;
	while ((thisObject = IOIteratorNext(iterator))) {
		kern_return_t	nameResult;
		io_name_t		deviceNameChars;

		//	This works with USB devices...
		//	but apparently not firewire
		nameResult = IORegistryEntryGetName(thisObject, deviceNameChars);
		CFStringRef deviceName = CFStringCreateWithCString(kCFAllocatorDefault,
														   deviceNameChars,
														   kCFStringEncodingASCII);
        if (CFStringCompare(deviceName, CFSTR("OHCI Root Hub Simulation"), 0) == kCFCompareEqualTo) {
            CFRelease(deviceName);
			deviceName = CFCopyLocalizedString(CFSTR("USB Bus"), "");
        }
        else if (CFStringCompare(deviceName, CFSTR("EHCI Root Hub Simulation"), 0) == kCFCompareEqualTo) {
            CFRelease(deviceName);
			deviceName = CFCopyLocalizedString(CFSTR("USB 2.0 Bus"), "");
        }

		// NSLog(@"USB Device Detached: %@" , deviceName);
		[(__bridge FFHelperApp *)refCon keyboardListChanged];
		CFRelease(deviceName);

		IOObjectRelease(thisObject);
	}
}

#pragma mark -

static void registerForUSBNotifications(void *refcon) {
	//http://developer.apple.com/documentation/DeviceDrivers/Conceptual/AccessingHardware/AH_Finding_Devices/chapter_4_section_2.html#//apple_ref/doc/uid/TP30000379/BABEACCJ
	kern_return_t	matchingResult;
	kern_return_t	removeNoteResult;
	io_iterator_t	addedIterator;
	io_iterator_t	removedIterator;

//	NSLog(@"registerForUSBNotifications");

	//	Setup a matching Dictionary.
	CFDictionaryRef myMatchDictionary;
	myMatchDictionary = IOServiceMatching(kIOUSBDeviceClassName);

	//	Register our notification
	matchingResult = IOServiceAddMatchingNotification(ioKitNotificationPort,
													  kIOPublishNotification,
													  myMatchDictionary,
													  usbDeviceAdded,
													  refcon,
													  &addedIterator);

	if (matchingResult)
		NSLog(@"matching notification registration failed: %d", matchingResult);

	//	Prime the Notifications (And Deal with the existing devices)...
	usbDeviceAdded(NULL, addedIterator);

	//	Register for removal notifications.
	//	It seems we have to make a new dictionary...  reusing the old one didn't work.

	myMatchDictionary = IOServiceMatching(kIOUSBDeviceClassName);
	removeNoteResult = IOServiceAddMatchingNotification(ioKitNotificationPort,
														kIOTerminatedNotification,
														myMatchDictionary,
														usbDeviceRemoved,
														refcon,
														&removedIterator);

	// Matching notification must be "primed" by iterating over the
	// iterator returned from IOServiceAddMatchingNotification(), so
	// we call our device removed method here...
	//
	if (kIOReturnSuccess != removeNoteResult)
		NSLog(@"Couldn't add device removal notification");
	else
		usbDeviceRemoved(NULL, removedIterator);

	notificationsArePrimed = true;
}

void USBNotifier_init(FFHelperApp *delegate) {
	notificationsArePrimed = false;
//#warning	kIOMasterPortDefault is only available on 10.2 and above...
	ioKitNotificationPort = IONotificationPortCreate(kIOMasterPortDefault);
	notificationRunLoopSource = IONotificationPortGetRunLoopSource(ioKitNotificationPort);

	CFRunLoopAddSource(CFRunLoopGetCurrent(),
					   notificationRunLoopSource,
					   kCFRunLoopDefaultMode);
	registerForUSBNotifications((__bridge void *)delegate);
}

void USBNotifier_dealloc(void) {
	if (ioKitNotificationPort) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), notificationRunLoopSource, kCFRunLoopDefaultMode);
		IONotificationPortDestroy(ioKitNotificationPort);
	}
}

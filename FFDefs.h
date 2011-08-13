/*
 *  FFDefs.h
 *  FunctionFlip
 *
 *  Created by Kevin Gessner on 9/3/08.
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
 *
 */

#ifndef FF_DEFS
#define FF_DEFS

// key codes from key events
#define KG_KEY_F1 122
#define KG_KEY_F2 120
#define KG_KEY_F3 99
#define KG_KEY_F4 118
#define KG_KEY_F5 96
#define KG_KEY_F6 97
#define KG_KEY_F7 98
#define KG_KEY_F8 100
#define KG_KEY_F9 101
#define KG_KEY_F10 109
#define KG_KEY_F11 103
#define KG_KEY_F12 111

// usage IDs from the hid
#define FF_F1_KEYID @"0x0007003a"
#define FF_F2_KEYID @"0x0007003b"
#define FF_F3_KEYID @"0x0007003c"
#define FF_F4_KEYID @"0x0007003d"
#define FF_F5_KEYID @"0x0007003e"
#define FF_F6_KEYID @"0x0007003f"
#define FF_F7_KEYID @"0x00070040"
#define FF_F8_KEYID @"0x00070041"
#define FF_F9_KEYID @"0x00070042"
#define FF_F10_KEYID @"0x00070043"
#define FF_F11_KEYID @"0x00070044"
#define FF_F12_KEYID @"0x00070045"

// usage IDs from the hid
#define FF_BRIGHTNESS_DOWN_ID_LAPTOP @"0x00ff0005" // for laptops
#define FF_BRIGHTNESS_UP_ID_LAPTOP @"0x00ff0004" // for laptops
#define FF_BRIGHTNESS_DOWN_ID_EXTERNAL @"0xff010021" // for external keyboards
#define FF_BRIGHTNESS_UP_ID_EXTERNAL @"0xff010020" // for external keyboards
#define FF_EXPOSE_ID @"0xff010010"
#define FF_DASHBOARD_ID @"0xff010002"
#define FF_LAUNCHPAD_ID @"0xff010004"
#define FF_ILLUMINATION_TOGGLE_ID @"0x00ff0007"
#define FF_ILLUMINATION_DOWN_ID @"0x00ff0009"
#define FF_ILLUMINATION_UP_ID @"0x00ff0008"
#define FF_VIDEO_MIRROR_ID @"0x00ff0006"
#define FF_REWIND_ID @"0x000C00B4"
#define FF_PLAYPAUSE_ID @"0x000C00CD"
#define FF_FASTFORWARD_ID @"0x000C00B3"
#define FF_MUTE_ID @"0x000C00E2"
#define FF_VOLUME_DOWN_ID @"0x000C00EA"
#define FF_VOLUME_UP_ID @"0x000C00E9"

// from http://www.opensource.apple.com/source/IOHIDFamily/IOHIDFamily-368.13/IOHIDFamily/IOHIDKeyboard.cpp,
// IOHIDKeyboard::defaultKeymapOfLength (grep for "dashboard")
#define KG_EXPOSE_KEY 160
#define KG_DASHBOARD_KEY 130
#define KG_LAUNCHPAD_KEY 131
#define KG_BRIGHTNESS_UP_KEY 144
#define KG_BRIGHTNESS_DOWN_KEY 145

// matches DDHidEvent -value
#define FF_KEY_DOWN 1
#define FF_KEY_UP 0

#define FF_PREFPANE_BUNDLE_IDENTIFIER @"com.kevingessner.FunctionFlip"
#define FF_HELPER_APP_BUNDLE_IDENTIFIER @"com.kevingessner.FFHelperApp"
#define FF_TERMINATE_NOTIFICATION @"Momento mori"
#define FF_UPDATE_URL @"http://kevingessner.com/update/functionflip"

#endif // !FF_DEFS

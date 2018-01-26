//
//  Utils.m
//  OneTouchInspection
//
//  Created by Ullas Joseph on 07/12/16.
//  Copyright © 2016 BeaconTree. All rights reserved.
//

#import "Utils.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Utils

#pragma mark - Private Functions

/**
 * Returns <code>YES</code> if the reader is plugged, otherwise <code>NO</code>.
 */
+ (BOOL)AJDIsReaderPlugged {
    
    BOOL plugged = NO;
    CFStringRef route = NULL;
    UInt32 routeSize = sizeof(route);
    
    if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route) == kAudioSessionNoError) {
        if (CFStringCompare(route, CFSTR("HeadsetInOut"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            plugged = YES;
        }
    }
    
    return plugged;
}

@end

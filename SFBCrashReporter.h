/*
 *  Copyright (C) 2009 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

// ========================================
// The main interface
// ========================================
@interface SFBCrashReporter : NSObject
{
}

// Ensure that SFBCrashReporterCrashSubmissionURL is set to a string in NSUserDefaults and call this!
+ (void) checkForNewCrashes;

@end

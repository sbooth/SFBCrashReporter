/*
 *  Copyright (C) 2009 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "SFBCrashReporter.h"
#import "SFBCrashReporterWindowController.h"

@interface SFBCrashReporter (Private)
+ (NSArray *) crashLogPaths;
@end

@implementation SFBCrashReporter

+ (void) checkForNewCrashes
{
	// If no URL is found for the submission, we can't do anything
	NSString *crashSubmissionURLString = [[NSUserDefaults standardUserDefaults] stringForKey:@"SFBCrashReporterCrashSubmissionURL"];
	if(!crashSubmissionURLString) {
		crashSubmissionURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFBCrashReporterCrashSubmissionURL"];
		if(!crashSubmissionURLString)
			[NSException raise:@"Missing SFBCrashReporterCrashSubmissionURL" format:@"You must specify the URL for crash log submission as the SFBCrashReporterCrashSubmissionURL in either Info.plist or the user defaults!"];
	}

	// Determine when the last crash was reported
	NSDate *lastCrashReportDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"SFBCrashReporterLastCrashReportDate"];
	
	// If a crash was never reported, use now as the starting point
	if(!lastCrashReportDate) {
		lastCrashReportDate = [NSDate date];
		[[NSUserDefaults standardUserDefaults] setObject:lastCrashReportDate forKey:@"SFBCrashReporterLastCrashReportDate"];
	}
	
	// Determine if it is even necessary to show the window (by comparing file modification dates to the last time a crash was reported)
	NSArray *crashLogPaths = [self crashLogPaths];
	for(NSString *path in crashLogPaths) {
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
		NSDate *fileModificationDate = [fileAttributes fileModificationDate];
		
		// If the last time a crash was reported is earlier than the file's modification date, allow the user to report the crash
		if(NSOrderedAscending == [lastCrashReportDate compare:fileModificationDate]) {
			[SFBCrashReporterWindowController showWindowForCrashLogPath:path submissionURL:[NSURL URLWithString:crashSubmissionURLString]];
			
			// Don't prompt more than once
			break;
		}
	}
}

@end

@implementation SFBCrashReporter (Private)

+ (NSArray *) crashLogPaths
{
	// Leopard crash logs have the form APPNAME_YYYY-MM-DD-hhmm_MACHINE.crash and are located in ~/Library/Logs/CrashReporter
	// See http://developer.apple.com/technotes/tn2004/tn2123.html
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	// FIXME: Would it be better to use NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) ?
	NSString *crashLogDirectory = [@"~/Library/Logs/CrashReporter/" stringByExpandingTildeInPath];

	NSMutableArray *paths = [[NSMutableArray alloc] init];

	NSString *file = nil;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:crashLogDirectory];
	while((file = [dirEnum nextObject]))
		if([file hasPrefix:applicationName])
			[paths addObject:[crashLogDirectory stringByAppendingPathComponent:file]];
	
	return [paths autorelease];
}

@end

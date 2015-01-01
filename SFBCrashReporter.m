/*
 *  Copyright (C) 2009, 2010, 2011, 2012, 2013, 2014, 2015 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFBCrashReporter.h"
#import "SFBCrashReporterWindowController.h"

@interface SFBCrashReporter (Private)
+ (NSArray *) crashLogDirectories;
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
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		NSDate *fileModificationDate = [fileAttributes fileModificationDate];
		
		// If the last time a crash was reported is earlier than the file's modification date, allow the user to report the crash
		if(fileModificationDate && NSOrderedAscending == [lastCrashReportDate compare:fileModificationDate]) {
			[SFBCrashReporterWindowController showWindowForCrashLogPath:path submissionURL:[NSURL URLWithString:crashSubmissionURLString]];
			
			// Don't prompt more than once
			break;
		}
	}
}

@end

@implementation SFBCrashReporter (Private)

+ (NSArray *) crashLogDirectories
{
	// Snow Leopard crash logs are located in ~/Library/Logs/DiagnosticReports
	NSString *crashLogDirectory = @"Logs/DiagnosticReports";

	NSMutableArray *crashFolderPaths = [[NSMutableArray alloc] init];
	
	NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask | NSLocalDomainMask, YES);
	for(NSString *libraryPath in libraryPaths) {
		NSString *path = [libraryPath stringByAppendingPathComponent:crashLogDirectory];
		
		BOOL isDir = NO;
		if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
			[crashFolderPaths addObject:path];
			break;
		}
	}
	
	return crashFolderPaths;
}

+ (NSArray *) crashLogPaths
{
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSArray *crashLogDirectories = [self crashLogDirectories];

	NSMutableArray *paths = [[NSMutableArray alloc] init];

	for(NSString *crashLogDirectory in crashLogDirectories) {
		NSString *file = nil;
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:crashLogDirectory];
		while((file = [dirEnum nextObject]))
			if([file hasPrefix:applicationName])
				[paths addObject:[crashLogDirectory stringByAppendingPathComponent:file]];
	}
	
	return paths;
}

@end

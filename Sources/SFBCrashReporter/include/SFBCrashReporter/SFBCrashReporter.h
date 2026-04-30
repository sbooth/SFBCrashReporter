//
// SPDX-FileCopyrightText: 2009 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/SFBCrashReporter
//

#import <Foundation/Foundation.h>

/*! @brief The interface for crash reporting */
@interface SFBCrashReporter : NSObject

/*!
 * @brief Check for new crash logs, and if any are found present a window to the user allowing
 * them to report the crash or discard the log.
 *
 * The crash information will be submitted to the URL specified by the key \c SFBCrashReporterCrashSubmissionURL
 * from your application's \c Info.plist or NSUserDefaults.
 */
+ (void)checkForNewCrashes;

@end

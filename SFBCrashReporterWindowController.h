/*
 * Copyright (C) 2009 - 2020 Stephen F. Booth <me@sbooth.org>
 * See https://github.com/sbooth/SFBCrashReporter/blob/master/LICENSE.txt for license information
 */

#import <Cocoa/Cocoa.h>

// ========================================
// The main class for SFBCrashReporter
// ========================================
@interface SFBCrashReporterWindowController : NSWindowController
{}

// ========================================
// Properties
@property (nonatomic, strong, nullable) NSString * emailAddress;
@property (nonatomic, strong, nonnull) NSString * crashLogPath;
@property (nonatomic, strong, nonnull) NSURL * submissionURL;

// ========================================
// IB Outlets
@property (nonatomic, assign, nullable) IBOutlet NSTextView * commentsTextView; // weak property type not available for NSTextView
@property (nonatomic, weak, nullable) IBOutlet NSButton * reportButton;
@property (nonatomic, weak, nullable) IBOutlet NSButton * ignoreButton;
@property (nonatomic, weak, nullable) IBOutlet NSButton * discardButton;
@property (nonatomic, weak, nullable) IBOutlet NSProgressIndicator * progressIndicator;

// ========================================
// Always use this to show the window- do not alloc/init directly
+ (void) showWindowForCrashLogPath:(nonnull NSString *)path submissionURL:(nonnull NSURL *)submissionURL;

// ========================================
// Action methods
- (IBAction) sendReport:(nullable id)sender;
- (IBAction) ignoreReport:(nullable id)sender;
- (IBAction) discardReport:(nullable id)sender;

@end

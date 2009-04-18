/*
 *  Copyright (C) 2009 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "SFBCrashReporterWindowController.h"
#import "SFBSystemInformation.h"
#import "GenerateFormData.h"

#import <AddressBook/AddressBook.h>

@interface SFBCrashReporterWindowController (Callbacks)
- (void) didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void  *)contextInfo;
- (void) showSubmissionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end

@interface SFBCrashReporterWindowController (Private)
- (NSString *) applicationName;
- (void) sendCrashReport;
@end

@implementation SFBCrashReporterWindowController

@synthesize emailAddress = _emailAddress;
@synthesize crashLogPath = _crashLogPath;
@synthesize submissionURL = _submissionURL;

+ (void) initialize
{
	// Register reasonable defaults for most preferences
	NSMutableDictionary *defaultsDictionary = [NSMutableDictionary dictionary];
	
	[defaultsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"SFBCrashReporterIncludeAnonymousSystemInformation"];
	[defaultsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"SFBCrashReporterIncludeEmailAddress"];
		
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

+ (void) showWindowForCrashLogPath:(NSString *)crashLogPath submissionURL:(NSURL *)submissionURL
{
	NSParameterAssert(nil != crashLogPath);
	NSParameterAssert(nil != submissionURL);

	SFBCrashReporterWindowController *windowController = [[self alloc] init];
	
	windowController.crashLogPath = crashLogPath;
	windowController.submissionURL = submissionURL;
	
	[windowController showWindow:self];

	// Don't explicitly release the window controller- just let nature run its course
	[windowController autorelease];
}

// Should not be called directly by anyone except this class
- (id) init
{
	return [super initWithWindowNibName:@"SFBCrashReporterWindow" owner:self];
}

- (void) dealloc
{
	[_emailAddress release], _emailAddress = nil;
	[_crashLogPath release], _crashLogPath = nil;
	[_submissionURL release], _submissionURL = nil;
	[_urlConnection release], _urlConnection = nil;

	[super dealloc];
}

- (void) windowDidLoad
{
	// Populate the e-mail field with the users primary e-mail address
	ABMultiValue *emailAddresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABEmailProperty];
	self.emailAddress = (NSString *)[emailAddresses valueForIdentifier:[emailAddresses primaryIdentifier]];
	
	// Select the comments text
	[_commentsTextView setSelectedRange:NSMakeRange(0, NSUIntegerMax)];
}

// Send the report off
- (IBAction) sendReport:(id)sender
{
	[self sendCrashReport];
}

// Don't do anything except dismiss our window
- (IBAction) ignoreReport:(id)sender
{
	[[self window] orderOut:self];
}

// Delete the crash log since the user isn't interested in submitting it
- (IBAction) discardReport:(id)sender
{
	NSError *error = nil;
	if(![[NSFileManager defaultManager] removeItemAtPath:self.crashLogPath error:&error])
		[self presentError:error modalForWindow:[self window] delegate:self didPresentSelector:@selector(didPresentErrorWithRecovery:contextInfo:) contextInfo:NULL];
	else
		[[self window] orderOut:self];
}

@end

@implementation SFBCrashReporterWindowController (Callbacks)

- (void) didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void  *)contextInfo
{
	// Just dismiss our window
	[[self window] orderOut:self];
}

- (void) showSubmissionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// Whether success or failure, all that remains is to close the window
	[[self window] orderOut:self];
}

@end

@implementation SFBCrashReporterWindowController (Private)

// Convenience method for bindings
- (NSString *) applicationName
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

// Do the actual work of building the HTTP POST and submitting it
- (void) sendCrashReport
{
	NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
	
	// Append system information, if specified
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SFBCrashReporterIncludeAnonymousSystemInformation"]) {
		SFBSystemInformation *systemInformation = [[SFBSystemInformation alloc] init];
		
		[formValues setObject:[systemInformation machine] forKey:@"machine"];
		[formValues setObject:[systemInformation model] forKey:@"model"];
		[formValues setObject:[systemInformation physicalMemory] forKey:@"numberOfCPUs"];
		[formValues setObject:[systemInformation numberOfCPUs] forKey:@"physicalMemory"];
		[formValues setObject:[systemInformation busFrequency] forKey:@"busFrequency"];
		[formValues setObject:[systemInformation CPUFrequency] forKey:@"CPUFrequency"];
		[formValues setObject:[systemInformation CPUFamily] forKey:@"CPUFamily"];
		[formValues setObject:[systemInformation modelName] forKey:@"modelName"];
		[formValues setObject:[systemInformation CPUFamilyName] forKey:@"CPUFamilyName"];
		[formValues setObject:[systemInformation systemVersion] forKey:@"systemVersion"];
		[formValues setObject:[systemInformation systemBuildVersion] forKey:@"systemBuildVersion"];
		
		[systemInformation release], systemInformation = nil;
	}
	
	// Include email address, if permitted
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SFBCrashReporterIncludeEmailAddress"])
		[formValues setObject:self.emailAddress forKey:@"emailAddress"];
	
	// The most important item of all
	[formValues setObject:[NSURL fileURLWithPath:self.crashLogPath] forKey:@"crashLog"];

	// Generate the form data
	NSString *boundary = @"0xKhTmLbOuNdArY";
	NSData *formData = GenerateFormData(formValues, boundary);
	
	// Set up the HTTP request
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.submissionURL];
	
	[urlRequest setHTTPMethod:@"POST"];

	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	[urlRequest setValue:@"SFBCrashReporter" forHTTPHeaderField:@"User-Agent"];
	[urlRequest setValue:[NSString stringWithFormat:@"%lu", [formData length]] forHTTPHeaderField:@"Content-Length"];

	[urlRequest setHTTPBody:formData];
	
	[_progressIndicator startAnimation:self];

	[_reportButton setEnabled: NO];
	[_ignoreButton setEnabled: NO];
	[_discardButton setEnabled: NO];
	
	// Submit the URL request
	_urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[_urlConnection release], _urlConnection = nil;
	
	// Use the file's modification date as the last submitted crash date
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:self.crashLogPath traverseLink:YES];
	NSDate *fileModificationDate = [fileAttributes fileModificationDate];

	[[NSUserDefaults standardUserDefaults] setObject:fileModificationDate forKey:@"SFBCrashReporterLastCrashReportDate"];
	
	[self performSelectorOnMainThread: @selector(showSubmissionSucceededSheet) withObject:nil waitUntilDone:NO];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_urlConnection release], _urlConnection = nil;

	[self performSelectorOnMainThread:@selector(showSubmissionFailedSheet:) withObject:error waitUntilDone:NO];
}

- (void) showSubmissionSucceededSheet
{
	[_progressIndicator stopAnimation:self];

	// Use the file's modification date as the last submitted crash date
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:self.crashLogPath traverseLink:YES];
	NSDate *fileModificationDate = [fileAttributes fileModificationDate];

	[[NSUserDefaults standardUserDefaults] setObject:fileModificationDate forKey:@"SFBCrashReporterLastCrashReportDate"];

	// Delete the crash log since it is no longer needed
	NSError *error = nil;
	if(![[NSFileManager defaultManager] removeItemAtPath:self.crashLogPath error:&error]) {
		[self presentError:error modalForWindow:[self window] delegate:self didPresentSelector:@selector(didPresentErrorWithRecovery:contextInfo:) contextInfo:NULL];
		return;
	}
	
	NSBeginAlertSheet(NSLocalizedString(@"The crash report was succesfully submitted.", @""), nil /* Use the default button title, */, nil, nil, [self window], self, @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), NULL, NULL, NSLocalizedString(@"Thank you for taking the time to help improve %@!", @""), [self applicationName]);
}

- (void) showSubmissionFailedSheet:(NSError *)error
{
	NSParameterAssert(nil != error);
	
	[_progressIndicator stopAnimation:self];

	NSBeginAlertSheet(NSLocalizedString(@"An error occurred while submitting the crash report.", @""), nil /* Use the default button title, */, nil, nil, [self window], self, @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), NULL, NULL, NSLocalizedString(@"The error was: %@", @""), [error localizedDescription]);
}

@end

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
- (void) showSubmissionSucceededSheet;
- (void) showSubmissionFailedSheet:(NSError *)error;
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
	[_responseData release], _responseData = nil;

	[super dealloc];
}

- (void) windowDidLoad
{
	// Set the window's title
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString *applicationShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

	NSString *windowTitle = [NSString stringWithFormat:NSLocalizedString(@"Crash Reporter - %@ (%@)", @""), applicationName, applicationShortVersion];
	[[self window] setTitle:windowTitle];
	
	// Populate the e-mail field with the users primary e-mail address
	ABMultiValue *emailAddresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABEmailProperty];
	self.emailAddress = (NSString *)[emailAddresses valueForIdentifier:[emailAddresses primaryIdentifier]];
	
	// Select the comments text
	[_commentsTextView setSelectedRange:NSMakeRange(0, NSUIntegerMax)];
}

#pragma mark Action Methods

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
		[formValues setObject:[systemInformation physicalMemory] forKey:@"physicalMemory"];
		[formValues setObject:[systemInformation numberOfCPUs] forKey:@"numberOfCPUs"];
		[formValues setObject:[systemInformation busFrequency] forKey:@"busFrequency"];
		[formValues setObject:[systemInformation CPUFrequency] forKey:@"CPUFrequency"];
		[formValues setObject:[systemInformation CPUFamily] forKey:@"CPUFamily"];
		[formValues setObject:[systemInformation modelName] forKey:@"modelName"];
		[formValues setObject:[systemInformation CPUFamilyName] forKey:@"CPUFamilyName"];
		[formValues setObject:[systemInformation systemVersion] forKey:@"systemVersion"];
		[formValues setObject:[systemInformation systemBuildVersion] forKey:@"systemBuildVersion"];

		[formValues setObject:[NSNumber numberWithBool:YES] forKey:@"systemInformationIncluded"];

		[systemInformation release], systemInformation = nil;
	}
	else
		[formValues setObject:[NSNumber numberWithBool:NO] forKey:@"systemInformationIncluded"];
	
	// Include email address, if permitted
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SFBCrashReporterIncludeEmailAddress"])
		[formValues setObject:self.emailAddress forKey:@"emailAddress"];
	
	// Optional comments
	NSAttributedString *attributedComments = [_commentsTextView attributedSubstringFromRange:NSMakeRange(0, NSUIntegerMax)];
	if([[attributedComments string] length])
		[formValues setObject:[attributedComments string] forKey:@"comments"];
	
	// The most important item of all
	[formValues setObject:[NSURL fileURLWithPath:self.crashLogPath] forKey:@"crashLog"];

	// Add the application information
	[formValues setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] forKey:@"applicationName"];
	[formValues setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"applicationIdentifier"];
	[formValues setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"applicationVersion"];
	[formValues setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"applicationShortVersion"];
	
	// Create a date formatter
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	// Determine which locale the developer would like dates/times in
	NSString *localeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"SFBCrashReporterPreferredReportingLocale"];
	if(!localeName) {
		localeName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFBCrashReporterPreferredReportingLocale"];
		// US English is the default
		if(!localeName)
			localeName = @"en_US";
	}
	
	NSLocale *localeToUse = [[NSLocale alloc] initWithLocaleIdentifier:localeName];
	[dateFormatter setLocale:localeToUse];

	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
	// Include the date and time
	[formValues setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"date"];
		
	[localeToUse release], localeToUse = nil;
	[dateFormatter release], dateFormatter = nil;
	
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

- (void) showSubmissionSucceededSheet
{
	[_progressIndicator stopAnimation:self];
		
	NSBeginAlertSheet(NSLocalizedString(@"The crash report was successfully submitted.", @""), nil /* Use the default button title, */, nil, nil, [self window], self, @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), NULL, NULL, NSLocalizedString(@"Thank you for taking the time to help improve %@!", @""), [self applicationName]);
}

- (void) showSubmissionFailedSheet:(NSError *)error
{
	NSParameterAssert(nil != error);
	
	[_progressIndicator stopAnimation:self];
	
	NSBeginAlertSheet(NSLocalizedString(@"An error occurred while submitting the crash report.", @""), nil /* Use the default button title, */, nil, nil, [self window], self, @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), NULL, NULL, NSLocalizedString(@"The error was: %@", @""), [error localizedDescription]);
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	// A valid response is simply the string 'ok'
	NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	BOOL responseOK = [responseString isEqualToString:@"ok"];

	[responseString release], responseString = nil;
	[_urlConnection release], _urlConnection = nil;
	[_responseData release], _responseData = nil;
	
	if(responseOK) {
		// Create our own instance since this method could be called from a background thread
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		// Use the file's modification date as the last submitted crash date
		NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:self.crashLogPath traverseLink:YES];
		NSDate *fileModificationDate = [fileAttributes fileModificationDate];
		
		[[NSUserDefaults standardUserDefaults] setObject:fileModificationDate forKey:@"SFBCrashReporterLastCrashReportDate"];
		
		// Delete the crash log since it is no longer needed
		NSError *error = nil;
		if(![fileManager removeItemAtPath:self.crashLogPath error:&error])
			NSLog(@"SFBCrashReporter error: Unable to delete the submitted crash log (%@): %@", [self.crashLogPath lastPathComponent], [error localizedDescription]);

		[fileManager release], fileManager = nil;
		
		// Even though the log wasn't deleted, submission was still successful
		[self performSelectorOnMainThread: @selector(showSubmissionSucceededSheet) withObject:nil waitUntilDone:NO];
	}
	// An error occurred on the server
	else {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unrecognized response from the server", @""), NSLocalizedDescriptionKey, nil];
		NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EPROTO userInfo:userInfo];

		[self performSelectorOnMainThread: @selector(showSubmissionFailedSheet:) withObject:error waitUntilDone:NO];
	}
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_urlConnection release], _urlConnection = nil;
	[_responseData release], _responseData = nil;

	[self performSelectorOnMainThread:@selector(showSubmissionFailedSheet:) withObject:error waitUntilDone:NO];
}

@end

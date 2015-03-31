Pod::Spec.new do |s|
	s.name					= "SFBCrashReporter"
	s.version				= "1.0.0"
	s.summary				= "A framework for submitting application crash logs to an HTTP server."
	s.description			= <<-DESC
Adding `SFBCrashReporter` support to your application is easy:

1.  Add the URL for crash log submission as `SFBCrashReporterCrashSubmissionURL` to your application's `Info.plist`

2.  Add the following code to your application's delegate:

```objective-c
#import <SFBCrashReporter/SFBCrashReporter.h>

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Check for and send crash reports
  [SFBCrashReporter checkForNewCrashes];
}
```
							DESC
	s.homepage				= "https://github.com/sbooth/SFBCrashReporter"
	s.license				= { :type => "MIT", :file => "COPYING" }
	s.author				= { "Stephen F. Booth" => "me@sbooth.org" }
	s.social_media_url		= "http://twitter.com/sbooth"
	s.platform				= :osx, "10.7"
	s.source       			= { :git => "https://github.com/sbooth/SFBCrashReporter.git", :tag => "1.0.0" }
	s.source_files  		= "GenerateFormData.{h,m}", "SFBCrashReporter.{h,m}", "SFBCrashReporterWindowController.{h,m}", "SFBSystemInformation.{h,m}"
	s.public_header_files 	= "SFBCrashReporter.h", "SFBSystemInformation.h"
	s.requires_arc 			= true
	s.frameworks			= "AddressBook", "Cocoa"
end

# SFBCrashReporter

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsbooth%2FSFBCrashReporter%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/sbooth/SFBCrashReporter)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsbooth%2FSFBCrashReporter%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/sbooth/SFBCrashReporter)

`SFBCrashReporter` is a framework for submitting application crash logs to an HTTP server.

## Installation

### Swift Package Manager

Add a package dependency to https://github.com/sbooth/SFBCrashReporter in Xcode.

### Manual or Custom Build

1. Clone the [SFBCrashReporter](https://github.com/sbooth/SFBCrashReporter) repository.
2. `swift build`.

## Usage

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

Adding support to your HTTP server to receive the crash logs is also easy.  `SFBCrashReporter` comes with a PHP script that will e-mail the submitted crash logs to a specified email account.

0.  Install PHP!

1.  Modify <tt>handle_crash_report.php</tt> as appropriate.

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

#import "GenerateFormData.h"

NSData *
GenerateFormData(NSDictionary *formValues, NSString *boundary)
{
	NSCParameterAssert(nil != formValues);
	NSCParameterAssert(nil != boundary);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	// Iterate over the form elements' keys and append their values
	NSArray *keys = [formValues allKeys];
	for(NSString *key in keys) {
		id value = [formValues valueForKey:key];
		
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
		
		// String value
		if([value isKindOfClass:[NSString class]]) {
			NSString *string = (NSString *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// Number value
		else if([value isKindOfClass:[NSNumber class]]) {
			NSNumber *number = (NSNumber *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[number stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// URL value (only file URLs are supported)
		else if([value isKindOfClass:[NSURL class]] && [(NSURL *)value isFileURL]) {
			NSURL *url = (NSURL *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[url path] lastPathComponent]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[NSData dataWithContentsOfURL:url]];
		}
		// Illegal class
		else
			NSLog(@"SFBCrashReporterError: formValues contained illegal object %@ of class %@", value, [value class]);
		
		[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
	return result;
}

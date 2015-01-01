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

#import "SFBSystemInformation.h"

#include <sys/sysctl.h>
#include <mach/machine.h>

// ========================================
// Utility functions for common sysctl to Cocoa tasks
// ========================================
static NSString * stringForMIB(int *mib, u_int mib_length, NSError **error)
{
	NSCParameterAssert(NULL != mib);
	
	char *buffer = NULL;
	size_t length = 0;
	
	// Determine the size of the data
	if(-1 == sysctl(mib, mib_length, NULL, &length, NULL, 0)) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	// Allocate space (includes the terminator)
	buffer = malloc(length);
	if(!buffer) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOMEM userInfo:nil];
		return nil;
	}
	
	// Fetch the property
	if(-1 == sysctl(mib, mib_length, buffer, &length, NULL, 0)) {
		free(buffer), buffer = NULL;
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	// Ensure the memory is freed if an error occurs
	NSString *result = [[NSString alloc] initWithBytesNoCopy:buffer length:(length - 1) encoding:NSASCIIStringEncoding freeWhenDone:YES];
	if(!result) {
		free(buffer), buffer = NULL;
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	return result;
}

static NSNumber * intForMIB(int *mib, u_int mib_length, NSError **error)
{
	NSCParameterAssert(NULL != mib);
	
	int value = 0;
	size_t length = sizeof(value);
	
	// Fetch the property
	if(-1 == sysctl(mib, mib_length, &value, &length, NULL, 0)) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	return [NSNumber numberWithInt:value];
}

static NSNumber * int64ForMIB(int *mib, u_int mib_length, NSError **error)
{
	NSCParameterAssert(NULL != mib);
	
	int64_t value = 0;
	size_t length = sizeof(value);
	
	// Fetch the property
	if(-1 == sysctl(mib, mib_length, &value, &length, NULL, 0)) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	return [NSNumber numberWithLongLong:value];
}

static NSNumber * int32ForSysctlName(const char *name, NSError **error)
{
	NSCParameterAssert(NULL != name);
	
	int32_t value = 0;
	size_t length = sizeof(value);
	
	// Fetch the property
	if(-1 == sysctlbyname(name, &value, &length, NULL, 0)) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	return [NSNumber numberWithLong:value];
}

static NSNumber * int64ForSysctlName(const char *name, NSError **error)
{
	NSCParameterAssert(NULL != name);
	
	int64_t value = 0;
	size_t length = sizeof(value);
	
	// Fetch the property
	if(-1 == sysctlbyname(name, &value, &length, NULL, 0)) {
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		return nil;
	}
	
	return [NSNumber numberWithLongLong:value];
}

@implementation SFBSystemInformation

+ (SFBSystemInformation *) instance
{
	static dispatch_once_t pred = 0;
	static SFBSystemInformation *sharedInstance = nil;

	dispatch_once(&pred, ^{
		sharedInstance = [[SFBSystemInformation alloc] init];
	});

	return sharedInstance;
}

- (NSString *) machine
{
	int mib [] = { CTL_HW, HW_MACHINE };
	return stringForMIB(mib, 2, NULL);
}

- (NSString *) model
{
	int mib [] = { CTL_HW, HW_MODEL };
	return stringForMIB(mib, 2, NULL);
}

- (NSNumber *) physicalMemory
{
	int mib [] = { CTL_HW, HW_MEMSIZE };
	return int64ForMIB(mib, 2, NULL);
}

- (NSNumber *) busFrequency
{
	return int64ForSysctlName("hw.busfrequency", NULL);
}

- (NSNumber *) CPUFrequency
{
	return int64ForSysctlName("hw.cpufrequency", NULL);
}

- (NSNumber *) CPUFamily
{
	return int32ForSysctlName("hw.cpufamily", NULL);
}

- (NSNumber *) CPUType
{
	return int32ForSysctlName("hw.cputype", NULL);
}

- (NSNumber *) CPUSubtype
{
	return int32ForSysctlName("hw.cpusubtype", NULL);
}

- (NSNumber *) numberOfCPUs
{
	int mib [] = { CTL_HW, HW_NCPU };
	return intForMIB(mib, 2, NULL);
}

- (NSNumber *) physicalCPUs
{
	return int32ForSysctlName("hw.physicalcpu", NULL);
}

- (NSNumber *) logicalCPUs
{
	return int32ForSysctlName("hw.logicalcpu", NULL);
}

- (NSString *) systemVersion
{
	NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	return [systemVersionDictionary objectForKey:@"ProductVersion"];
}

- (NSString *) systemBuildVersion
{
	NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	return [systemVersionDictionary objectForKey:@"ProductBuildVersion"];
}

@end

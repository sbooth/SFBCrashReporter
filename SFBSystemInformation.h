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

#import <Cocoa/Cocoa.h>

// ========================================
// Utility class for accessing useful system information
// ========================================
@interface SFBSystemInformation : NSObject
{}

// The shared instance
+ (SFBSystemInformation *) instance;

// Hardware information
- (NSString *) machine;			// Machine class: "x86_64"
- (NSString *) model;			// Machine model: "MacBookPro8,2"

- (NSNumber *) physicalMemory;	// in bytes
- (NSNumber *) busFrequency;	// in hertz
- (NSNumber *) CPUFrequency;	// in hertz

// See /usr/include/mach/machine.h for possible values
- (NSNumber *) CPUFamily;
- (NSNumber *) CPUType;
- (NSNumber *) CPUSubtype;

- (NSNumber *) numberOfCPUs;	// The maximum number of processors that could be available
- (NSNumber *) physicalCPUs;	// The number of physical processors in the current power mgmt mode
- (NSNumber *) logicalCPUs;		// The number of logical processors in the current power mgmt mode

// Mac OS version information
- (NSString *) systemVersion;
- (NSString *) systemBuildVersion;

@end

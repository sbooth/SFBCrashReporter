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

/*! @brief Utility class for accessing useful system information */
@interface SFBSystemInformation : NSObject
{}

/*! @brief The shared instance */
+ (SFBSystemInformation *) instance;

#pragma mark Hardware information

/*! @brief The machine class, for example \c x86_64 */
- (NSString *) machine;

/*! @brief The machine model, for example \c MacBookPro8,2 */
- (NSString *) model;


/*! @brief The physical memory in bytes */
- (NSNumber *) physicalMemory;

/*! @brief The bus frequency in hertz */
- (NSNumber *) busFrequency;

/*! @brief The CPU frequency in hertz */
- (NSNumber *) CPUFrequency;


// See /usr/include/mach/machine.h for possible values

/*! @brief The CPU family */
- (NSNumber *) CPUFamily;

/*! @brief The CPU type */
- (NSNumber *) CPUType;

/*! @brief The CPU subtype */
- (NSNumber *) CPUSubtype;

/*! @brief The maximum number of processors that could be available */
- (NSNumber *) numberOfCPUs;

/*! @brief The number of physical processors in the current power management mode */
- (NSNumber *) physicalCPUs;

/*! @brief The number of logical processors in the current power management mode */
- (NSNumber *) logicalCPUs;


#pragma mark Mac OS version information

/*! @brief The version of Mac OS X, for example \c 10.10.2 */
- (NSString *) systemVersion;

/*! @brief The build version of Mac OS X, for example \c 14C1514 */
- (NSString *) systemBuildVersion;

@end

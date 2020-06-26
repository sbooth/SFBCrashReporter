/*
 * Copyright (C) 2009 - 2020 Stephen F. Booth <me@sbooth.org>
 * See https://github.com/sbooth/SFBCrashReporter/blob/master/LICENSE.txt for license information
 */

#import <Cocoa/Cocoa.h>

/*! @brief Utility class for accessing useful system information */
@interface SFBSystemInformation : NSObject

/*! @brief The shared instance */
+ (nonnull SFBSystemInformation *)instance;

#pragma mark Hardware information

/*! @brief The machine class, for example \c x86_64 */
- (nullable NSString *)machine;

/*! @brief The machine model, for example \c MacBookPro8,2 */
- (nullable NSString *)model;


/*! @brief The physical memory in bytes */
- (nullable NSNumber *)physicalMemory;

/*! @brief The bus frequency in hertz */
- (nullable NSNumber *)busFrequency;

/*! @brief The CPU frequency in hertz */
- (nullable NSNumber *)cpuFrequency;
- (nullable NSNumber *)CPUFrequency __attribute__((deprecated("", "cpuFrequency")));


// See /usr/include/mach/machine.h for possible values

/*! @brief The CPU family */
- (nullable NSNumber *)cpuFamily;
- (nullable NSNumber *)CPUFamily __attribute__((deprecated("", "cpuFamily")));

/*! @brief The CPU type */
- (nullable NSNumber *)cpuType;
- (nullable NSNumber *)CPUType __attribute__((deprecated("", "cpuType")));

/*! @brief The CPU subtype */
- (nullable NSNumber *)cpuSubtype;
- (nullable NSNumber *)CPUSubtype __attribute__((deprecated("", "cpuSubtype")));

/*! @brief The maximum number of processors that could be available */
- (nullable NSNumber *)numberOfCPUs;

/*! @brief The number of physical processors in the current power management mode */
- (nullable NSNumber *)physicalCPUs;

/*! @brief The number of logical processors in the current power management mode */
- (nullable NSNumber *)logicalCPUs;


#pragma mark Mac OS version information

/*! @brief The version of Mac OS X, for example \c 10.10.2 */
- (nullable NSString *)systemVersion;

/*! @brief The build version of Mac OS X, for example \c 14C1514 */
- (nullable NSString *)systemBuildVersion;

@end

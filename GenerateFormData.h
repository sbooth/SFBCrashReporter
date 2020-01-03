/*
 * Copyright (C) 2009 - 2020 Stephen F. Booth <me@sbooth.org>
 * See https://github.com/sbooth/SFBCrashReporter/blob/master/LICENSE.txt for license information
 */

#pragma once

#import <Cocoa/Cocoa.h>

// ========================================
// Generates multipart/form-data from the given dictionary using the specified boundary
// ========================================
NSData * _Nonnull GenerateFormData(NSDictionary<NSString *, NSObject *> * _Nonnull formValues, NSString * _Nonnull boundary) NS_RETURNS_RETAINED;

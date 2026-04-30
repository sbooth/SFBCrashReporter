//
// SPDX-FileCopyrightText: 2009 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/SFBCrashReporter
//

#pragma once

#import <AppKit/AppKit.h>

// ========================================
// Generates multipart/form-data from the given dictionary using the specified boundary
// ========================================
NSData * _Nonnull SFBGenerateFormData(NSDictionary<NSString *, NSObject *> * _Nonnull formValues, NSString * _Nonnull boundary) NS_RETURNS_RETAINED;

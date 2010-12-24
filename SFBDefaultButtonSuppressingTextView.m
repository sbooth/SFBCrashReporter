//
//  SFBDefaultButtonSuppressingTextView.m
//  SFBCrashReporter
//
//  Created by Nicholas Riley on 12/24/10.
//  Copyright 2010 sbooth.org. All rights reserved.
//

#import "SFBDefaultButtonSuppressingTextView.h"

// The default button still appears as default even when it can't be triggered by Return.  This is confusing.  Since only Enter will trigger the default button while the text view is active, don't mark it as such.

@implementation SFBDefaultButtonSuppressingTextView

- (BOOL)becomeFirstResponder;
{
    if (![super becomeFirstResponder])
        return NO;
    
    defaultButtonCell = [[self window] defaultButtonCell];
    [defaultButtonCell setKeyEquivalent:@"\x3"]; // Enter
    
    return YES;
}

- (BOOL)resignFirstResponder;
{
    if (![super resignFirstResponder])
        return NO;
        
    [defaultButtonCell setKeyEquivalent:@"\r"];
        
    return YES;
}

@end

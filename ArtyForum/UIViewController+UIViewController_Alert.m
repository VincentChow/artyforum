//
//  UIViewController+UIViewController_Alert.m
//  1ADApp
//
//  Created by Erik Österberg on 2013-06-27.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "UIViewController+UIViewController_Alert.h"

@implementation UIViewController (UIViewController_Alert)

-(void)alertWithMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:nil
                                      message:message
                                     delegate:nil
                            cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]show];
}

@end

//
//  NewThreadViewController.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-02.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateThreadViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textInput;
- (IBAction)didPressCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

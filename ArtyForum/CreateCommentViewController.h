//
//  CreateCommentViewController.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-04.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateCommentViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) NSString *inThreadId;
@property (nonatomic) NSString *inThreadNamed;

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressPost:(id)sender;


@end

//
//  CreateCommentViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-04.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "CommentsViewController.h"
#import "CreateCommentViewController.h"
#import "UIViewController+UIViewController_Alert.h"
#import "Server.h"
#import "Comment.h"

@interface CreateCommentViewController ()

@end

@implementation CreateCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    self.titleLabel.text = [NSString stringWithFormat:@"In thread: %@", self.inThreadNamed];
    [self.textView becomeFirstResponder];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

-(void)didChangeOrientation {
    CGRect rect = self.textView.frame;
    self.textView.frame = [[UIDevice currentDevice]orientation] <= 1 ? CGRectMake(20, 85, rect.size.width, 128) : CGRectMake(20, 85, rect.size.width, 45);
}




- (void) addComment:(NSDictionary *)response {
    
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    CommentsViewController *commentsView = (CommentsViewController *) navController.topViewController;
    
    NSDateFormatter *form = [[NSDateFormatter alloc]init];
    [form setDateFormat:@"d MMM yyyy HH:mm"];
    
    Comment *comment = [[Comment alloc]init];
    comment.id = response[@"id"];
    comment.rev = response[@"rev"];
    comment.creator = commentsView.username;
    comment.text = self.textView.text;
    comment.time = [form stringFromDate:[NSDate date]];
    [commentsView.comments addObject:comment];
    [commentsView reloadTable];
    
    navController = nil;
    commentsView = nil;
    
    [self backToComments];
}

-(void)commentCreationDidFail {
    [self.activityIndicator stopAnimating];
    [self alertWithMessage:@"Could not create comment! Please try again later."];
    self.textView.editable = YES;
}

- (IBAction)didPressCancel:(id)sender {
    [self backToComments];
}

- (IBAction)didPressPost:(id)sender {
    if (self.textView.text.length < 4) {
        [self alertWithMessage:@"Thread must be at least 5 characters!"];
    } else {
        self.textView.editable = NO;
        [self.activityIndicator startAnimating];
        [Server post:@{@"txt": self.textView.text, @"thrnm": self.inThreadNamed, @"thr": self.inThreadId} toPath:@"comments" onCompletion:^(NSDictionary *response, NSError *error) {
            if (response && response[@"ok"]) {
                [self performSelectorOnMainThread:@selector(addComment:) withObject:response waitUntilDone:YES];
            } else if (response) {
                NSLog(@"%@",response);
                [self performSelectorOnMainThread:@selector(commentCreationDidFail) withObject:nil waitUntilDone:YES];
            } else {
                [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
            }
        }];
    }
}

-(void)backToComments {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
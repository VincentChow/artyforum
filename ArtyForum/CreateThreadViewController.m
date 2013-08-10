//
//  NewThreadViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-02.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "CreateThreadViewController.h"
#import "Server.h"
#import "UIViewController+UIViewController_Alert.h"
#import "ThreadsViewController.h"
#import "Thread.h"

@interface CreateThreadViewController ()

@end

@implementation CreateThreadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textInput.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"New thread";
    [self.textInput becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.textInput.text.length < 4) {
        [self alertWithMessage:@"Thread must be at least 5 characters!"];
    } else {
        self.textInput.enabled = NO;
        [self.activityIndicator startAnimating];
        [Server post:@{@"txt": self.textInput.text} toPath:@"threads" onCompletion:^(NSDictionary *response, NSError *error) {
            if (response && response[@"ok"]) {
                [self performSelectorOnMainThread:@selector(addThread:) withObject:response waitUntilDone:YES];
            } else if (response) {
                [self performSelectorOnMainThread:@selector(threadCreationDidFail) withObject:nil waitUntilDone:YES];
            } else {
                [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
            }            
        }];
    }
    return NO;
}

- (IBAction)didPressCancel:(id)sender {
    [self backToThreads];
}

- (void) addThread:(NSDictionary *)response {
    
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    ThreadsViewController *threadsView = (ThreadsViewController *) navController.topViewController;
      
    NSDateFormatter *form = [[NSDateFormatter alloc]init];
    [form setDateFormat:@"d MMM yyyy"];
    
    Thread *thread = [[Thread alloc]init];
    thread.id = response[@"id"];
    thread.rev = response[@"rev"];
    thread.creator = threadsView.username;
    thread.text = self.textInput.text;
    thread.time = [form stringFromDate:[NSDate date]];    
    [threadsView.threads addObject:thread];    
    [threadsView reloadTable];

    navController = nil;
    threadsView = nil;
    
    [self backToThreads];
}

-(void)threadCreationDidFail {
    [self.activityIndicator stopAnimating];
    [self alertWithMessage:@"Thread creation did fail! Please try again later."];
    self.textInput.enabled = YES;
}

-(void)backToThreads {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

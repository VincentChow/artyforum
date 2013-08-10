//
//  LoginViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Server.h"
#import "UIViewController+UIViewController_Alert.h"
#import "ThreadsViewController.h"
#import "Thread.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)didPressSignIn:(id)sender;
- (IBAction)didPressJoin:(id)sender;
- (IBAction)didPressGuest:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;
@property (weak, nonatomic) IBOutlet UIButton *guestBtn;

@end

@implementation LoginViewController
{
    NSString *username;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInBtn.layer.cornerRadius = 9.0f;
    self.joinBtn.layer.cornerRadius = 9.0f;
    self.guestBtn.layer.cornerRadius = 9.0f;

    self.emailInput.delegate = self;
    self.passwordInput.delegate = self;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:@"credentials"] && [def objectForKey:@"credentials"] != nil) {
        [self signInWithCredentials:[def objectForKey:@"credentials"]];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)didPressSignIn:(id)sender {
    [self signInWithCredentials:@{@"mail": self.emailInput.text, @"pass": self.passwordInput.text}];
}

- (IBAction)didPressJoin:(id)sender {    
    if ([self.emailInput.text isEqual:@""] || [self.passwordInput.text isEqual:@""]) {
        [self alertWithMessage:@"Please fill out the forms!"];
    } else if (![self isValidEmail:self.emailInput.text]) {
        [self alertWithMessage:@"Invalid e-mail address!"];
    } else if ([self.passwordInput.text length] < 6) {
        [self alertWithMessage:@"Password must be at least 6 characters!"];
    } else {
        //join the forum...
        [self.activityIndicator startAnimating];
        [Server post:@{@"mail": self.emailInput.text, @"pass": self.passwordInput.text} toPath:@"users" onCompletion:^(NSDictionary *response, NSError *error) {
            [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
            if (response) {
                if (response[@"mailTaken"]) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:@"There is already an account registered to that email adress." waitUntilDone:YES];
                } else if (response[@"nameTaken"]) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:@"There is already an account in that name." waitUntilDone:YES];
                } else if (response[@"ok"]) {
                    username = [self.emailInput.text componentsSeparatedByString:@"@"][0];
                    [self performSelectorOnMainThread:@selector(fetchThreads) withObject:nil waitUntilDone:YES];
                }
            } else {
                [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
            }
        }];
    }    
}

- (IBAction)didPressGuest:(id)sender {
    username = nil;
    [self fetchThreads];
}

-(void)signInWithCredentials:(NSDictionary*)credentials {
    if ([self isValidEmail:credentials[@"mail"]] && [credentials[@"pass"] length] > 5) {
        [self.activityIndicator startAnimating];
        [Server post:@{@"mail": credentials[@"mail"], @"pass": credentials[@"pass"]} toPath:@"login" onCompletion:^(NSDictionary *response, NSError *error) {
            [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
            if (response) {
                if ([response[@"loggedIn"]integerValue] == 1) {
                    //go to threads...
                    username = response[@"name"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:credentials forKey:@"credentials"];
                    [defaults synchronize];
                    [self performSelectorOnMainThread:@selector(fetchThreads) withObject:nil waitUntilDone:YES];
                } else {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:@"Incorrect credentials!" waitUntilDone:YES];
                }
            } else {
                [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
            }
        }];
    } else {
        [self alertWithMessage:@"Incorrect credentials!"];
    }
}

-(void)fetchThreads {
    self.passwordInput.text = @"";
    [self.activityIndicator startAnimating];
    [Server getDataAtPath:@"threads" onCompletion:^(NSArray *response, NSError *error) {
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        if (response) {
            //load threads view
            [self performSelectorOnMainThread:@selector(loadThreadsView:) withObject:response waitUntilDone:YES];
        } else {
            [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
        }
    }];
}

-(void) loadThreadsView:(NSArray *) jsonThreads {
    NSMutableArray *threads = [[NSMutableArray alloc]init];
    for (NSDictionary *json in jsonThreads) {
        [threads addObject:[Thread fromJson:json]];
    }
    ThreadsViewController *threadView = [self.storyboard instantiateViewControllerWithIdentifier:@"ThreadView"];
    threadView.threads = threads;
    threadView.username = username;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:threadView];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:navController animated:YES completion:nil];
}

-(BOOL) isValidEmail:(NSString *)checkString {
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:checkString];
}

-(void)stopActivityIndicator {
    [self.activityIndicator stopAnimating];
}
@end

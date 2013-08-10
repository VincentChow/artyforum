//
//  CommentDetailViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-06.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "CommentDetailViewController.h"

@interface CommentDetailViewController ()

@end

@implementation CommentDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews {
    [self.commentLabel sizeToFit];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

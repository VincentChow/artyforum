//
//  CommentDetailViewController.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-06.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

//
//  CommentCell.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-04.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;




@end

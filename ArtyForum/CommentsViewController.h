//
//  CommentsViewController.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-04.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Thread;

@interface CommentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) Thread *thread;
@property (nonatomic) NSString *username;

-(void) reloadTable;


@end

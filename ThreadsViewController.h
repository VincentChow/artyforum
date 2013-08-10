//
//  ThreadsViewController.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *threads;
@property (nonatomic) NSString *username;

-(void) reloadTable;

@end

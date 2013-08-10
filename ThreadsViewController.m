//
//  ThreadsViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "ThreadsViewController.h"
#import "Thread.h"
#import "Comment.h"
#import "Server.h"
#import "ThreadCell.h"
#import "UIViewController+UIViewController_Alert.h"
#import "CreateThreadViewController.h"
#import "CommentsViewController.h"

@interface ThreadsViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ThreadsViewController
{
    NSMutableArray *filteredThreads;
    BOOL isFiltered;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"ArtyForum threads";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.username ? @"Sign out" : @"Sign in/join" style:UIBarButtonItemStylePlain target:self action:@selector(backToLogin)];
    if (self.username) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAddButton)];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
}

#pragma mark Search Bar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        isFiltered = NO;
    } else {
        isFiltered = YES;
        filteredThreads = [[NSMutableArray alloc]init];
        for (Thread *thread in self.threads) {
            NSRange textRange = [thread.text rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange creatorRange = [thread.creator rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange timeRange = [thread.time rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (textRange.location != NSNotFound || creatorRange.location != NSNotFound || timeRange.location != NSNotFound) {
                [filteredThreads addObject:thread];
            }
        }
    }
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

#pragma mark Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered) {
        return [filteredThreads count];
    }
    return [self.threads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"thrCll";
    ThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ThreadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    Thread *thread;
    if (isFiltered) {
        thread = filteredThreads[indexPath.row];
    } else {
        thread = self.threads[indexPath.row];
    }
    cell.contentLabel.text = thread.text;
    cell.subLabel.text = [NSString stringWithFormat:@"%@ at %@", thread.creator, thread.time];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Thread *thread;
    if (isFiltered) {
        thread = filteredThreads[indexPath.row];
    } else {
        thread = self.threads[indexPath.row];
    }
    return [self.username isEqualToString:thread.creator];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block Thread *thread;
        __block NSNumber *index = [NSNumber numberWithInt:[self.threads indexOfObject:thread]];
        if (isFiltered) {
            thread = filteredThreads[indexPath.row];
        } else {
            thread = self.threads[indexPath.row];
        }
        
        [self.tableView beginUpdates];
        [self.threads removeObject:thread];
        if (isFiltered) {
            [filteredThreads removeObject:thread];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        [Server deleteObjectWithId:thread.id atPath:@"threads" onCompletion:^(NSDictionary *response, NSError *error) {
            if (response && [response[@"deleted"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                //do nothing
            } else {
                if (error) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
                } else if (response) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:@"Unable to delete thread" waitUntilDone:YES];
                }
                [self performSelectorOnMainThread:@selector(reinsertThread:) withObject:@{@"thread": thread, @"index": index} waitUntilDone:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Thread *thread = self.threads[indexPath.row];
    NSString *path = [NSString stringWithFormat:@"comments/%@", thread.id];
    [Server getDataAtPath:path onCompletion:^(NSArray *response, NSError *error) {
        if (response) {
            [self performSelectorOnMainThread:@selector(loadCommentsInThread:) withObject:@[response, thread] waitUntilDone:YES];
        } else {
            [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
        }
    }];
}

- (void)loadCommentsInThread:(NSArray *) commentsAndThread {

    NSMutableArray *comments = [[NSMutableArray alloc]init];
    Thread *thread = commentsAndThread[1];
    for (NSDictionary *json in commentsAndThread[0]) {
        [comments addObject:[Comment fromJson:json]];
    }
        
    CommentsViewController *commentsView = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsView"];
    commentsView.thread = thread;
    commentsView.comments = comments;
    commentsView.username = self.username;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Threads" style: UIBarButtonItemStyleBordered target: nil action: nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    [self.navigationController pushViewController:commentsView animated:YES];
}

-(void)reinsertThread:(NSDictionary*)threadWithIndex {
    [self alertWithMessage:@"Unable to delete thread! Please try again later"];
    NSUInteger index = [threadWithIndex[@"index"] integerValue];
    Thread *thread = threadWithIndex[@"thread"];
    [self.threads insertObject:thread atIndex:index];
    if (isFiltered) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    } else {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(void)didPressAddButton {
    CreateThreadViewController *newThread = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateThread"];
    newThread.modalPresentationStyle = UIModalPresentationFormSheet;
    newThread.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:newThread animated:YES completion:nil];
}

-(void) reloadTable {
    if (isFiltered) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    [self.tableView reloadData];
}

-(void)backToLogin {
    [Server clearSession];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:@"credentials"];
    [def synchronize];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end

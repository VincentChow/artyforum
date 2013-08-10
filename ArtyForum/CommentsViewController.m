//
//  CommentsViewController.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-07-04.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "CommentsViewController.h"
#import "Thread.h"
#import "Comment.h"
#import "CommentCell.h"
#import "Server.h"
#import "UIViewController+UIViewController_Alert.h"
#import "CommentDetailViewController.h"
#import "CreateCommentViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController
{
    NSMutableArray *filteredComments;
    BOOL isFiltered;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.navigationItem.title = self.thread.text;
    
    if (self.username) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAddButton)];
    }    
}

#pragma mark Search Bar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        isFiltered = NO;
    } else {
        isFiltered = YES;
        filteredComments = [[NSMutableArray alloc]init];
        for (Comment *comment in self.comments) {
            NSRange textRange = [comment.text rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange creatorRange = [comment.creator rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange timeRange = [comment.time rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (textRange.location != NSNotFound || creatorRange.location != NSNotFound || timeRange.location != NSNotFound) {
                [filteredComments addObject:comment];
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
        return [filteredComments count];
    }
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier2 = @"comCll";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
    }
    Comment *comment;
    if (isFiltered) {
        comment = filteredComments[indexPath.row];
    } else {
        comment = self.comments[indexPath.row];
    }
    
    cell.commentLabel.text = comment.text;
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ said:", comment.creator];
    cell.timeLabel.text = comment.time;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment;
    if (isFiltered) {
        comment = filteredComments[indexPath.row];
    } else {
        comment = self.comments[indexPath.row];
    }
    return [self.username isEqualToString:comment.creator];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block Comment *comment;
        __block NSNumber *index = [NSNumber numberWithInt:[self.comments indexOfObject:comment]];
        if (isFiltered) {
            comment = filteredComments[indexPath.row];
        } else {
            comment = self.comments[indexPath.row];
        }
        
        [self.tableView beginUpdates];
        [self.comments removeObject:comment];
        if (isFiltered) {
            [filteredComments removeObject:comment];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        [Server deleteObjectWithId:comment.id atPath:@"comments" onCompletion:^(NSDictionary *response, NSError *error) {
            if (response && [response[@"ok"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                //do nothing
            } else {
                if (error) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:error.localizedDescription waitUntilDone:YES];
                } else if (response) {
                    [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:@"Unable to delete comment" waitUntilDone:YES];
                }
                [self performSelectorOnMainThread:@selector(reinsertComment:) withObject:@{@"comment": comment, @"index": index} waitUntilDone:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = self.comments[indexPath.row];
    CommentDetailViewController *commentDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentDetail"];
    [self.navigationController pushViewController:commentDetail animated:YES];
    commentDetail.commentLabel.text = comment.text;
    commentDetail.timeLabel.text = comment.time;
    commentDetail.nameLabel.text = comment.creator;
}

-(void) reloadTable {
    if (isFiltered) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    [self.tableView reloadData];
}

-(void)didPressAddButton {
    CreateCommentViewController *newComment = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateComment"];
    newComment.modalPresentationStyle = UIModalPresentationFormSheet;
    newComment.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    newComment.inThreadId = self.thread.id;
    newComment.inThreadNamed = self.thread.text;
    [self presentViewController:newComment animated:YES completion:nil];
    
}

-(void)reinsertComment:(NSDictionary*)commentWithIndex {
    [self alertWithMessage:@"Unable to delete comment! Please try again later"];
    NSUInteger index = [commentWithIndex[@"index"] integerValue];
    Comment *comment = commentWithIndex[@"comment"];
    [self.comments insertObject:comment atIndex:index];
    if (isFiltered) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    } else {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

@end
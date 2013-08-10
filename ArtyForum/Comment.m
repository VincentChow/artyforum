//
//  Comment.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+(id)fromJson:(NSDictionary *)json {
    Comment *comment = [[Comment alloc]init];
    comment.id = json[@"_id"];
    comment.rev = json[@"_rev"];
    comment.text = json[@"txt"];
    comment.creator = json[@"cre"];
    comment.time = json[@"tim"];
    comment.inThreadId = json[@"thr"];
    comment.inThreadNamed = json[@"thrnm"];
    return comment;
}

-(NSDictionary *)toJson {
    NSMutableDictionary *json = [[NSMutableDictionary alloc]initWithDictionary:[super toJson]];
    [json setValue:self.inThreadId forKey:@"thr"];
    [json setValue:self.inThreadNamed forKey:@"thrnm"];
    return json;
}

@end

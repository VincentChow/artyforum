//
//  Thread.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "Thread.h"

@implementation Thread

+(id)fromJson:(NSDictionary *)json {
    Thread *thread = [[Thread alloc]init];
    thread.id = json[@"_id"];
    thread.rev = json[@"_rev"];
    thread.text = json[@"txt"],
    thread.time = json[@"tim"];
    thread.creator = json[@"cre"];
    return thread;    
}

-(NSDictionary *)toJson {
    return @{@"_id": self.id, @"_rev": self.rev, @"txt": self.text, @"tim": self.time, @"cre": self.creator};
}

@end

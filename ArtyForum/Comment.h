//
//  Comment.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "Thread.h"

@interface Comment : Thread

@property (nonatomic) NSString *inThreadId;
@property (nonatomic) NSString *inThreadNamed;

@end

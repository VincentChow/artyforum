//
//  Thread.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-29.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thread : NSObject

@property (nonatomic) NSString *id;
@property (nonatomic) NSString *rev;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *time;
@property (nonatomic) NSString *creator;

+(id)fromJson:(NSDictionary*)json;
-(NSDictionary *)toJson;

@end

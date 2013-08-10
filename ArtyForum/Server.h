//
//  Server.h
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-15.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Server : NSObject

+(void)getDataAtPath:(NSString *)path onCompletion:(callbackReturningArray)callBack;
+(void)post:(NSDictionary *)data toPath:(NSString *)path onCompletion:(callbackReturningDictionary)callback;
+(void)deleteObjectWithId:(NSString *)id atPath:(NSString *)path onCompletion:(callbackReturningDictionary)callback;
+(void)clearSession;

@end

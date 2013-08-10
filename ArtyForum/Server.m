//
//  Server.m
//  ArtyForum
//
//  Created by Erik Österberg on 2013-06-15.
//  Copyright (c) 2013 SoundByte Studios. All rights reserved.
//

#import "Server.h"

@implementation Server

static NSString *serverUrl;
static NSOperationQueue *queue;

+(void)initialize
{
    serverUrl = @"http://artyforum.erikosterberg.com";
    //serverUrl = @"http://localhost:31220"; //test server
    queue = [[NSOperationQueue alloc]init];
}

+(void)getDataAtPath:(NSString *)path onCompletion:(callbackReturningArray)callback
{
    NSMutableURLRequest *request = [self requestWithUrl:[NSString stringWithFormat:@"%@/%@", serverUrl, path] method:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            callback([NSJSONSerialization JSONObjectWithData:data options:0 error:NULL], error);
        } else {
            callback(nil, error);
        }
    }];
}

+(void)post:(NSDictionary *)data toPath:(NSString *)path onCompletion:(callbackReturningDictionary)callback
{
    NSMutableURLRequest *request = [self requestWithUrl:[NSString stringWithFormat:@"%@/%@", serverUrl, path] method:@"POST"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:NULL];
    [request setHTTPBody:jsonData];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            callback([NSJSONSerialization JSONObjectWithData:data options:0 error:NULL], error);
        } else {
            callback(nil, error);
        }
    }];
}

+(void)deleteObjectWithId:(NSString *)id atPath:(NSString *)path onCompletion:(callbackReturningDictionary)callback {
    NSMutableURLRequest *request = [self requestWithUrl:[NSString stringWithFormat:@"%@/%@/%@", serverUrl, path, id] method:@"DELETE"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            callback([NSJSONSerialization JSONObjectWithData:data options:0 error:NULL], error);
        } else {
            callback(nil, error);
        }
    }];
}

+(void)clearSession {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

/* ------------------- PRIVATE METHODS --------------------- */

+(NSMutableURLRequest*) requestWithUrl: (NSString*) urlString method: (NSString*) method
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    } else {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    [request setHTTPMethod:method];
    return request;
}

@end

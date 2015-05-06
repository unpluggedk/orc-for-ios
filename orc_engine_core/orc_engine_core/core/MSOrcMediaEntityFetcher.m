/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSOrcMediaEntityFetcher.h"
#import "MSOrcRequest.h"
#import "MSOrcURL.h"

@implementation MSOrcMediaEntityFetcher

- (instancetype)initWithUrl:(NSString *)urlComponent parent:(id<MSOrcExecutable>)parent {
    
    self = [super initWithUrl:urlComponent parent:parent asClass:nil];
    
    return self;
}

- (NSURLSessionTask *)getContentWithCallback:(void (^)(NSData *content, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createODataRequest];
    
    [request.url appendPathComponent:@"$value"];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse> r, MSOrcError *e) {
        
        if (e == nil) {
            
            return callback([r data],e);
        }
        
        callback(nil,e);
    }];
}

- (NSURLSessionTask *)getStreamedContentWithCallback:(void (^)(NSInputStream *content, MSOrcError *error))callback{
    
    id<MSOrcRequest> request = [self.resolver createODataRequest];
    
    [request.url appendPathComponent:@"$value"];
    
    [[request options] addObject:[NSDictionary dictionaryWithObject:@"true" forKey:OPT_STREAM_DOWNLOAD]];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse> r, MSOrcError *e) {
        
        if (e == nil) {
            
            callback([r stream ],e);
        }
        else{
            
            callback(nil,e);
        }
    }];
}

- (NSURLSessionTask *)putContent:(NSData *)content
                        callback:(void (^)(NSInteger statusCode, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createODataRequest];
    
    [request.url appendPathComponent:@"$value"];
    [request setVerb:HTTP_VERB_PUT];
    [request setContent:[NSMutableData dataWithData:content]];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse>r, MSOrcError *e) {
        
        if(e == nil){
            
            callback(r.status, e);
        }
        else{
            
            callback([e code],e);
        }
    }];
}

- (NSURLSessionTask *)putContent:(NSInputStream *)content withSize:(NSInteger)size callback:(void (^)(NSInteger statusCode, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createODataRequest];
    
    [request.url appendPathComponent:@"$value"];
    [request setVerb:HTTP_VERB_PUT];
    [request setStreamContent:content];
    [request setSize:size];
    
    [[request options] addObject:[NSDictionary dictionaryWithObject:@"true" forKey:OPT_STREAM_UPLOAD]];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse>r, MSOrcError *e) {
        
        if (e == nil) {
            
            callback(r.status, e);
        }
        else{
            
            callback([e code], e);
        }
    }];
}

@end
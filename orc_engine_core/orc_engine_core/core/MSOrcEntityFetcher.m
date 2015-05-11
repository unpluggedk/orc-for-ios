/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSOrcEntityFetcher.h"
#import "MSOrcBaseContainer.h"
#import "MSOrcOperations.h"
#import "MSOrcJsonSerializer.h"
#import "MSOrcRequest.h"
#import "MSOrcURL.h"

@interface MSOrcEntityFetcher()

@property (copy, nonatomic, readonly) NSString *select;
@property (copy, nonatomic, readonly) NSString *expand;

@end

@implementation MSOrcEntityFetcher

@synthesize operations = _operations;

- (instancetype)initWithUrl:(NSString *)urlComponent
                     parent:(id<MSOrcExecutable>)parent asClass:(Class)entityClass {
    
    if (self = [super initWithUrl:urlComponent parent:parent asClass:entityClass]) {
    
        _operations = [[MSOrcOperations alloc] initOperationWithUrl:@"" parent:parent];
        _expand = nil;
        _select = nil;
    }
    
    return self;
}

- (NSURLSessionTask *)oDataExecuteRequest:(id<MSOrcRequest>)request
                                 callback:(void (^)(id<MSOrcResponse> response, MSOrcError *error))callback {
    
    id<MSOrcURL> url = request.url;
    
    [url appendPathComponent:self.urlComponent];
    
    if (self.select != nil) {
        
        [url addQueryStringParameter:@"$select" value:self.select];
    }
    
    if (self.expand != nil) {
        
        [url addQueryStringParameter:@"$expand" value:self.expand];
    }
    
    [MSOrcBaseContainer addCustomParametersToODataURLWithRequest:request
                                                      parameters:self.customParameters
                                                         headers:self.customHeaders
                                              dependencyResolver:super.resolver];
    
    return [super.parent orcExecuteRequest:request callback:^(id<MSOrcResponse> r, MSOrcError *e) {
        
        callback(r,e);
    }];
}

- (NSURLSessionTask *)updateEntity:(id)entity
                          callback:(void (^)(id updatedEntity, MSOrcError *error))callback {
    
    NSString *payload = [self.resolver.jsonSerializer serialize:entity];
    
    return [self updateRaw:payload callback:^(NSString *response, MSOrcError *e) {
        
        if (e == nil) {
            
            id entity = [self.resolver.jsonSerializer deserialize:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                          asClass:self.entityClass];
            
            callback(entity, e);
        }
        else {
            
            callback(nil, e);
        }
    }];
}

- (NSURLSessionTask *)updateRaw:(NSString*)payload
                       callback:(void (^)(NSString *entityResponse, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createOrcRequest];
    

    [request setContent:[NSMutableData dataWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]]];
    [request setVerb:HTTP_VERB_PATCH];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse> response, MSOrcError *e) {
        
        if (e == nil) {
            
            callback([[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding], e);
        }
        else {
            
            callback(nil, e);
        }
    }];
}

-(NSURLSessionTask *)deleteWithCallback:(void (^)(int statusCode, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createOrcRequest];
    
    [request setVerb:HTTP_VERB_DELETE];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse> r, MSOrcError *e) {
        
        callback(r.status, e);
    }];
}

- (NSURLSessionTask *)readRawWithCallback:(void (^)(NSString *entityString, MSOrcError *error))callback {
    
    id<MSOrcRequest> request = [self.resolver createOrcRequest];
    
    return [self oDataExecuteRequest:request callback:^(id<MSOrcResponse> response, MSOrcError *e) {
        
        if (e == nil) {
            
            callback([[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding], e);
        }
        else {
            
            callback(nil, e);
        }
    }];
}

- (NSURLSessionTask *)readWithCallback:(void (^)(id result, MSOrcError *error))callback {
    
    return [self readRawWithCallback:^(NSString *r, MSOrcError *e) {
        
        if (e == nil) {
            
            id entity = [self.resolver.jsonSerializer deserialize:[r dataUsingEncoding:NSUTF8StringEncoding]
                                                          asClass:self.entityClass];
            
            callback(entity, e);
        }
        else {
            
            callback(nil, e);
        }
    }];
}

- (MSOrcEntityFetcher *)select:(NSString *)params {
    
    _select = params;
    
    return self;
}

- (MSOrcEntityFetcher *)expand:(NSString *)value {
    
    _expand = value;
    
    return self;
}

+ (void)setPathForCollectionsWithUrl:(id<MSOrcURL>)url
                                 top:(int)top
                                skip:(int)skip
                              select:(NSString *)select
                              expand:(NSString *)expand
                              filter:(NSString *)filter
                             orderby:(NSString *)orderBy
                              search:(NSString *)search {
    
    if (top > -1) {
        
        [url addQueryStringParameter:@"$top" value:[[NSString alloc] initWithFormat:@"%d", top]];
    }
    
    if (skip > -1) {
        
        [url addQueryStringParameter:@"$skip" value:[[NSString alloc] initWithFormat:@"%d", skip]];
    }
    
    if (select != nil) {
        
        [url addQueryStringParameter:@"$select" value:select];
    }
    
    if (expand != nil) {
        
        [url addQueryStringParameter:@"$expand" value:expand];
    }
    
    if (filter!= nil) {
        
        [url addQueryStringParameter:@"$filter" value:filter];
    }
    
    if (orderBy != nil) {
        
        [url addQueryStringParameter:@"$orderBy" value:orderBy];
    }
    
    if (search != nil) {
        
        [url addQueryStringParameter:@"$search" value:search];
    }
}

@end
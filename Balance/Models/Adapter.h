//
//  Adapter.h
//  Balance
//
//  Created by Chris Nolet on 4/22/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface Adapter : NSObject

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSDictionary *defaultParameters;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

+ (instancetype)sharedInstance;

- (void)postToEndpoint:(NSString *)endpoint
            parameters:(NSDictionary *)parameters
            completion:(void (^)(NSDictionary *results, NSError *error))completion;

@end

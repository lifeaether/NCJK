//
//  NCJKServer.h
//  NCJK
//
//  Created by lifeaether on 2013/03/12.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NCJKServerErrorDomain;
extern const NSInteger NCJKServerErrorCodeGetInformation;
extern const NSInteger NCJKServerErrorCodeConnectToServer;
extern const NSInteger NCJKServerErrorCodeReadStream;


@interface NCJKServer : NSObject

@property (nonatomic, getter = isStop, setter = setStop:) BOOL isStop;

+ (id)serverStart:(NSString *)channelIdentifier receiveHandler:(void (^)(id server, NSXMLElement *element))receive errorHandler:(void (^)(id server, NSError *error))error;

@end
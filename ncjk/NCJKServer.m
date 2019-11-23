//
//  NCJKServer.m
//  NCJK
//
//  Created by lifeaether on 2013/03/12.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "NCJKServer.h"

NSString * const NCJKServerErrorDomain = @"com.lifeaether.NCJKServer";

const NSInteger NCJKServerErrorCodeGetInformation    = 10;
const NSInteger NCJKServerErrorCodeConnectToServer   = 11;
const NSInteger NCJKServerErrorCodeReadStream        = 12;

static NSString * const NCJKServerURLGetFLV = @"http://jk.nicovideo.jp/api/getflv?v=%@";

NSString * const NCJKServerStopKey = @"stop";

@interface NCJKServer ()
@property (copy,nonatomic) NSString *identifier;
@property (copy,nonatomic) void (^receiveHandler)(id server, NSString *comment);
@property (copy,nonatomic) void (^errorHandler)(id server, NSError *error);
- (void)start;
@end

@implementation NCJKServer

@synthesize identifier, receiveHandler, errorHandler;

- (void)dealloc
{
    NSLog( @"NCJKServer deallocated." );
}

+ (id)serverStart:(NSString *)channelIdentifier receiveHandler:(void (^)(id server, NSString *comment))receive errorHandler:(void (^)(id server, NSError *error))error
{
    NCJKServer *server = [[NCJKServer alloc] init];   // release on end of start method.
    
    [server setIdentifier:channelIdentifier];
    
    if ( receive ) {
        [server setReceiveHandler:receive];
    } else {
        [server setReceiveHandler:^(id server, NSString *comment) {
            NSLog( @"%@", comment );
        }];
    }
    
    if ( error ) {
        [server setErrorHandler:error];
    } else {
        [server setErrorHandler:^(id server, NSError *error) {
            NSLog( @"%@", error );
        }];
    }
    
    [server setStop:NO];
    [NSThread detachNewThreadSelector:@selector(start) toTarget:server withObject:nil];
    return server;
}

- (void)start
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        NSError *error = nil;
        
        // getting jk information.
        NSString *ms = nil;
        NSInteger port = 0;
        NSString *thread = nil;
        {
            // loading information.
            NSString *urlString = [NSString stringWithFormat:NCJKServerURLGetFLV, [self identifier]];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if ( !data ) {
                [self setStop:YES];
                [self errorHandler]( self, error );
                return;
            }
            
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            // parsing information.
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            NSScanner *scanner = [NSScanner scannerWithString:result];
            while ( ![scanner isAtEnd] ) {
                NSString *scannedKey = nil;
                NSString *scannedValue = nil;
                if ( ![scanner scanUpToString:@"=" intoString:&scannedKey] ) {
                    break;
                }
                if ( ![scanner scanString:@"=" intoString:nil] ) {
                    break;
                }
                if ( ![scanner scanUpToString:@"&" intoString:&scannedValue] ) {
                    break;
                }
                [parameter setValue:scannedValue forKey:scannedKey];
                if ( ![scanner scanString:@"&" intoString:nil] ) {
                    break;
                }
            }
            
            ms = [parameter objectForKey:@"ms"];
            port = [[parameter objectForKey:@"ms_port"] intValue];
            thread = [parameter objectForKey:@"thread_id"];
        }
        
        // validating information.
        if ( [ms isEqualToString:@""] || port == 0 || [thread isEqualToString:@""] ) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      NSLocalizedString(@"Failed to get jk information",nil), NSLocalizedDescriptionKey,
                                      NSLocalizedString(@"Failed to parse jk information.", nil), NSLocalizedFailureReasonErrorKey,
                                      nil];
            error = [NSError errorWithDomain:NCJKServerErrorDomain code:NCJKServerErrorCodeGetInformation userInfo:userInfo];
            [self setStop:YES];
            [self errorHandler]( self, error );
            return;
        }
        
        // create stream.
        NSInputStream *inputStream = nil;
        NSOutputStream *outputStream = nil;
        [NSStream getStreamsToHostWithName:ms port:port inputStream:&inputStream outputStream:&outputStream];
        if ( !inputStream || !outputStream ) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      NSLocalizedString(@"Failed to open stream",nil), NSLocalizedDescriptionKey,
                                      NSLocalizedString(@"Failed to open stream.", nil), NSLocalizedFailureReasonErrorKey,
                                      nil];
            error = [NSError errorWithDomain:NCJKServerErrorDomain code:NCJKServerErrorCodeConnectToServer userInfo:userInfo];
            [self setStop:YES];
            [self errorHandler]( self, error );
            return;
        }
        
        [inputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        // send request.
        {
            NSString *sendString = [NSString stringWithFormat:@"<thread thread=\"%@\" res_from=\"0\" version=\"20061206\" />", thread];
            NSData *data = [sendString dataUsingEncoding:NSUTF8StringEncoding];
            [outputStream write:[data bytes] maxLength:[data length]];
            const uint8_t zero = 0;
            [outputStream write:&zero maxLength:1];
        }
        
        // loading messages...
        NSMutableData *receivedData = [NSMutableData data];
        while ( ! [self isStop] ) {
            @autoreleasepool {
                static const size_t maxlen = 1024;
                u_int8_t buffer[maxlen];
                const NSInteger len = [inputStream read:buffer maxLength:maxlen];
                if ( len < 0 ) {    // error occurs
                    NSLog( @"%@", [inputStream streamError] );
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              NSLocalizedString(@"Failed to read stream.",nil), NSLocalizedDescriptionKey,
                                              NSLocalizedString(@"Failed to read stream.", nil), NSLocalizedFailureReasonErrorKey,
                                              nil];
                    error = [NSError errorWithDomain:NCJKServerErrorDomain code:NCJKServerErrorCodeReadStream userInfo:userInfo];
                    [self errorHandler]( self, error );
                    [self setStop:YES];
                } else if ( len == 0 ) {    // end of buffer.
                    [self setStop:YES];
                } else {
                    for ( NSInteger i = 0; i < len; i++) {
                        if ( buffer[i] == 0 ) {
                            NSString *string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                            NSScanner *scanner = [NSScanner scannerWithString:string];
                            if ( [scanner scanString:@"<chat" intoString:nil] && [scanner scanUpToString:@">" intoString:nil] && [scanner scanString:@">" intoString:nil] ) {
                                NSString *comment = nil;
                                if ( [scanner scanUpToString:@"</chat>" intoString:&comment] ) {
                                    [self receiveHandler]( self, comment );
                                }
                            }
                            [receivedData setLength:0];
                        } else {
                            [receivedData appendBytes:buffer+i length:1];
                        }
                    }
                }
            }
        }
        
        [inputStream close];
        [outputStream close];
    }
}

@end

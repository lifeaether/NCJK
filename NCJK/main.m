//
//  main.m
//  NCJK
//
//  Created by lifeaether on 2013/03/12.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCJKServer.h"

static void usage()
{
    fprintf( stdout, "usage: ncjk channel [format]\n" );
    fprintf( stdout, "example: ncjk jk1\n" );
    fprintf( stdout, "example: ncjk jk1 date -\n" );
}

static NCJKServer *server = nil;

void terminate()
{
    [server setStop:YES];
    fprintf( stdout, "\n" );
}

int main(int argc, const char * argv[])
{
    signal( SIGINT, terminate );
    
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if ( [arguments count] > 1 ) {
            NSString *channel = [arguments objectAtIndex:1];
            NSArray *formats = [arguments subarrayWithRange:NSMakeRange(2, [arguments count]-2)];

            server = [NCJKServer serverStart:channel receiveHandler:^(id server, NSXMLElement *element) {
                if ( [[element name] isEqualToString:@"chat"] ) {
                    if ( [formats count] > 0 ) {
                        BOOL isFirst = YES;
                        for ( NSString *key in formats ) {
                            if ( isFirst ) {
                                isFirst = NO;
                            } else {
                                fprintf( stdout, " " );
                            }
                            if ( [key isEqualToString:@"-"] ) {
                                fprintf( stdout, "%s", [[element stringValue] UTF8String] );
                            } else if ( [key isEqualToString:@"@"] ) {
                                fprintf( stdout, "%s", [[element description] UTF8String] );
                            } else {
                                fprintf( stdout, "%s", [[[element attributeForName:key] stringValue] UTF8String] );
                            }
                        }
                        fprintf( stdout, "\n" );
                    } else {
                        fprintf( stdout, "%s\n", [[element stringValue] UTF8String] );
                    }
                    fflush( stdout );
                }
            } errorHandler:^(id server, NSError *error ) {
                fprintf( stderr, "%s\n", [[error description] UTF8String] );
            }];
            
            [[server retain] autorelease];
           
            while ( ! [server isStop] ) {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
    return 0;
}


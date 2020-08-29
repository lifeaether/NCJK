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
    fprintf( stdout, "usage: ncjk channel\n" );
    fprintf( stdout, "example: ncjk jk1\n" );
}

static NCJKServer *server = nil;

void terminate()
{
    [server setStop:YES];
    fprintf( stdout, "\n" );
}

BOOL options( int argc, const char *argv[], NSString **channel, NSTimeInterval *timeout )
{
    for ( int i = 1; i < argc; i++ ) {
        if ( strcmp( argv[i], "-t" ) == 0 ) {
            *timeout = [[NSString stringWithUTF8String:argv[++i]] integerValue];
        } else {
            *channel = [NSString stringWithUTF8String:argv[i]];
        }
    }
    
    if ( ! (*channel) ) {
        return NO;
    }
    return YES;
}

int main(int argc, const char * argv[])
{
    signal( SIGINT, terminate );
    
    @autoreleasepool {
        NSString *channel = nil;
        NSTimeInterval timeout = 0;
        if ( options( argc, argv, &channel, &timeout ) ) {
            server = [NCJKServer serverStart:channel receiveHandler:^(id server, NSString *comment) {
                fprintf( stdout, "%s\n", [comment UTF8String] );
                fflush( stdout );
            } errorHandler:^(id server, NSError *error ) {
                fprintf( stderr, "%s\n", [[error description] UTF8String] );
            }];
            
            [server setTimeout:timeout];
            
            while ( ! [server isStop] ) {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
    return 0;
}


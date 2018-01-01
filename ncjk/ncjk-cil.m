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

int main(int argc, const char * argv[])
{
    signal( SIGINT, terminate );
    
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if ( [arguments count] == 2 ) {
            NSString *channel = [arguments objectAtIndex:1];
            server = [NCJKServer serverStart:channel receiveHandler:^(id server, NSString *comment) {
                fprintf( stdout, "%s\n", [comment UTF8String] );
                fflush( stdout );
            } errorHandler:^(id server, NSError *error ) {
                fprintf( stderr, "%s\n", [[error description] UTF8String] );
            }];
            
            while ( ! [server isStop] ) {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
    return 0;
}


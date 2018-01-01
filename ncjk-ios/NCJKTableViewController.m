//
//  NCJKTableViewController.m
//  ncjk-ios
//
//  Created by lifeaether on 2017/12/31.
//  Copyright © 2017年 lifeaether. All rights reserved.
//

#import "NCJKTableViewController.h"
#import "NCJKServer.h"

@interface NCJKTableViewController ()
@property (strong) NCJKServer *server;
@property (strong) NSMutableArray *comments;

- (void)resume;
- (void)suspend;

- (void)applicationDidEnterBackground:(NSNotification *)notification;
- (void)applicationWillEnterForeground:(NSNotification *)notification;

@end

@implementation NCJKTableViewController

- (void)resume
{
    [self suspend];
    
    NSMutableArray *comments = [self comments];
    UITableView *tableView = [self tableView];
    NCJKServer *server = [NCJKServer serverStart:[self channel] receiveHandler:^(id server, NSString *comment) {
        dispatch_async( dispatch_get_main_queue(), ^{
            [comments insertObject:comment atIndex:0];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        });
    } errorHandler:^(id server, NSError *error ) {
        dispatch_async( dispatch_get_main_queue(), ^{
            [comments insertObject:[error description] atIndex:0];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
    
    [self setServer:server];
}

- (void)suspend
{
    [[self server] setStop:YES];
    [self setServer:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setComments:[NSMutableArray array]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self suspend];
    [self resume];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [self suspend];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self suspend];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self comments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setLineBreakMode:NSLineBreakByCharWrapping];
    NSString *comment = [[self comments] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:comment];
    return cell;
}

@end

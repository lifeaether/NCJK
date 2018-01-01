//
//  ChannelTableViewController.m
//  ncjk-ios
//
//  Created by lifeaether on 2017/12/31.
//  Copyright © 2017年 lifeaether. All rights reserved.
//

#import "ChannelTableViewController.h"
#import "NCJKTableViewController.h"

@implementation ChannelTableViewController

static NSString * const ChannelStringKey = @"name";
static NSString * const ChannelNameKey = @"description";
static NSString * const ChannelURLKey = @"url";

static NSArray<NSDictionary *> * ChannelDifinition() {
    return @[
             @{ ChannelStringKey: @"jk1", ChannelNameKey:@"NHK 総合", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk1" },
             @{ ChannelStringKey: @"jk2", ChannelNameKey:@"Eテレ", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk2" },
             @{ ChannelStringKey: @"jk4", ChannelNameKey:@"日本テレビ", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk4" },
             @{ ChannelStringKey: @"jk5", ChannelNameKey:@"テレビ朝日", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk5" },
             @{ ChannelStringKey: @"jk6", ChannelNameKey:@"TBS テレビ", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk6" },
             @{ ChannelStringKey: @"jk7", ChannelNameKey:@"テレビ東京", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk7" },
             @{ ChannelStringKey: @"jk8", ChannelNameKey:@"フジテレビ", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk8" },
             @{ ChannelStringKey: @"jk9", ChannelNameKey:@"TOKYO MX", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk9" },
             @{ ChannelStringKey: @"jk3", ChannelNameKey:@"テレ玉", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk10" },
             @{ ChannelStringKey: @"jk3", ChannelNameKey:@"tvk", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk11" },
             @{ ChannelStringKey: @"jk3", ChannelNameKey:@"チバテレビ", ChannelURLKey: @"http://jk.nicovideo.jp/watch/jk12" },
    ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ChannelDifinition() count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *channel = [ChannelDifinition() objectAtIndex:[indexPath row]];
    NSString *name = [channel objectForKey:ChannelNameKey];
    NSString *number = [channel objectForKey:ChannelStringKey];
    [[cell textLabel] setText:name];
    [[cell detailTextLabel] setText:number];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
    NSDictionary *channel = [ChannelDifinition() objectAtIndex:[indexPath row]];
    NSString *name = [channel objectForKey:ChannelNameKey];
    NSString *number = [channel objectForKey:ChannelStringKey];

    NCJKTableViewController *destination = [segue destinationViewController];
    [destination setTitle:name];
    [destination setChannel:number];
}

@end

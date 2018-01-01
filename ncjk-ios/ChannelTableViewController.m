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
static NSString * const ChannelIdentifierKey = @"url";

static NSArray<NSDictionary *> * ChannelDifinition() {
    return @[
             @{ ChannelStringKey: @"1ch", ChannelNameKey:@"NHK 総合", ChannelIdentifierKey: @"jk1" },
             @{ ChannelStringKey: @"2ch", ChannelNameKey:@"Eテレ", ChannelIdentifierKey: @"jk2" },
             @{ ChannelStringKey: @"4ch", ChannelNameKey:@"日本テレビ", ChannelIdentifierKey: @"jk4" },
             @{ ChannelStringKey: @"5ch", ChannelNameKey:@"テレビ朝日", ChannelIdentifierKey: @"jk5" },
             @{ ChannelStringKey: @"6ch", ChannelNameKey:@"TBS テレビ", ChannelIdentifierKey: @"jk6" },
             @{ ChannelStringKey: @"7ch", ChannelNameKey:@"テレビ東京", ChannelIdentifierKey: @"jk7" },
             @{ ChannelStringKey: @"8ch", ChannelNameKey:@"フジテレビ", ChannelIdentifierKey: @"jk8" },
             @{ ChannelStringKey: @"9ch", ChannelNameKey:@"TOKYO MX", ChannelIdentifierKey: @"jk9" },
             @{ ChannelStringKey: @"3ch", ChannelNameKey:@"テレ玉", ChannelIdentifierKey: @"jk10" },
             @{ ChannelStringKey: @"3ch", ChannelNameKey:@"tvk", ChannelIdentifierKey: @"jk11" },
             @{ ChannelStringKey: @"3ch", ChannelNameKey:@"チバテレビ", ChannelIdentifierKey: @"jk12" },
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
    NSString *identifier = [channel objectForKey:ChannelIdentifierKey];

    NCJKTableViewController *destination = [segue destinationViewController];
    [destination setTitle:name];
    [destination setChannel:identifier];
}

@end

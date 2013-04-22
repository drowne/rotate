//
//  MVRHighScoreViewController.m
//  Rotate!
//
//  Created by Movellas on 4/22/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "MVRHighScoreViewController.h"

static const NSString *kMRVBestScoresKey = @"best";
static const NSString *kMRVWorstScoresKey = @"worst";
static const NSString *kMRVMyScoreKey = @"you";
static const NSString *kMRVMyEnumPositionKey = @"enumPosition";

@interface MVRHighScoreViewController ()
@property (nonatomic, strong) NSMutableDictionary *scores;
@end

@implementation MVRHighScoreViewController


-(void)awakeFromNib{
    
    _scores = [NSMutableDictionary dictionary];
    
    //        [self.scores setObject:[NSMutableArray array] forKey:kMRVBestScoresKey];
    //        [self.scores setObject:[NSMutableArray array] forKey:kMRVWorstScoresKey];
    //        [self.scores setObject:[NSMutableDictionary dictionary] forKey:kMRVMyScoreKey];
    //        [self.scores setObject:[NSNumber numberWithInt:-1] forKey:kMRVMyEnumPositionKey];
    
    [self.scores setObject:[NSMutableArray arrayWithArray:@[@0,@0,@0,@1]] forKey:kMRVBestScoresKey];
    [self.scores setObject:[NSMutableArray arrayWithArray:@[@2,@2,@2]] forKey:kMRVWorstScoresKey];
    [self.scores setObject:[NSMutableDictionary dictionary] forKey:kMRVMyScoreKey];
    [self.scores setObject:[NSNumber numberWithInt:-1] forKey:kMRVMyEnumPositionKey];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

#pragma mark - Accessors 

- (NSMutableArray*)MRVBestScores {
    return [_scores objectForKey:kMRVBestScoresKey];
}

- (NSMutableArray*)MRVWorstScores {
    return [_scores objectForKey:kMRVWorstScoresKey];
}

- (NSMutableDictionary*)MRVMyScore {
    return [_scores objectForKey:kMRVMyScoreKey];
}

- (NSNumber*)MRVMyEnumPosition {
    return [_scores objectForKey:kMRVMyEnumPositionKey];
}

- (BOOL)isUserInTheMiddle {
#warning remove
    return NO;
    return [self MRVMyEnumPosition].intValue == 1;
}

- (BOOL)isUserInTheBest {
    return [self MRVMyEnumPosition].intValue == 0;
}

- (BOOL)isUserInTheWorst {
    return [self MRVMyEnumPosition].intValue == 2;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#define kMVRBestSection 0
#define kMVRMiddleSection 1
#define kMVRWorstSection 2

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
    switch (section) {
        case kMVRBestSection:
            rows = [self MRVBestScores].count;
            
        case kMVRMiddleSection:
            if ([self isUserInTheMiddle]) 
                rows = 1;
            else
                rows = 0;

        case kMVRWorstSection:
            rows = [self MRVWorstScores].count;
            
    }
    
    return rows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    NSDictionary *spin = @{@"points": @(10+indexPath.row-(indexPath.section*2)),
                           @"displayname": [NSString stringWithFormat:@"pippo-%d_%d", indexPath.section, indexPath.row],
                           @"when": @"14-09/2012"};
    [cell.textLabel setText:(NSString*)[spin objectForKey:@"displayname"]];
    
    NSString *sub = [NSString stringWithFormat:@"%@ - %@", [spin objectForKey:@"points"], [spin objectForKey:@"when"]];
    [cell.detailTextLabel setText:sub];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

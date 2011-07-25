//
//  SenseViewController_iPhone.h
//  Dubsar
//
//  Created by Jimmy Dee on 7/23/11.
//  Copyright 2011 Jimmy Dee. All rights reserved.
//

#import "SearchBarViewController_iPhone.h"

@class Sense;


@interface SenseViewController_iPhone : SearchBarViewController_iPhone
{
    UILabel *bannerLabel;
    UIScrollView *glossScrollView;
    UILabel *glossLabel;
    UITableView *tableView;
    UILabel *detailLabel;
    UIView *detailView;
    NSMutableArray* tableSections;
    UINib* detailNib;
    UIView* mainView;
}

@property (nonatomic, retain) Sense* sense;
@property (nonatomic, retain) IBOutlet UILabel *bannerLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *glossScrollView;
@property (nonatomic, retain) IBOutlet UILabel *glossLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (nonatomic, retain) IBOutlet UIView *detailView;

- (void)displayPopup:(NSString*)text;
- (IBAction)dismissPopup:(id)sender;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil sense:(Sense*)theSense;

-(void)adjustBannerLabel;
-(void)loadSynsetView;
-(void)loadWordView;

-(void)followTableLink:(NSIndexPath*)indexPath;

- (void)setupTableSections;

@end

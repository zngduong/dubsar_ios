/*
 Dubsar Dictionary Project
 Copyright (C) 2010-11 Jimmy Dee
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "DubsarAppDelegate_iPad.h"
#import "PartOfSpeechDictionary.h"
#import "PointerDictionary.h"
#import "Sense.h"
#import "SenseViewController_iPad.h"
#import "Synset.h"
#import "SynsetViewController_iPad.h"


@implementation SynsetViewController_iPad
@synthesize synset;
@synthesize tableView;
@synthesize bannerLabel;
@synthesize detailLabel;
@synthesize detailView;
@synthesize detailBannerLabel;
@synthesize detailGlossTextView;
@synthesize glossTextView;


- (void)displayPopup:(NSString*)text
{
    [detailLabel setText:text];
    [UIView transitionWithView:self.view duration:0.4 
                       options:UIViewAnimationOptionTransitionFlipFromRight 
                    animations:^{
                        bannerLabel.hidden = YES;
                        // glossScrollView.hidden = YES;
                        tableView.hidden = YES;
                        detailView.hidden = NO;
                        self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
                        UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque;
                    } completion:^(BOOL finished){
                    }];
}

- (IBAction)dismissPopup:(id)sender {
    [tableView reloadData];
    [UIView transitionWithView:self.view duration:0.4 
                       options:UIViewAnimationOptionTransitionFlipFromLeft 
                    animations:^{
                        bannerLabel.hidden = NO;
                        // glossScrollView.hidden = NO;
                        tableView.hidden = NO;
                        detailView.hidden = YES;
                        self.navigationController.toolbar.barStyle = UIBarStyleDefault;
                        UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
                    } completion:^(BOOL finished){
                        
                    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil synset:(Synset *)theSynset
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.synset = theSynset;
        synset.delegate = self;
        
        [self adjustTitle];
                
        detailNib = [[UINib nibWithNibName:@"DetailView_iPad" bundle:nil]retain];
        
    }
    return self;
}

- (void)dealloc
{
    [tableSections release];
    [detailGlossTextView release];
    [detailLabel release];
    [detailView release];
    synset.delegate = nil;
    [synset release];
    [tableView release];
    [bannerLabel release];
    [detailBannerLabel release];
    [glossTextView release];
    [super dealloc];
}

- (void)load
{
    [synset load];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [detailNib instantiateWithOwner:self options:nil];
    [detailView setHidden:YES];
    [self.view addSubview:detailView];
}

- (void)viewDidUnload
{
    [self setDetailGlossTextView:nil];
    [self setDetailLabel:nil];
    [self setDetailView:nil];
    [self setTableView:nil];
    [self setBannerLabel:nil];
    [self setDetailBannerLabel:nil];
    [self setGlossTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (synset.complete) {
        [self loadComplete:synset withError:synset.errorMessage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    bannerLabel.hidden = NO;
    tableView.hidden = NO;
    detailView.hidden = YES;
}

- (void)loadComplete:(Model*)model withError:(NSString *)error
{
    if (model != synset) return;
    
    if (error) {
        [bannerLabel setHidden:YES];
        [tableView setHidden:YES];
        [glossTextView setText:error];
        return;
    }
    
    [self adjustTitle];
    [self adjustBannerLabel];
    [self adjustGlossLabel];
    [self setupTableSections];
    [tableView reloadData];
}

- (void)adjustBannerLabel
{
    NSString* text = [NSString stringWithFormat:@"<%@>", synset.lexname];
    if (synset.freqCnt > 0) {
        text = [text stringByAppendingFormat:@" freq. cnt.: %d", synset.freqCnt];
    }
    bannerLabel.text = text;
    detailBannerLabel.text = text;
}

- (void)adjustGlossLabel
{
    glossTextView.text = synset.gloss;
    detailGlossTextView.text = [synset.synonymsAsString stringByAppendingFormat:@" (%@.)", [PartOfSpeechDictionary posFromPartOfSpeech:synset.partOfSpeech]];
}

- (void)adjustTitle
{
    if (synset.gloss) {
        self.title = [NSString stringWithFormat:@"Synset: %@", synset.gloss];
    }
    else {
        self.title = [NSString stringWithString:@"Synset"];
    }
}

- (void)loadRootController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/* TableView management */

- (void)tableView:(UITableView*)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self followTableLink:indexPath];
}

- (void)tableView:(UITableView *)theTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self followTableLink:indexPath];   
}

- (void)followTableLink:(NSIndexPath *)indexPath
{
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    NSDictionary* _section = [tableSections objectAtIndex:section];
    id _linkType = [_section valueForKey:@"linkType"];
    if (_linkType == NSNull.null) return;
    
    NSArray* _collection = [_section valueForKey:@"collection"];
    id _object = [_collection objectAtIndex:row];
    
    Sense* targetSense=nil;
    
    if ([_linkType isEqualToString:@"sense"]) {
        targetSense = _object;
        SenseViewController_iPad* senseViewController = [[[SenseViewController_iPad alloc]initWithNibName:@"SenseViewController_iPad" bundle:nil sense:targetSense]autorelease];
        [senseViewController load];
        [self.navigationController pushViewController:senseViewController animated:YES];
    }
    else if ([_linkType isEqualToString:@"sample"]) {
        [self displayPopup:_object];
    }
    else {
        NSArray* pointer = _object;
        NSNumber* targetId = [pointer objectAtIndex:1];
        /* synset pointer */
        Synset* targetSynset = [Synset synsetWithId:targetId.intValue partOfSpeech:POSUnknown];
        SynsetViewController_iPad* synsetViewController = [[[SynsetViewController_iPad alloc]initWithNibName:@"SynsetViewController_iPad" bundle:nil synset:targetSynset]autorelease];
        [synsetViewController load];
        [self.navigationController pushViewController:synsetViewController animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)theTableView
{
    NSInteger n = synset && synset.complete ? tableSections.count : 1;
    return n;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary* _section = [tableSections objectAtIndex:section];
    NSArray* _collection = [_section valueForKey:@"collection"];
    NSInteger n = synset && synset.complete ? _collection.count : 1 ;
    return n;
}

- (UITableViewCell*)tableView:(UITableView*)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellType = @"synset";
    
    UITableViewCell* cell = [theTableView dequeueReusableCellWithIdentifier:cellType];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType]autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!synset || !synset.complete) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"indicator"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"indicator"]autorelease];
        }
        UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]autorelease];
        [cell.contentView addSubview:indicator];
        CGRect frame = CGRectMake(10.0, 10.0, 24.0, 24.0);
        indicator.frame = frame;
        [indicator startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        int section = indexPath.section;
        int row = indexPath.row;
        NSDictionary* _section = [tableSections objectAtIndex:section];
        NSArray* _collection = [_section valueForKey:@"collection"];
        id _object = [_collection objectAtIndex:row];
        bool hasLinks = [_section valueForKey:@"linkType"] != NSNull.null;
        NSString* linkType = nil;
        if (hasLinks) linkType = [_section valueForKey:@"linkType"];
        
        if ([_object respondsToSelector:@selector(name)]) {
            cell = [theTableView dequeueReusableCellWithIdentifier:@"synsetPointer"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"synsetPointer"]autorelease];
            }
            
            cell.textLabel.text = [_object name];
            NSString* detailLine = [NSString string];
            if ([_object respondsToSelector:@selector(freqCnt)] && [_object freqCnt] > 0) {
                detailLine = [detailLine stringByAppendingFormat:@"freq. cnt.: %d", [_object freqCnt]];
            }
            if ([_object respondsToSelector:@selector(marker)] && [_object marker]) {
                detailLine = [detailLine stringByAppendingFormat:@" (%@)", [_object marker]];
            }
            cell.detailTextLabel.text = detailLine;
        }
        else if ([_object respondsToSelector:@selector(objectAtIndex:)]) {
            cell = [theTableView dequeueReusableCellWithIdentifier:@"synsetPointer"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"synsetPointer"]autorelease];
            }
            
            // pointers
            cell.textLabel.text = [_object objectAtIndex:2];
            cell.detailTextLabel.text = [_object objectAtIndex:3];
        }
        else {
            // must be a string
            cell.textLabel.text = _object;
        }
        
        if ([linkType isEqualToString:@"sample"]) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    DubsarAppDelegate_iPad* appDelegate = (DubsarAppDelegate_iPad*)UIApplication.sharedApplication.delegate;
    cell.textLabel.textColor = appDelegate.dubsarTintColor;
    cell.textLabel.font = appDelegate.dubsarNormalFont;
    cell.detailTextLabel.font = appDelegate.dubsarSmallFont;
   
    return cell;
}

- (NSString*)tableView:(UITableView*)theTableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary* _section = [tableSections objectAtIndex:section];
    NSString* title = synset && synset.complete ? [_section valueForKey:@"header"] : @"loading...";
    return title;
}

- (NSString*)tableView:(UITableView*)theTableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary* _section = [tableSections objectAtIndex:section];
    NSString* title = synset && synset.complete ? [_section valueForKey:@"footer"] : @"";
    return title;
}

- (void)setupTableSections
{
    tableSections = [[NSMutableArray array]retain];
    NSMutableDictionary* section;
    if (synset.senses && synset.senses.count > 0) {
        section = [NSMutableDictionary dictionary];
        [section setValue:@"Synonyms" forKey:@"header"];
        [section setValue:[PointerDictionary helpWithPointerType:@"synonym"] forKey:@"footer"];
        [section setValue:synset.senses forKey:@"collection"];
        [section setValue:@"sense" forKey:@"linkType"];
        [tableSections addObject:section];
    }
    
    if (synset.samples && synset.samples.count > 0) {
        section = [NSMutableDictionary dictionary];
        [section setValue:@"Sample Sentences" forKey:@"header"];
        [section setValue:[PointerDictionary helpWithPointerType:@"sample sentence"] forKey:@"footer"];
        [section setValue:synset.samples forKey:@"collection"];
        [section setValue:@"sample" forKey:@"linkType"];
        [tableSections addObject:section];
    }
    
    if (synset.pointers && synset.pointers.count > 0) {
        NSArray* keys = [synset.pointers allKeys];
        for (int j=0; j<keys.count; ++j) {
            NSString* key = [keys objectAtIndex:j];
            NSString* title = [PointerDictionary titleWithPointerType:key];
            
            section = [NSMutableDictionary dictionary];
            [section setValue:title forKey:@"header"];
            [section setValue:[PointerDictionary helpWithPointerType:key] forKey:@"footer"];
            [section setValue:[synset.pointers valueForKey:key] forKey:@"collection"];
            [section setValue:@"pointer" forKey:@"linkType"];
            [tableSections addObject:section];
        }
    }
}

@end

//
//  LicenseViewController.m
//  Dubsar
//
//  Created by Jimmy Dee on 7/20/11.
//  Copyright 2011 Jimmy Dee. All rights reserved.
//

#import "DubsarViewController_iPhone.h"
#import "LicenseViewController_iPhone.h"
#import "SearchBarManager_iPHone.h"

@implementation LicenseViewController_iPhone
@synthesize searchBarManager;
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"License";
        [self createToolbarItems];
    }
    return self;
}

- (void)dealloc
{
    [searchBarManager release];
    [searchBar release];
    [super dealloc];
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
    searchBarManager = [[SearchBarManager_iPhone alloc]initWithSearchBar:searchBar navigationController:self.navigationController];
}

- (void)viewDidUnload
{
    [self setSearchBarManager:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
        (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
        (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        return YES;
    
    return NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    [searchBarManager searchBarTextDidBeginEditing:theSearchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
{
    [searchBarManager searchBarTextDidEndEditing:theSearchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBarManager searchBarCancelButtonClicked:theSearchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBarManager searchBarSearchButtonClicked:theSearchBar];
}

- (void)createToolbarItems
{
    UIBarButtonItem* homeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(loadRootController)];
    
    NSMutableArray* buttonItems = [NSMutableArray arrayWithObject:homeButtonItem];
    
    self.toolbarItems = buttonItems;
}

- (void)loadRootController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
//
//  SearchViewController.m
//  Dubsar
//
//  Created by Jimmy Dee on 7/20/11.
//  Copyright 2011 Jimmy Dee. All rights reserved.
//

#import <stdlib.h>

#import "DubsarViewController_iPhone.h"
#import "SearchViewController_iPhone.h"
#import "Search.h"
#import "Word.h"
#import "WordViewController_iPHone.h"


@implementation SearchViewController_iPhone

@synthesize search;
@synthesize pageLabel = _pageLabel;
@synthesize searchText=_searchText;
@synthesize searchResultsTableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString*)theSearchText 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*
         * The argument (theSearchText) is the content of the search bar from the previous 
         * view that launched this search, not the search bar associated with this
         * controller. That view was just unloaded. We make a copy here.
         */
        _searchText = [[theSearchText copy] retain];
        
        // set up a new search request to the server asynchronously
        search = [[Search searchWithTerm:_searchText] retain];
        search.delegate = self;
        
        // send the request
        [search load];
        
        self.title = [NSString stringWithFormat:@"Search: \"%@\"", _searchText];
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [search release];
    [_searchText release];
    [_pageLabel release];
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
}

- (void)viewDidUnload
{
    [self setPageLabel:nil];
    [self setSearchBar:nil];
    [self setSearchResultsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustPageLabel];
    searchBar.text = [_searchText copy];
    [_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    if (theSearchBar != searchBar) return;
    
    _searchText = @"";
    [self adjustPageLabel];
    [super searchBarCancelButtonClicked:theSearchBar];
}

- (void)searchBar:(UISearchBar*)theSearchBar textDidChange:(NSString *)searchText
{
    if (theSearchBar != searchBar) return;
    NSLog(@"search text changed in search view search bar");
    _searchText = [searchText copy];
    [super searchBar:theSearchBar textDidChange:searchText];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != _tableView) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    
    int index = indexPath.row;
    Word* word = [search.results objectAtIndex:index];
    [self.navigationController pushViewController:[[WordViewController_iPhone alloc]initWithNibName:@"WordViewController_iPhone" bundle:nil word:word] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (_tableView != tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    NSInteger rows = search.complete && search.results ? search.results.count : 1;
    NSLog(@"tableView:numberOfRowsInSection: = %d", rows);
    return rows;
}

- (NSString*)tableView:(UITableView*)theTableView titleForHeaderInSection:(NSInteger)section
{
    if (theTableView != _tableView) {
        return [super tableView:theTableView titleForHeaderInSection:section];
    }
    
    return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView != _tableView) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString* cellType = @"search";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType]autorelease];
    }
    
    if (!search.complete) {
        cell.textLabel.text = @"loading...";
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    NSLog(@"have view cell, loading data");

    int index = indexPath.row;
    NSLog(@"looking for index %d", index);
    Word* word = [search.results objectAtIndex:index];
    NSLog(@"found \"%@\"", [word nameAndPos]);
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [word nameAndPos];
    return cell;
}

- (void)adjustPageLabel
{
    if (_searchText.length > 0) {
        _pageLabel.text = [NSString stringWithFormat:@"search results for \"%@\"", _searchText];
    }
    else {
        _pageLabel.text = @"enter a word or words";
    }
}

- (void)loadComplete:(Model *)model
{
    if (model != search) return;
    
    NSLog(@"search complete");
    [_tableView reloadData];
}

@end

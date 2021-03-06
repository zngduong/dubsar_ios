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

#import <UIKit/UIKit.h>
#import "LoadDelegate.h"

@class Word;

@interface WordPopoverViewController_iPad : UIViewController<LoadDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UITextView *inflectionsTextView;
    UILabel *headerLabel;
    UIColor* highlightBg;
    UIColor* highlightTextColor;
    UIColor* origBg;
    UIColor* origTextColor;
}

@property (nonatomic, assign) UINavigationController* navigationController;
@property (nonatomic, assign) UIPopoverController* popoverController;
@property (nonatomic, retain) Word* word;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextView *inflectionsTextView;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil word:(Word*)theWord;
- (void)adjustInflections;
- (void)adjustTitle;
- (void)load;
- (IBAction)loadWord:(id)sender;
- (void)fireButton:(UITapGestureRecognizer*)sender;

- (void)adjustTableViewFrame;
- (void)adjustPopoverSize;

- (void)addGestureRecognizer;

@end

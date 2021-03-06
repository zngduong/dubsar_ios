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

#import "DailyWord.h"
#import "JSONkit.h"
#import "Word.h"

@implementation DailyWord

@synthesize word;

- (id)init
{
    self = [super init];
    if (self) {
        [self set_url:@"/wotd"];
        word = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [word release];
    [super dealloc];
}

- (void)load
{
    [self loadFromServer];
}

- (void)parseData
{
    NSArray* wotd = [[self decoder] objectWithData:[self data]];
    NSNumber* numericId = [wotd objectAtIndex:0];
    
    word = [[Word wordWithId:numericId.intValue name:[wotd objectAtIndex:1] posString:[wotd objectAtIndex:2]]retain];
    
    NSNumber* fc = [wotd objectAtIndex:3];
    word.freqCnt = fc.intValue;
    
    word.inflections = [wotd objectAtIndex:4];
}

@end

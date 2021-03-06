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

#import "DubsarAppDelegate.h"
#import "Section.h"

@implementation Section
@synthesize header;
@synthesize footer;
@synthesize linkType;
@synthesize ptype;
@synthesize numRows=_numRows;
@synthesize senseId;
@synthesize synsetId;

+ (id)section
{
    return [[[self alloc]init]autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        header = nil;
        footer = nil;
        linkType = nil;
        ptype = nil;
        _numRows = senseId = synsetId = 0;
    }
    
    return self;
}

- (int)numRows
{
    if ([ptype isEqualToString:@"synonym"] ||
        [ptype isEqualToString:@"verb frame"] ||
        [ptype isEqualToString:@"sample sentence"]) return _numRows;
    
    NSLog(@"counting rows");

    DubsarAppDelegate* appDelegate = (DubsarAppDelegate*)UIApplication.sharedApplication.delegate;
    NSString* sql;
    
    if (senseId != 0) {
        sql = [NSString stringWithFormat:
           @"SELECT COUNT(*) FROM "
           @"(SELECT DISTINCT target_id, target_type FROM pointers WHERE "
           @"(ptype = '%@' AND ((source_id = %d AND source_type = 'Sense') OR "
           @"(source_id = %d AND source_type = 'Synset'))))", ptype, senseId, synsetId];
    }
    else {
        sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM "
               @"(SELECT DISTINCT target_id, target_type FROM pointers WHERE "
               @"ptype = '%@' AND source_id = %d AND source_type = 'Synset')", ptype, synsetId];
    }
    int rc;
    sqlite3_stmt* statement;
    if ((rc=sqlite3_prepare_v2(appDelegate.database, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL)) != SQLITE_OK) {
        NSLog(@"error %d preparing statement", rc);
        return 0;
    }
    
    NSLog(@"executing %@", sql);
    int count;
    if (sqlite3_step(statement) == SQLITE_ROW) {
        count = sqlite3_column_int(statement, 0);
        NSLog(@"%d rows of type %@", count, ptype);
    }
    
    sqlite3_finalize(statement);
    
    return count;
}

@end

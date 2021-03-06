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

#import "Dubsar.h"
#import "Model.h"

@class Pointer;
@class Synset;
@class Word;

@interface Sense : Model {
    bool weakSynsetLink, weakWordLink;
    sqlite3_stmt* pointerQuery;
    sqlite3_stmt* lexicalQuery;
    sqlite3_stmt* semanticQuery;
}

@property int _id;
@property (nonatomic, retain) NSString* name;
@property PartOfSpeech partOfSpeech;
@property (nonatomic, retain) NSString* gloss;
@property (nonatomic, retain) NSMutableArray* synonyms;

@property (nonatomic, retain) Synset* synset;
@property (nonatomic, retain) Word* word;

@property (nonatomic, retain) NSString* lexname;
@property int freqCnt;
@property (nonatomic, retain) NSString* marker;

@property (nonatomic, retain) NSMutableArray* verbFrames;
@property (nonatomic, retain) NSMutableArray* samples;
@property (nonatomic, retain) NSMutableDictionary* pointers;

@property (nonatomic) int numberOfSections;
@property (nonatomic, retain) NSMutableArray* sections;

+(id)senseWithId:(int)theId name:(NSString*)theName synset:(Synset*)theSynset;
+(id)senseWithId:(int)theId name:(NSString*)theName partOfSpeech:(PartOfSpeech)thePartOfSpeech;
+(id)senseWithId:(int)theId gloss:(NSString*)theGloss synonyms:(NSArray*)theSynonyms word:(Word*)theWord;
+(id)senseWithId:(int)theId nameAndPos:(NSString*)nameAndPos;
-(id)initWithId:(int)theId name:(NSString*)theName synset:(Synset*)theSynset;
-(id)initWithId:(int)theId name:(NSString*)theName partOfSpeech:(PartOfSpeech)thePartOfSpeech;
-(id)initWithId:(int)theId gloss:(NSString*)theGloss synonyms:(NSArray*)theSynonyms word:(Word*)theWord;
-(id)initWithId:(int)theId nameAndPos:(NSString*)nameAndPos;

-(NSString*)pos;
-(NSString*)nameAndPos;
-(void)initUrl;
-(void)parsePointers:(NSArray*)response;

-(NSComparisonResult)compareFreqCnt:(Sense*)sense;

-(NSString*)synonymsAsString;
-(void)parseNameAndPos:(NSString*)nameAndPos;

// -(void)loadPointers:(DubsarAppDelegate*)appDelegate;
// -(void)countPointers:(DubsarAppDelegate*)appDelegate;

-(void)prepareStatements;
-(void)destroyStatements;
-(Pointer*)pointerForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

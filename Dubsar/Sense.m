//
//  Sense.m
//  Dubsar
//
//  Created by Jimmy Dee on 7/23/11.
//  Copyright 2011 Jimmy Dee. All rights reserved.
//

#import "Dubsar.h"
#import "JSONKit.h"
#import "Sense.h"
#import "Synset.h"
#import "Word.h"

@implementation Sense

@synthesize _id;
@synthesize name;
@synthesize partOfSpeech;
@synthesize gloss;
@synthesize synonyms;
@synthesize synset;
@synthesize word;
@synthesize lexname;
@synthesize marker;
@synthesize freqCnt;
@synthesize verbFrames;
@synthesize samples;
@synthesize pointers;

+(id)senseWithId:(int)theId name:(NSString *)theName synset:(Synset *)theSynset
{
    return [[self alloc]initWithId:theId name:theName synset:theSynset];
}

+(id)senseWithId:(int)theId name:(NSString *)theName partOfSpeech:(PartOfSpeech)thePartOfSpeech
{
    return [[self alloc]initWithId:theId name:theName partOfSpeech:thePartOfSpeech];
}

+(id)senseWithId:(int)theId gloss:(NSString *)theGloss synonyms:(NSArray *)theSynonyms word:(Word *)theWord
{
    return [[self alloc]initWithId:theId gloss:theGloss synonyms:theSynonyms word:theWord];
}

-(id)initWithId:(int)theId name:(NSString *)theName synset:(Synset *)theSynset
{
    self = [super init];
    if (self) {
        _id = theId;
        name = [[theName copy]retain];
        word = nil;
        gloss = nil;
        synonyms = nil;
        synset = [theSynset retain];
        partOfSpeech = synset.partOfSpeech;
        marker = nil;
        verbFrames = nil;
        samples = nil;
        pointers = nil;
        [self initUrl];
    }
    return self;
}

-(id)initWithId:(int)theId name:(NSString *)theName partOfSpeech:(PartOfSpeech)thePartOfSpeech
{
    self = [super init];
    if (self) {
        _id = theId;
        name = [[theName copy]retain];
        word = nil;
        gloss = nil;
        synonyms = nil;
        synset = nil;
        partOfSpeech = thePartOfSpeech;
        marker = nil;
        verbFrames = nil;
        samples = nil;
        pointers = nil;
        [self initUrl];
    }
    return self;
   
}

-(id)initWithId:(int)theId gloss:(NSString *)theGloss synonyms:(NSArray *)theSynonyms word:(Word *)theWord
{
    self = [super init];
    if (self) {
        _id = theId;
        gloss = [[theGloss copy]retain];
        synonyms = [theSynonyms retain];
        word = [theWord retain];
        partOfSpeech = word.partOfSpeech;
        
        /* no need to retain or release this, which just points to another property */
        name = word.name;
        synset = nil;
        marker = nil;
        verbFrames = nil;
        samples = nil;
        pointers = nil;
        [self initUrl];
    }
    return self;
}

-(void)dealloc
{
    [pointers release];
    [samples release];
    [verbFrames release];
    [gloss release];
    [synonyms release];
    [synset release];
    [word release];
    [lexname release];
    [marker release];
    [super dealloc];
}

-(NSString*)synonymsAsString
{
    NSString* synonymList = [NSString string];
    for(int j=0; j<synonyms.count; ++j) {
        Word* synonym = [synonyms objectAtIndex:j];
        synonymList = [synonymList stringByAppendingString:synonym.name];
        if (j<synonyms.count-1) {
            synonymList = [synonymList stringByAppendingString:@", "];
        }
    }
    
    return synonymList;
}

-(NSString*)pos
{
    switch (partOfSpeech) {
        case POSAdjective:
            return @"adj";
        case POSAdverb:
            return @"adv";
        case POSConjunction:
            return @"conj";
        case POSInterjection:
            return @"interj";
        case POSNoun:
            return @"n";
        case POSPreposition:
            return @"prep";
        case POSPronoun:
            return @"pron";
        case POSVerb:
            return @"v";
        default:
            // DEBT: Should throw an exception
            return nil;
    }
}

-(NSString *)nameAndPos
{
    return [[NSString alloc]initWithFormat:@"%@ (%@.)", name, self.pos];
}

-(void)parseData
{
    NSArray* response = [decoder objectWithData:data];
    NSArray* _word = [response objectAtIndex:1];
    NSNumber* _wordId = [_word objectAtIndex:0];
    NSArray* _synset = [response objectAtIndex:2];
    NSNumber* _synsetId = [_synset objectAtIndex:0];
    
    NSLog(@"parsing Sense response for %@", self.nameAndPos);
    if (!word) {
        word = [[Word wordWithId:_wordId.intValue name:[_word objectAtIndex:1] partOfSpeech:partOfSpeech]retain];
    }

    if (!gloss) {
        gloss = [_synset objectAtIndex:1];
    }
   
    if (!synset) {
        synset = [[Synset synsetWithId:_synsetId.intValue gloss:[_synset objectAtIndex:1] partOfSpeech:partOfSpeech] retain];
    }
    
    lexname = [[response objectAtIndex:3] retain];
    NSLog(@"lexname: \"%@\"", lexname);

    NSObject* _marker = [response objectAtIndex:4];
    if (_marker != NSNull.null) {
        marker = [_marker retain];
    }
    
    NSNumber* fc = [response objectAtIndex:5];
    freqCnt = fc.intValue;
    
    NSLog(@"freq. cnt.: %d", freqCnt);
    
    if (!synonyms) {
        NSArray* _synonyms = [response objectAtIndex:6];
        NSLog(@"found %u synonyms", [_synonyms count]);
        synonyms = [[NSMutableArray arrayWithCapacity:_synonyms.count] retain];
        for (int j=0; j< _synonyms.count; ++j) {
            NSArray* _synonym = [_synonyms objectAtIndex:j];
            NSNumber* _senseId = [_synonym objectAtIndex:0];
            Sense* sense = [Sense senseWithId:_senseId.intValue name:[_synonym objectAtIndex:1] synset:synset];
            NSLog(@" found %@, ID %d", sense.nameAndPos, _senseId.intValue);
            [synonyms insertObject:sense atIndex:j];
        }
    }
    
    NSArray* _verbFrames = [[response objectAtIndex:7]retain];
    NSLog(@"found %u verb frames", _verbFrames.count);
    verbFrames = [[NSMutableArray arrayWithCapacity:_verbFrames.count]retain];
    for (int j=0; j<_verbFrames.count; ++j) {
        NSString* frame = [_verbFrames objectAtIndex:j];
        NSString* format = [frame stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
        NSLog(@" %@", format);
        [verbFrames insertObject:[NSString stringWithFormat:format, name] atIndex:j];
    }
    samples = [[response objectAtIndex:8]retain];
    
    NSLog(@"found %u verb frames and %u sample sentences", [verbFrames count], [samples count]);
}

- (void)initUrl
{
    _url = [[NSString stringWithFormat:@"%@/senses/%d.json", DubsarBaseUrl, _id]retain];
}

@end

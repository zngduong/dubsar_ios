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
    
    NSArray* _verbFrames = [response objectAtIndex:7];
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
    
    [self parsePointers:response];
}

- (void)parsePointers:(NSArray*)response
{    
    pointers = [[NSMutableDictionary dictionary]retain];
    NSArray* _pointers = [response objectAtIndex:9];
    for (int j=0; j<_pointers.count; ++j) {
        NSArray* _pointer = [_pointers objectAtIndex:j];
        
        NSString* ptype = [_pointer objectAtIndex:0];
        NSString* targetType = [_pointer objectAtIndex:1];
        NSNumber* targetId = [_pointer objectAtIndex:2];
        NSString* targetText = [_pointer objectAtIndex:3];
        
        NSMutableArray* _pointersByType = [pointers valueForKey:ptype];
        if (_pointersByType == nil) {
            _pointersByType = [NSMutableArray array];
            [pointers setValue:_pointersByType forKey:ptype];
        }
        
        NSMutableArray* _ptr = [NSMutableArray array];
        [_ptr addObject:targetType];
        [_ptr addObject:targetId];
        [_ptr addObject:targetText];
        
        [_pointersByType addObject:_ptr];
        [pointers setValue:_pointersByType forKey:ptype];
    }
}

- (void)initUrl
{
    _url = [[NSString stringWithFormat:@"%@/senses/%d.json", DubsarBaseUrl, _id]retain];
}

+ (NSString*)helpWithPointerType:(NSString *)ptype
{
    /* From the Rails server (Pointer model):
     'antonym' => 'words opposite in meaning',
     'hypernym' => 'more generic terms',
     'instance hypernym' => 'classes of which this is an instance',
     'hyponym' => 'more specific terms',
     'instance hyponym' => 'instances of this class',
     'member holonym' => 'wholes of which this is a member',
     'substance holonym' => 'wholes of which this is an ingredient',
     'part holonym' => 'wholes of which this is a part',
     'member meronym' => 'constituent members',
     'substance meronym' => 'constituent substances',
     'part meronym' => 'constituent parts',
     'attribute' => 'general quality',
     'derivationally related form' => 'cognates, etc.',
     'domain of synset (topic)' => 'related topics',
     'member of this domain (topic)' => 'entries under this topic',
     'domain of synset (region)' => 'relevant region',
     'member of this domain (region)' => 'things relevant to this region',
     'domain of synset (usage)' => 'pertinent to usage',
     'member of this domain (usage)' => 'relevant by usage',
     'entailment' => 'consequence',
     'cause' => 'origin or reason',
     'also see' => 'related entries',
     'verb group' => 'related verbs',
     'similar to' => 'near in meaning, but not exact',
     'participle of verb' => 'root verb',
     'derived from/pertains to' => 'adj: pertinent noun; adv: source noun'

     */
    return @"";
}

+ (NSString*)titleWithPointerType:(NSString *)ptype
{
    if ([ptype isEqualToString:@"antonym"]) {
        return @"Antonyms";
    }
    else if ([ptype isEqualToString:@"hypernym"]) {
        return @"Hypernyms";
    }
    else if ([ptype isEqualToString:@"instance hypernym"]) {
        return @"Instance Hypernyms";
    }
    else if ([ptype isEqualToString:@"hyponym"]) {
        return @"Hyponyms";
    }
    else if ([ptype isEqualToString:@"instance hyponym"]) {
        return @"Instance Hyponyms";
    }
    else if ([ptype isEqualToString:@"member holonym"]) {
        return @"Member Hypernyms";
    }
    else if ([ptype isEqualToString:@"substance holonym"]) {
        return @"Substance Holonyms";
    }
    else if ([ptype isEqualToString:@"part holonym"]) {
        return @"Part Holonyms";
    }
    else if ([ptype isEqualToString:@"member meronym"]) {
        return @"Member Meronyms";
    }
    else if ([ptype isEqualToString:@"substance meronym"]) {
        return @"Substance Meronyms";
    }
    else if ([ptype isEqualToString:@"part meronym"]) {
        return @"Part Meronyms";
    }
    else if ([ptype isEqualToString:@"attribute"]) {
        return @"Attributes";
    }
    else if ([ptype isEqualToString:@"derivationally related form"]) {
        return @"Derivationally Related Forms";
    }
    else if ([ptype isEqualToString:@"domain of synset (topic)"]) {
        return @"Domains of Synset (Topic)";
    }
    else if ([ptype isEqualToString:@"member of this domain (topic)"]) {
        return @"Members of this Domain (Topic)";
    }
    else if ([ptype isEqualToString:@"domain of synset (region)"]) {
        return @"Domains of Synset (Region)";
    }
    else if ([ptype isEqualToString:@"member of this domain (region)"]) {
        return @"Members of this Domain (Region)";
    }
    else if ([ptype isEqualToString:@"domain of synset (usage)"]) {
        return @"Domains of Synset (Usage)";
    }
    else if ([ptype isEqualToString:@"member of this domain (usage)"]) {
        return @"Members of this Domain (Usage)";
    }
    else if ([ptype isEqualToString:@"entailment"]) {
        return @"Entailments";
    }
    else if ([ptype isEqualToString:@"cause"]) {
        return @"Causes";
    }
    else if ([ptype isEqualToString:@"also see"]) {
        return @"Also See";
    }
    else if ([ptype isEqualToString:@"verb group"]) {
        return @"Verb Groups";
    }
    else if ([ptype isEqualToString:@"similar to"]) {
        return @"Similar to";
    }
    else if ([ptype isEqualToString:@"participle of verb"]) {
        return @"Participle of Verbs";
    }
    else if ([ptype isEqualToString:@"derived from/pertains to"]) {
        return @"Derived from/Pertains to";
    }
   
    return @"";
}

@end

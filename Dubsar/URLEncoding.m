#import "URLEncoding.h"


@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding 
{
	CFStringRef cvalue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding));
    
    // autoreleased string
    NSString* svalue = [NSString stringWithString:(NSString*)cvalue];
    CFRelease(cvalue);
    
    return svalue;
}

@end

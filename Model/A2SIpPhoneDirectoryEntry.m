#import "A2SIpPhoneDirectoryEntry.h"

@implementation A2SIpPhoneDirectoryEntry

- (instancetype)init
{
	self = [super init];

	_name      = nil;
    _telephone = nil;
    _office = nil;
    _mobile = nil;

	return self;
}

- (void) dealloc
{
    [_name release];
    [_telephone release];
    [_office release];
    [_mobile release];

    [super dealloc];
}

@end

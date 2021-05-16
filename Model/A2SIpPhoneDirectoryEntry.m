#import "A2SIpPhoneDirectoryEntry.h"
#include <ObjFW/OFObject.h>

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

- (void)dealloc
{
    [_name release];
    [_telephone release];
    [_office release];
    [_mobile release];

    [super dealloc];
}

- (OFString*)description
{
    return [OFString stringWithFormat: @"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@", self.name, self.telephone, self.office, self.mobile];
}

@end

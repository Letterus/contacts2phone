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

- (instancetype)initWithSerialization: (OFXMLElement *)element
{
    @throw [OFNotImplementedException exceptionWithSelector:@selector(initWithSerialization) object:self];
}

- (void)dealloc
{
    [_name release];
    [_telephone release];
    [_office release];
    [_mobile release];

    [super dealloc];
}

- (OFXMLElement *)XMLElementBySerializing
{
	OFXMLElement *element = [OFXMLElement elementWithName: @"DirectoryEntry"];

    OFXMLElement *name = [OFXMLElement elementWithName: @"Name"
                                           stringValue:self.name];
    [element addChild:name];

    if(self.telephone != nil && self.telephone.length > 0) {
        OFXMLElement *telephone = [OFXMLElement elementWithName: @"Telephone"
                                                    stringValue:self.telephone];
        [element addChild:telephone];
    }

    if(self.office != nil && self.office.length > 0) {
        OFXMLElement *office = [OFXMLElement elementWithName: @"Office"
                                                 stringValue:self.office];
        [element addChild:office];
    }

    if(self.mobile!= nil && self.mobile.length > 0) {
        OFXMLElement *mobile = [OFXMLElement elementWithName: @"Mobile"
                                                 stringValue:self.mobile];
        [element addChild:mobile];
    }

	return element;
}

- (OFString*)description
{
    return [OFString stringWithFormat: @"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@", self.name, self.telephone, self.office, self.mobile];
}

@end

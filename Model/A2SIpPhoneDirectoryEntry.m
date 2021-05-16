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
	OFXMLElement *element = [OFXMLElement elementWithName: @"DirectoryEntry"
				                              stringValue: [OFString stringWithFormat:
                                    @"\t\t\t<Name>%@</Name>\n\t\t\t<Telephone>%@</Telephone>\n\t\t\t<Office>%@</Office>\n\t\t\t<Mobile>%@</Mobile>\n", 
                                    self.name, self.telephone, self.office, self.mobile]
                            ];

	return element;
}

- (OFString*)description
{
    return [OFString stringWithFormat: @"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@", self.name, self.telephone, self.office, self.mobile];
}

@end

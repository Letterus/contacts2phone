#import "A2SIpPhoneDirectoryEntry.h"
#include <ObjFW/OFString.h>
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
    OFConstantString* emptyString = @"";

    OFXMLElement *name = [OFXMLElement elementWithName: @"Name"
                                           stringValue:self.name];
    [element addChild:name];

    OFString* telephoneValue;
    if(self.telephone != nil && self.telephone.length > 0)
        telephoneValue = self.telephone;
    else
        telephoneValue = emptyString;

    OFXMLElement *telephone = [OFXMLElement elementWithName: @"Telephone"
                                                stringValue:telephoneValue];
    [element addChild:telephone];

    OFString* officeValue;
    if(self.office != nil && self.office.length > 0)
        officeValue = self.office;
    else
        officeValue = emptyString;

    OFXMLElement *office = [OFXMLElement elementWithName: @"Office"
                                                stringValue:officeValue];
    [element addChild:office];

    OFString* mobileValue;
    if(self.mobile != nil && self.mobile.length > 0)
        mobileValue = self.mobile;
    else
        mobileValue = emptyString;
    
    OFXMLElement *mobile = [OFXMLElement elementWithName: @"Mobile"
                                                stringValue:mobileValue];
    [element addChild:mobile];

	return element;
}

- (OFString*)description
{
    return [OFString stringWithFormat: @"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@", self.name, self.telephone, self.office, self.mobile];
}

@end

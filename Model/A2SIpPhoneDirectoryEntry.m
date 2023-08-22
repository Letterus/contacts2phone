/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "A2SIpPhoneDirectoryEntry.h"

@implementation A2SIpPhoneDirectoryEntry

- (void)dealloc
{
    [_name release];
    [_telephone release];
    [_office release];
    [_mobile release];

    [super dealloc];
}

- (OFXMLElement*)XMLElementBySerializing
{
    OFXMLElement* element = [OFXMLElement elementWithName:@"DirectoryEntry"];
    OFConstantString* emptyString = @"";

    OFXMLElement* name = [OFXMLElement elementWithName:@"Name"
                                           stringValue:self.name];
    [element addChild:name];

    OFString* telephoneValue;
    if (self.telephone != nil)
        telephoneValue = self.telephone;
    else
        telephoneValue = emptyString;

    OFXMLElement* telephone = [OFXMLElement elementWithName:@"Telephone"
                                                stringValue:telephoneValue];
    [element addChild:telephone];

    OFString* officeValue;
    if (self.office != nil)
        officeValue = self.office;
    else
        officeValue = emptyString;

    OFXMLElement* office = [OFXMLElement elementWithName:@"Office"
                                             stringValue:officeValue];
    [element addChild:office];

    OFString* mobileValue;
    if (self.mobile != nil)
        mobileValue = self.mobile;
    else
        mobileValue = emptyString;

    OFXMLElement* mobile = [OFXMLElement elementWithName:@"Mobile"
                                             stringValue:mobileValue];
    [element addChild:mobile];

    return element;
}

- (OFString*)description
{
    return [OFString stringWithFormat:@"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@",
                     self.name, self.telephone, self.office, self.mobile];
}

@end

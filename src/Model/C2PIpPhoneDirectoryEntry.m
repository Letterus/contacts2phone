/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PIpPhoneDirectoryEntry.h"
#import "../Exception/C2PEDSException.h"

@implementation C2PIpPhoneDirectoryEntry

- (instancetype)init
{
	self = [super init];

	_allowedCharsInPhoneNumber =
	    [[OFCharacterSet characterSetWithCharactersInString:@"+0123456789 "] retain];
	_cleanNumberCharsToKeep = [[_allowedCharsInPhoneNumber invertedSet] retain];

	return self;
}

- (void)dealloc
{
	[_name release];
	[_telephone release];
	[_office release];
	[_mobile release];
	[_allowedCharsInPhoneNumber release];
	[_cleanNumberCharsToKeep release];

	[super dealloc];
}

- (instancetype)addNameFromEvolutionContact:(EContact *)econtact
{
	OFString *familyname =
	    [self cleanName:[self stringFromGlib:e_contact_get(econtact, E_CONTACT_FAMILY_NAME)]];
	OFString *givenname =
	    [self cleanName:[self stringFromGlib:e_contact_get(econtact, E_CONTACT_GIVEN_NAME)]];
	OFString *fullname =
	    [self cleanName:[self stringFromGlib:e_contact_get(econtact, E_CONTACT_FULL_NAME)]];

	if ([self isValidNameField:familyname]) {
		if ([self isValidNameField:givenname])
			self.name = [OFString stringWithFormat:@"%@, %@", familyname, givenname];
		else
			self.name = familyname;

	} else if ([self isValidNameField:givenname]) {
		self.name = givenname;
	} else if ([self isValidNameField:fullname]) {
		self.name = fullname;
	} else {
		@throw [C2PEDSException exceptionWithDescription:@"Name fields are empty."];
	}
	return self;
}

- (instancetype)setTelephoneValuesForKeysWithDictionary:(OFDictionary *)keyValueMapping
                                   fromEvolutionContact:(EContact *)econtact
{
	bool gotTelephone = false;

	for (OFString *ownProperty in keyValueMapping) {
		OFArray *eContactProperties = [keyValueMapping objectForKey:ownProperty];
		for (OFNumber *eContactProperty in eContactProperties) {
			if ([self addTelephoneProperty:eContactProperty
			                          from:econtact
			                         toKey:ownProperty])
				gotTelephone = true;
		}
	}

	if (!gotTelephone)
		@throw [C2PEDSException exceptionWithDescription:@"Found no phone number."];

	return self;
}

- (bool)addTelephoneProperty:(OFNumber *)telephoneProperty
                        from:(EContact *)econtact
                       toKey:(OFString *)key
{
	OFString *telephoneNumber =
	    [self stringFromGlib:e_contact_get(econtact, [telephoneProperty intValue])];

	if ([self isValidPhoneField:telephoneNumber]) {
		telephoneNumber = [self cleanPhoneNumber:telephoneNumber];

		if ([telephoneNumber length]) {

			// In case we already got that telephone number as main number: Don't set it
			// again
			if ([key isEqual:@"office"] || [key isEqual:@"mobile"]) {
				if ([telephoneNumber isEqual:self.telephone])
					return true;
			}

			[self setValue:telephoneNumber forKey:key];
			return true;
		}
	}

	return false;
}

- (OFString *)stringFromGlib:(const char *)cString
{
	if (cString == NULL)
		return nil;

	return [OFString stringWithUTF8String:(char *_Nonnull)cString];
}

- (bool)isValidNameField:(OFString *)nameField
{
	if (nameField != nil && [nameField length] != 0)
		return true;

	return false;
}

- (bool)isValidPhoneField:(OFString *)phoneField
{
	if (phoneField != nil && ![phoneField isEqual:@""] && [phoneField length] > 3)
		return true;

	return false;
}

- (OFString *)cleanPhoneNumber:(OFString *)phoneNumber
{
	OFString *cleanPhoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(0)"
	                                                                    withString:@""];
	@autoreleasepool {
		cleanPhoneNumber =
		    [[cleanPhoneNumber componentsSeparatedByCharactersInSet:_cleanNumberCharsToKeep]
		        componentsJoinedByString:@""];
		[cleanPhoneNumber retain];
	}
	[cleanPhoneNumber autorelease];

	return [cleanPhoneNumber stringByDeletingEnclosingWhitespaces];
}

- (OFString *)cleanName:(OFString *)name
{
	OFString *cleanName = [name stringByReplacingOccurrencesOfString:@"'" withString:@""];

	@autoreleasepool {
		cleanName = [cleanName stringByReplacingOccurrencesOfString:@"\"" withString:@""];

		cleanName = [cleanName stringByReplacingOccurrencesOfString:@"‘" withString:@""];

		cleanName = [cleanName stringByReplacingOccurrencesOfString:@"&" withString:@"+"];

		[cleanName retain];
	}
	[cleanName autorelease];

	return [cleanName stringByDeletingEnclosingWhitespaces];
}

- (OFXMLElement *)XMLElementBySerializing
{
	OFXMLElement *element = [OFXMLElement elementWithName:@"DirectoryEntry"];
	OFConstantString *emptyString = @"";

	OFXMLElement *name = [OFXMLElement elementWithName:@"Name" stringValue:self.name];
	[element addChild:name];

	OFString *telephoneValue;
	if (self.telephone != nil)
		telephoneValue = self.telephone;
	else
		telephoneValue = emptyString;

	OFXMLElement *telephone = [OFXMLElement elementWithName:@"Telephone"
	                                            stringValue:telephoneValue];
	[element addChild:telephone];

	OFString *officeValue;
	if (self.office != nil)
		officeValue = self.office;
	else
		officeValue = emptyString;

	OFXMLElement *office = [OFXMLElement elementWithName:@"Office" stringValue:officeValue];
	[element addChild:office];

	OFString *mobileValue;
	if (self.mobile != nil)
		mobileValue = self.mobile;
	else
		mobileValue = emptyString;

	OFXMLElement *mobile = [OFXMLElement elementWithName:@"Mobile" stringValue:mobileValue];
	[element addChild:mobile];

	return element;
}

- (OFString *)description
{
	return
	    [OFString stringWithFormat:@"Directory Entry: Name=%@ Telephone=%@ Office=%@ Mobile=%@",
	              self.name, self.telephone, self.office, self.mobile];
}

@end

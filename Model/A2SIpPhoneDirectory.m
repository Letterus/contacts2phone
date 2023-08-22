/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "A2SIpPhoneDirectory.h"
#import "../Exception/A2SEDSException.h"
#import "A2SIpPhoneDirectoryEntry.h"

const OFStringEncoding _encoding = OFStringEncodingUTF8;

@implementation A2SIpPhoneDirectory

#pragma mark - Init methods

- (instancetype)init
{
	self = [super init];

	_entries = [[OFMutableArray alloc] init];

	return self;
}

- (void)dealloc
{
	[_entries release];

	[super dealloc];
}

#pragma mark - Import methods

- (void)importFromEvolutionBook:(GSList *)evolutionContacts
{
	for (GSList *element = evolutionContacts; element != NULL;
	     element = element->next) {
		EContact *econtact = element->data;
		bool gotPhoneNumber = false;

		A2SIpPhoneDirectoryEntry *newEntry =
		    [[A2SIpPhoneDirectoryEntry alloc] init];

		@try {
			[self addNameToEntry:newEntry
			    fromEvolutionContact:econtact];
			if ([self addOfficeToEntry:newEntry
			        fromEvolutionContact:econtact])
				gotPhoneNumber = true;

			if ([self addMobileToEntry:newEntry
			        fromEvolutionContact:econtact])
				gotPhoneNumber = true;

			if ([self addTelephoneToEntry:newEntry
			         fromEvolutionContact:econtact])
				gotPhoneNumber = true;

			if (!gotPhoneNumber)
				@throw [A2SEDSException
				    exceptionWithDescription:
				        @"Found no phone number."];

		} @catch (id e) {
			[newEntry release];
			continue;
		}

		[self.entries addObject:newEntry];

		OFLog(@"Added to Directory Entry: %@", [newEntry description]);

		[newEntry release];
	}
}

#pragma mark - Private import helper methods

- (void)addNameToEntry:(A2SIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(EContact *)econtact
{
	char *familyname =
	    (char *)e_contact_get(econtact, E_CONTACT_FAMILY_NAME);
	char *givenname = (char *)e_contact_get(econtact, E_CONTACT_GIVEN_NAME);
	char *fullname = (char *)e_contact_get(econtact, E_CONTACT_FULL_NAME);

	if ([self isValidNameField:familyname]) {
		if ([self isValidNameField:givenname])
			entry.name = [OFString
			    stringWithFormat:@"%s, %s", familyname, givenname];
		else
			entry.name = [OFString stringWithCString:familyname
			                                encoding:_encoding];

	} else if ([self isValidNameField:givenname]) {
		entry.name = [OFString stringWithCString:givenname
		                                encoding:_encoding];
	} else if ([self isValidNameField:fullname]) {
		entry.name = [OFString stringWithCString:fullname
		                                encoding:_encoding];
	} else {
		@throw [A2SEDSException
		    exceptionWithDescription:@"Name fields are empty."];
	}
}

- (bool)addTelephoneToEntry:(A2SIpPhoneDirectoryEntry *)entry
       fromEvolutionContact:(EContact *)econtact
{
	OFMutableString *primary =
	    [self getEContactField:E_CONTACT_PHONE_PRIMARY
	              fromEContact:econtact];
	OFMutableString *home = [self getEContactField:E_CONTACT_PHONE_HOME
	                                  fromEContact:econtact];
	OFMutableString *home2 = [self getEContactField:E_CONTACT_PHONE_HOME_2
	                                   fromEContact:econtact];
	OFMutableString *other = [self getEContactField:E_CONTACT_PHONE_OTHER
	                                   fromEContact:econtact];

	if ([self isValidPhoneField:primary]) {
		primary = [self cleanPhoneNumber:primary];
		if (![primary isEqual:entry.office] &&
		    ![primary isEqual:entry.mobile]) {
			entry.telephone = primary;
			return true;
		}
	}

	if ([self isValidPhoneField:home]) {
		entry.telephone = [self cleanPhoneNumber:home];
		return true;

	} else if ([self isValidPhoneField:home2]) {
		entry.telephone = [self cleanPhoneNumber:home2];
		return true;

	} else if ([self isValidPhoneField:other]) {
		entry.telephone = [self cleanPhoneNumber:other];
		return true;
	}

	return false;
}

- (bool)addOfficeToEntry:(A2SIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(EContact *)econtact
{
	OFMutableString *business =
	    [self getEContactField:E_CONTACT_PHONE_BUSINESS
	              fromEContact:econtact];
	OFMutableString *business2 =
	    [self getEContactField:E_CONTACT_PHONE_BUSINESS_2
	              fromEContact:econtact];
	OFMutableString *company =
	    [self getEContactField:E_CONTACT_PHONE_COMPANY
	              fromEContact:econtact];

	if ([self isValidPhoneField:business]) {
		entry.office = [self cleanPhoneNumber:business];
		return true;

	} else if ([self isValidPhoneField:business2]) {
		entry.office = [self cleanPhoneNumber:business2];
		return true;

	} else if ([self isValidPhoneField:company]) {
		entry.office = [self cleanPhoneNumber:company];
		return true;
	}

	return false;
}

- (bool)addMobileToEntry:(A2SIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(EContact *)econtact
{
	OFMutableString *mobile = [self getEContactField:E_CONTACT_PHONE_MOBILE
	                                    fromEContact:econtact];
	OFMutableString *pager = [self getEContactField:E_CONTACT_PHONE_PAGER
	                                   fromEContact:econtact];
	OFMutableString *car = [self getEContactField:E_CONTACT_PHONE_CAR
	                                 fromEContact:econtact];

	if ([self isValidPhoneField:mobile]) {
		entry.mobile = [self cleanPhoneNumber:mobile];
		return true;

	} else if ([self isValidPhoneField:pager]) {
		entry.mobile = [self cleanPhoneNumber:pager];
		return true;

	} else if ([self isValidPhoneField:car]) {
		entry.mobile = [self cleanPhoneNumber:car];
		return true;
	}

	return false;
}

- (OFMutableString *)getEContactField:(EContactField)field
                         fromEContact:(EContact *)econtact
{
	if (e_contact_get(econtact, field) != NULL)
		return [OFMutableString
		    stringWithCString:(char *)e_contact_get(econtact, field)
		             encoding:_encoding];

	return nil;
}

- (bool)isValidNameField:(char *)nameField
{
	if (nameField != NULL && strcmp(nameField, "") != 0)
		return true;

	return false;
}

- (bool)isValidPhoneField:(OFMutableString *)phoneField
{
	if (phoneField != nil && ![phoneField isEqual:@""] &&
	    [phoneField length] > 3)
		return true;

	return false;
}

- (OFMutableString *)cleanPhoneNumber:(OFMutableString *)phoneNumber
{
	[phoneNumber replaceOccurrencesOfString:@"(0)" withString:@""];
	[phoneNumber replaceOccurrencesOfString:@"(" withString:@""];
	[phoneNumber replaceOccurrencesOfString:@")" withString:@""];
	[phoneNumber replaceOccurrencesOfString:@"/" withString:@" "];
	[phoneNumber replaceOccurrencesOfString:@"-" withString:@" "];
	[phoneNumber replaceOccurrencesOfString:@"   " withString:@" "];
	[phoneNumber replaceOccurrencesOfString:@"  " withString:@" "];
	[phoneNumber deleteEnclosingWhitespaces];
	return phoneNumber;
}

#pragma mark - Serializers

- (OFString *)stringBySerializing
{
	void *pool;
	OFXMLElement *element;
	OFString *ret;

	pool = objc_autoreleasePoolPush();
	element = self.XMLElementBySerializing;

	ret = [@"<?xml version='1.0' encoding='UTF-8'?>\n"
	    stringByAppendingString:[element XMLStringWithIndentation:2]];

	[ret retain];

	objc_autoreleasePoolPop(pool);

	return [ret autorelease];
}

- (OFXMLElement *)XMLElementBySerializing
{
	void *pool = objc_autoreleasePoolPush();

	OFXMLElement *element =
	    [OFXMLElement elementWithName:@"IPPhoneDirectory"];

	for (A2SIpPhoneDirectoryEntry *entry in self.entries) {
		[element addChild:entry.XMLElementBySerializing];
	}

	[element retain];

	objc_autoreleasePoolPop(pool);

	return [element autorelease];
}

@end

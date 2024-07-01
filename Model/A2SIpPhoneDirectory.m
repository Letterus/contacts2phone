/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
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
		EContact *gecontact = element->data;
		OGEContact *econtact = [OGEContact withGObject:gecontact];
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

		} @catch (A2SEDSException *e) {
			[newEntry release];
			continue;
		}

		[self.entries addObject:newEntry];

		OFLog(@"Added to Directory Entry: %@", [newEntry description]);

		[newEntry release];
		[econtact release];
	}
}

#pragma mark - Private import helper methods

- (OFMutableString *)stringFromPointer:(gpointer)gpointer
{
	OFMutableString *returnValue = ((gpointer != NULL)
	        ? [OFMutableString
	              stringWithUTF8StringNoCopy:(char *_Nonnull)gpointer
	                            freeWhenDone:false]
	        : nil);

	return returnValue;
}

- (void)addNameToEntry:(A2SIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(OGEContact *)econtact
{
	OFMutableString *familyname =
	    [self stringFromPointer:[econtact get:E_CONTACT_FAMILY_NAME]];
	OFMutableString *givenname =
	    [self stringFromPointer:[econtact get:E_CONTACT_GIVEN_NAME]];
	OFMutableString *fullname =
	    [self stringFromPointer:[econtact get:E_CONTACT_FULL_NAME]];

	if ([self isValidNameField:familyname]) {
		if ([self isValidNameField:givenname])
			entry.name = [OFString
			    stringWithFormat:@"%@, %@", familyname, givenname];
		else
			entry.name = familyname;

	} else if ([self isValidNameField:givenname]) {
		entry.name = givenname;
	} else if ([self isValidNameField:fullname]) {
		entry.name = fullname;
	} else {
		@throw [A2SEDSException
		    exceptionWithDescription:@"Name fields are empty."];
	}
}

- (bool)addTelephoneToEntry:(A2SIpPhoneDirectoryEntry *)entry
       fromEvolutionContact:(OGEContact *)econtact
{
	OFMutableString *primary =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_PRIMARY]];
	OFMutableString *home =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_HOME]];
	OFMutableString *home2 =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_HOME_2]];
	OFMutableString *other =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_OTHER]];

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
    fromEvolutionContact:(OGEContact *)econtact
{
	OFMutableString *business =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_BUSINESS]];
	OFMutableString *business2 =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_BUSINESS_2]];
	OFMutableString *company =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_COMPANY]];

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
    fromEvolutionContact:(OGEContact *)econtact
{
	OFMutableString *mobile =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_MOBILE]];
	OFMutableString *pager =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_PAGER]];
	OFMutableString *car =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_CAR]];

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

- (bool)isValidNameField:(OFString *)nameField
{
	if (nameField != nil && [nameField length] != 0)
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

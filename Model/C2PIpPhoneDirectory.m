/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PIpPhoneDirectory.h"
#import "../Exception/C2PEDSException.h"
#import "C2PIpPhoneDirectoryEntry.h"

const OFStringEncoding _encoding = OFStringEncodingUTF8;

@implementation C2PIpPhoneDirectory

#pragma mark - Init methods

- (instancetype)init
{
	self = [super init];

	_entries = [[OFMutableArray alloc] init];
	_allowedCharsInPhoneNumber =
	    [OFCharacterSet characterSetWithCharactersInString:@"+0123456789 "];
	_cleanNumberCharsToKeep = [_allowedCharsInPhoneNumber invertedSet];

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
		@autoreleasepool {
			EContact *gecontact = element->data;
			OGEContact *econtact =
			    [OGEContact withGObject:gecontact];
			bool gotPhoneNumber = false;

			C2PIpPhoneDirectoryEntry *newEntry =
			    [[C2PIpPhoneDirectoryEntry alloc] init];

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
					@throw [C2PEDSException
					    exceptionWithDescription:
					        @"Found no phone number."];

			} @catch (C2PEDSException *e) {
				[newEntry release];
				continue;
			}

			[self.entries addObject:newEntry];

			OFLog(@"Added to Directory Entry: %@",
			    [newEntry description]);

			[newEntry release];
		}
	}
}

#pragma mark - Private import helper methods

- (OFString *)stringFromPointer:(gpointer)gpointer
{
	OFString *returnValue = ((gpointer != NULL)
	        ? [OFString stringWithUTF8StringNoCopy:(char *_Nonnull)gpointer
	                                  freeWhenDone:false]
	        : nil);

	return returnValue;
}

- (void)addNameToEntry:(C2PIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(OGEContact *)econtact
{
	OFString *familyname =
	    [self stringFromPointer:[econtact get:E_CONTACT_FAMILY_NAME]];
	OFString *givenname =
	    [self stringFromPointer:[econtact get:E_CONTACT_GIVEN_NAME]];
	OFString *fullname =
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
		@throw [C2PEDSException
		    exceptionWithDescription:@"Name fields are empty."];
	}
}

- (bool)addTelephoneToEntry:(C2PIpPhoneDirectoryEntry *)entry
       fromEvolutionContact:(OGEContact *)econtact
{
	OFString *primary =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_PRIMARY]];
	OFString *home =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_HOME]];
	OFString *home2 =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_HOME_2]];
	OFString *other =
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

- (bool)addOfficeToEntry:(C2PIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(OGEContact *)econtact
{
	OFString *business =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_BUSINESS]];
	OFString *business2 =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_BUSINESS_2]];
	OFString *company =
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

- (bool)addMobileToEntry:(C2PIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(OGEContact *)econtact
{
	OFString *mobile =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_MOBILE]];
	OFString *pager =
	    [self stringFromPointer:[econtact get:E_CONTACT_PHONE_PAGER]];
	OFString *car =
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

- (bool)isValidPhoneField:(OFString *)phoneField
{
	if (phoneField != nil && ![phoneField isEqual:@""] &&
	    [phoneField length] > 3)
		return true;

	return false;
}

- (OFString *)cleanPhoneNumber:(OFString *)phoneNumber
{
	OFString *cleanPhoneNumber =
	    [phoneNumber stringByReplacingOccurrencesOfString:@"(0)"
	                                           withString:@""];
	@autoreleasepool {
		cleanPhoneNumber = [[cleanPhoneNumber
		    componentsSeparatedByCharactersInSet:
		        _cleanNumberCharsToKeep] componentsJoinedByString:@""];
		[cleanPhoneNumber retain];
	}
	[cleanPhoneNumber autorelease];

	return [cleanPhoneNumber stringByDeletingEnclosingWhitespaces];
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

	for (C2PIpPhoneDirectoryEntry *entry in self.entries) {
		[element addChild:entry.XMLElementBySerializing];
	}

	[element retain];

	objc_autoreleasePoolPop(pool);

	return [element autorelease];
}

@end

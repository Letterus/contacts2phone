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
#include <peel/EBook/EBook.h>
#include <peel/EBookContacts/EBookContacts.h>
#include <peel/GLib/functions.h>

using namespace peel;

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

- (void)importFromEvolutionBook:(UniquePtr<GLib::SList>)evolutionContacts
{
	GLib::SList::foreach (evolutionContacts, [dir = self] (gpointer data)
	{
		auto econtact = reinterpret_cast<EBookContacts::Contact *> (data);
		@autoreleasepool {
			bool gotPhoneNumber = false;

			C2PIpPhoneDirectoryEntry *newEntry =
			    [[C2PIpPhoneDirectoryEntry alloc] init];

			@try {
				[dir addNameToEntry:newEntry
				    fromEvolutionContact:econtact];
				if ([dir addOfficeToEntry:newEntry
				        fromEvolutionContact:econtact])
					gotPhoneNumber = true;

				if ([dir addMobileToEntry:newEntry
				        fromEvolutionContact:econtact])
					gotPhoneNumber = true;

				if ([dir addTelephoneToEntry:newEntry
				         fromEvolutionContact:econtact])
					gotPhoneNumber = true;

				if (!gotPhoneNumber)
					@throw [C2PEDSException
					    exceptionWithDescription:
					        @"Found no phone number."];

			} @catch (C2PEDSException *e) {
				[newEntry release];
				return;
			}

			[dir.entries addObject:newEntry];

//			OFLog(@"Added to Directory Entry: %@",
//			    [newEntry description]);

			[newEntry release];
		}
	});

	GLib::SList::free_full (std::move (evolutionContacts).release_ref (), g_object_unref);
}

- (OFString *)stringFromPeel:(peel::String)peelString
{
	const char* cString = peelString.c_str();
	if(cString == NULL)
		return nil;

	return [OFString stringWithUTF8String:(char * _Nonnull)cString];
}

- (void)addNameToEntry:(C2PIpPhoneDirectoryEntry *)entry
    fromEvolutionContact:(EBookContacts::Contact *)econtact
{
	OFString *familyname =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_family_name ())];
	OFString *givenname =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_given_name ())];
	OFString *fullname =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_full_name ())];

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
       fromEvolutionContact:(EBookContacts::Contact *)econtact
{
	OFString *primary =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_primary_phone ())];
	OFString *home =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_home_phone ())];
	OFString *home2 =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_home_phone_2 ())];
	OFString *other =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_other_phone ())];

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
    fromEvolutionContact:(EBookContacts::Contact *)econtact
{
	OFString *business =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_business_phone ())];
	OFString *business2 =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_business_phone_2 ())];
	OFString *company =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_company_phone ())];

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
    fromEvolutionContact:(EBookContacts::Contact *)econtact
{
	OFString *mobile =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_mobile_phone ())];
	OFString *pager =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_pager ())];
	OFString *car =
	    [self stringFromPeel:econtact->get_property (EBookContacts::Contact::prop_car_phone ())];

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

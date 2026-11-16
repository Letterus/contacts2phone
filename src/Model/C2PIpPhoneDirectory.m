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
#include <libebook-contacts/libebook-contacts.h>
#include <libebook/libebook.h>

@implementation C2PIpPhoneDirectory

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
	GSList *entry;
	for (entry = evolutionContacts; entry; entry = entry->next) {
		EContact *econtact = E_CONTACT(entry->data);
		@autoreleasepool {
			C2PIpPhoneDirectoryEntry *newEntry =
			    [[C2PIpPhoneDirectoryEntry alloc] init];

			@try {
				[newEntry addNameFromEvolutionContact:econtact];

				OFDictionary *keyValueMapping = @{
					@"telephone" : @[
						@(E_CONTACT_PHONE_PRIMARY), @(E_CONTACT_PHONE_HOME),
						@(E_CONTACT_PHONE_HOME_2), @(E_CONTACT_PHONE_OTHER)
					],
					@"office" : @[
						@(E_CONTACT_PHONE_BUSINESS),
						@(E_CONTACT_PHONE_BUSINESS_2),
						@(E_CONTACT_PHONE_COMPANY)
					],
					@"mobile" : @[
						@(E_CONTACT_PHONE_MOBILE), @(E_CONTACT_PHONE_PAGER),
						@(E_CONTACT_PHONE_CAR)
					]
				};

				[newEntry setTelephoneValuesForKeysWithDictionary:keyValueMapping
				                             fromEvolutionContact:econtact];

			// TODO: Make new C2PInvalidEntryException
			} @catch (C2PEDSException *e) {
				[newEntry release];
				continue;
			}

			[self.entries addObject:newEntry];

			// OFLog(@"Added to Directory Entry: %@", [newEntry description]);

			[newEntry release];
		}
	}
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

	OFXMLElement *element = [OFXMLElement elementWithName:@"IPPhoneDirectory"];

	for (C2PIpPhoneDirectoryEntry *entry in self.entries) {
		[element addChild:entry.XMLElementBySerializing];
	}

	[element retain];

	objc_autoreleasePoolPop(pool);

	return [element autorelease];
}

@end

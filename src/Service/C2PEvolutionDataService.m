/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PEvolutionDataService.h"
#import "../Exception/C2PEDSException.h"

@implementation C2PEvolutionDataService

- (void)dealloc
{
	[_registry release];
	[_defaultAddressbookSource release];
	[_client release];
	g_slist_free_full(_contacts, g_object_unref);

	[super dealloc];
}

#pragma mark - Property getters

- (OGESourceRegistry *)registry
{
	if (_registry != nil)
		return _registry;

	_registry = [self retrieveRegistry];
	[_registry retain];

	return _registry;
}

- (OGESource *)defaultAddressbookSource
{
	if (_defaultAddressbookSource != nil)
		return _defaultAddressbookSource;

	_defaultAddressbookSource = self.registry.refDefaultAddressBook;
	[_defaultAddressbookSource retain];

	return _defaultAddressbookSource;
}

- (OGListStore *)addressbookSources
{
	OGListStore *addressBookListStore = [[[OGListStore alloc]
	    initWithItemType:e_source_get_type()] autorelease];

	GList *sourceList = [self.registry listSources:@"Address Book"];

	for (GList *element = sourceList; element != NULL;
	     element = element->next) {
		ESource *source = element->data;
		// OFLog(@"Addressbook name %s, UUID: %s",
		//     e_source_get_display_name(source),
		//     e_source_get_uid(source));
		[addressBookListStore append:source];
		g_object_unref(source);
	}
	g_list_free(sourceList);

	return addressBookListStore;
}

- (OGEBookClient *)client
{
	if (_client != nil)
		return _client;

	_client = [self retrieveEBookClient];
	[_client retain];

	return _client;
}

- (GSList *)contacts
{
	if (_contacts != NULL)
		return _contacts;

	_contacts = [self retrieveContacts];
	return _contacts;
}

#pragma mark - Private methods - fetching data from EDS

- (OGESourceRegistry *)retrieveRegistry
{
	OGESourceRegistry *registry;
	OGCancellable *cble = [[[OGCancellable alloc] init] autorelease];

	@try {
		registry =
		    [[OGESourceRegistry alloc] initWithCancellableSync:cble];
	} @catch (id e) {
		[registry release];
		@throw e;
	}

	return [registry autorelease];
}

- (OGEBookClient *)retrieveEBookClient
{
	OGESource *addressbook = self.defaultAddressbookSource;
	OGEBookClient *client;
	OGCancellable *cble = [[[OGCancellable alloc] init] autorelease];

	client =
	    (OGEBookClient *)[OGEBookClient connectSyncWithSource:addressbook
	                                  waitForConnectedSeconds:1
	                                              cancellable:cble];

	return client;
}

- (GSList *)retrieveContacts
{
	OGEBookClient *client = self.client;

	GSList *contactsList = NULL;
	OFString *sexp = @"";
	OGCancellable *cble = [[[OGCancellable alloc] init] autorelease];

	[client contactsSyncWithSexp:sexp
	                 outContacts:&contactsList
	                 cancellable:cble];

	if (contactsList == NULL)
		@throw [C2PDescriptionException
		    exceptionWithDescription:
		        [OFString
		            stringWithFormat:@"Could not get any contacts "
		                             @"from addressbook: %@",
		            self.defaultAddressbookSource.displayName]];

	return contactsList;
}

@end

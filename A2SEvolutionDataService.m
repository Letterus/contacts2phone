/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "A2SEvolutionDataService.h"

@implementation A2SEvolutionDataService

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
	if (_registry != NULL)
		return _registry;

	_registry = [self retrieveRegistry];
	return _registry;
}

- (OGESource *)defaultAddressbookSource
{
	if (_defaultAddressbookSource != NULL)
		return _defaultAddressbookSource;

	_defaultAddressbookSource = [self retrieveDefaultAddressbookSource];
	return _defaultAddressbookSource;
}

- (OGEBookClient *)client
{
	if (_client != NULL)
		return _client;

	_client = [self retrieveEBookClient];
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
	GCancellable *cble = g_cancellable_new();
	OGESourceRegistry *registry;

	@try {
		registry = [[OGESourceRegistry alloc] initSync:cble];
	} @catch (id e) {
		[registry release];
		@throw e;
	}

	return registry;
}

- (OGESource *)retrieveDefaultAddressbookSource
{
	OGESourceRegistry *registry = self.registry;
	OGESource *addressbook;

	/*
	GList* sources = e_source_registry_list_sources(registry,
	E_SOURCE_EXTENSION_ADDRESS_BOOK); GList* sourceElement;
	for(sourceElement = sources; sourceElement; sourceElement =
	sourceElement->next) { addressbook = sourceElement->data; OFLog(@"%s",
	e_source_get_display_name(addressbook));
	}
	*/

	addressbook = [self.registry refDefaultAddressBook];

	return addressbook;
}

- (OGEBookClient *)retrieveEBookClient
{
	OGESource *addressbook = self.defaultAddressbookSource;
	OGEBookClient *client;

	GCancellable *cble = g_cancellable_new();
	GError *err = NULL;

	@try {
		client = [OGEBookClient connectSyncWithSource:addressbook
		                      waitForConnectedSeconds:5
		                                  cancellable:cble];
	} @catch (id e) {
		[client release];
		@throw e;
	}

	return client;
}

- (GSList *)retrieveContacts
{
	OGEBookClient *client = self.client;

	GSList *contactsList = NULL;
	OFString *sexp = @"";
	GCancellable *cble = g_cancellable_new();

	@try {
		[client contactsSyncWithSexp:sexp
		                 outContacts:&contactsList
		                 cancellable:cble];

		if (contactsList == NULL)
			@throw [A2SDescriptionException
			    exceptionWithDescription:
			        [OFString stringWithFormat:
			                      @"Could not get any contacts "
			                      @"from addressbook: %s",
			                  [self.defaultAddressbookSource
			                          displayName]]];

	} @catch (id e) {
		[client release];
		@throw e;
	}

	return contactsList;
}

@end

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
	if (_registry != nil)
		return _registry;

	_registry = [self retrieveRegistry];
	return _registry;
}

- (OGESource *)defaultAddressbookSource
{
	if (_defaultAddressbookSource != nil)
		return _defaultAddressbookSource;

	_defaultAddressbookSource = self.registry.refDefaultAddressBook;
	return _defaultAddressbookSource;
}

- (OGEBookClient *)client
{
	if (_client != nil)
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

- (OGEBookClient *)retrieveEBookClient
{
	OGESource *addressbook = self.defaultAddressbookSource;
	OGEBookClient *client;

	GCancellable *cble = g_cancellable_new();

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

	[client contactsSyncWithSexp:sexp
	                 outContacts:&contactsList
	                 cancellable:cble];

	if (contactsList == NULL)
		@throw [A2SDescriptionException
		    exceptionWithDescription:
		        [OFString
		            stringWithFormat:@"Could not get any contacts "
		                             @"from addressbook: %s",
		            self.defaultAddressbookSource.displayName]];

	return contactsList;
}

@end

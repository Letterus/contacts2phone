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
	OGListStore *addressBookListStore = [OGListStore listStoreWithItemType:e_source_get_type()];

	GList *sourceList = [self.registry listSourcesWithExtensionName:@"Address Book"];

	for (GList *element = sourceList; element != NULL; element = element->next) {
		ESource *source = element->data;
		// OFLog(@"Addressbook name %s, UUID: %s",
		//     e_source_get_display_name(source),
		//     e_source_get_uid(source));
		[addressBookListStore appendWithItem:source];
		g_object_unref(source);
	}
	g_list_free(sourceList);

	return addressBookListStore;
}

#pragma mark - Private methods - fetching data from EDS

- (OGESourceRegistry *)retrieveRegistry
{
	OGESourceRegistry *registry;

	@try {
		registry = [OGESourceRegistry sourceRegistrySyncWithCancellable:nil];
	} @catch (id e) {
		[registry release];
		@throw e;
	}

	return [registry autorelease];
}

- (GSList *)retrieveContactsFromAddressbookSource:(OGESource *)addressbook
{
	OGEBookClient *client;

	client = (OGEBookClient *)[OGEBookClient connectSyncWithSource:addressbook
	                                       waitForConnectedSeconds:1
	                                                   cancellable:nil];

	GSList *contactsList = NULL;
	OFString *sexp = @"";

	[client contactsSyncWithSexp:sexp outContacts:&contactsList cancellable:nil];

	if (contactsList == NULL)
		@throw [C2PDescriptionException
		    exceptionWithDescription:[OFString
		                                 stringWithFormat:@"Could not get any contacts "
		                                                  @"from addressbook: %@",
		                                 self.defaultAddressbookSource.displayName]];

	return contactsList;
}

@end

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
#include <glib-object.h>
#include <glib.h>

@implementation C2PEvolutionDataService

/**
 *
 * @return A `GList` of addressbook sources as returned by `e_source_registry_list_sources`.
 * Ownership is transferred to the caller. The list needs to be freed with `g_list_free_full` f.e.
 */
- (GList *)addressbookSources
{
	GError *error = NULL;
	ESourceRegistry *registry = e_source_registry_new_sync(NULL, &error);

	if (error != NULL) {
		@throw [C2PEDSException
		    exceptionWithDescription:
		        [OFString stringWithFormat:@"Failed to create a source registry: %s\n",
		                  error->message]];
	}

	return e_source_registry_list_sources(registry, E_SOURCE_EXTENSION_ADDRESS_BOOK);
}

/**
 *
 * @return A `GSList` of `EContact` as returned by `e_book_client_get_contacts_sync`.
 * Ownership is transferred to the caller. The list needs to be freed with `g_slist_free_full` f.e.
 */
- (GSList *)contactsFromAddressbookSource:(ESource *)addressbook
{
	GSList *contacts;
	GError *error = NULL;

	EBookClient *client = E_BOOK_CLIENT(e_book_client_connect_sync(
	    addressbook, /* timeout */ 1, /* cancellable */ NULL, &error));

	if (error != NULL) {
		@throw [C2PEDSException
		    exceptionWithDescription:
		        [OFString
		            stringWithFormat:@"Failed to connect to EBook: %s\n", error->message]];
	}

	e_book_client_get_contacts_sync(
	    client, /* sexp */ "", &contacts, /* cancellable */ NULL, &error);

	if (error != NULL) {
		@throw [C2PEDSException
		    exceptionWithDescription:[OFString
		                                 stringWithFormat:@"Failed to get contacts: %s\n",
		                                 error->message]];
	}

	return contacts;
}

@end
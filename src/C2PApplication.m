/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

// #import "Controller/GTK/C2PGTKAppController.h"
#import "Model/C2PIpPhoneDirectory.h"
#import "Service/C2PEvolutionDataService.h"
#import <ObjFW/ObjFW.h>

@interface C2PApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(C2PApplication)

@implementation C2PApplication
- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	C2PEvolutionDataService *evolutionService = [[C2PEvolutionDataService alloc] init];

	GList *entry, *addressbookList = [evolutionService addressbookSources];
	ESource *selectedAddressBook = NULL;

	for (entry = addressbookList; entry; entry = entry->next) {
		ESource *addressbook = E_SOURCE(entry->data);

		//OFLog(@"Address book name: %s", e_source_get_display_name(addressbook));

		if (strcmp(e_source_get_display_name(addressbook), "Dienst Gemeinsam") == 0) {
			selectedAddressBook = addressbook;
			break;
		}
	}

	if (selectedAddressBook == NULL)
		[OFApplication terminateWithStatus:EXIT_FAILURE];

	C2PIpPhoneDirectory *phoneDirectory = [[C2PIpPhoneDirectory alloc] init];
	GSList *contacts = [evolutionService contactsFromAddressbookSource:selectedAddressBook];

	[phoneDirectory importFromEvolutionBook:contacts];
	[OFStdOut writeString:phoneDirectory.stringBySerializing];

	g_slist_free_full(contacts, g_object_unref);
	[phoneDirectory release];
	[evolutionService release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}

@end

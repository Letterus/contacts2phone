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

static void
c2p_usage()
{
	[OFStdOut writeLine:@"Usage:"];
	[OFStdOut
	    writeFormat:@"%@ [-l|--list]\n", [OFApplication programName]];
	[OFStdOut writeLine:@"\t[-s \"Addressbook Display Name\"|--select=\"Addressbook Display Name\""];
	[OFStdOut writeLine:@"\t-u http://host|--upload-to-host=http://host"];
	[OFStdOut writeLine:@"\t-n username|--username=username]\n"];
}

static void
c2p_list(C2PEvolutionDataService *evolutionService)
{
	GList *entry, *addressbookList = [evolutionService addressbookSources];

	[OFStdOut writeLine:@"For option -s, --select choose one of the following addressbooks:"];
	for (entry = addressbookList; entry; entry = entry->next) {
		ESource *addressbook = E_SOURCE(entry->data);
		[OFStdOut writeFormat:@"\t- %s\n", e_source_get_display_name(addressbook)];
	}
}

static void
c2p_select(C2PEvolutionDataService *evolutionService, OFString *addressbookDisplayName)
{
	GList *entry, *addressbookList = [evolutionService addressbookSources];
	ESource *selectedAddressBook = NULL;

	for (entry = addressbookList; entry; entry = entry->next) {
		ESource *addressbook = E_SOURCE(entry->data);

		if (strcmp(e_source_get_display_name(addressbook),
		        addressbookDisplayName.UTF8String) == 0) {
			selectedAddressBook = addressbook;
			break;
		}
	}

	if (selectedAddressBook == NULL) {
		// TODO: Throw exception
		OFLog(@"Addressbook with name \"%@\" not found.", addressbookDisplayName);
		[OFApplication terminateWithStatus:EXIT_FAILURE];
	}

	C2PIpPhoneDirectory *phoneDirectory = [[C2PIpPhoneDirectory alloc] init];
	GSList *contacts = [evolutionService contactsFromAddressbookSource:selectedAddressBook];

	[phoneDirectory importFromEvolutionBook:contacts];
	[OFStdOut writeString:phoneDirectory.stringBySerializing];

	g_slist_free_full(contacts, g_object_unref);
	[phoneDirectory release];
}

@implementation C2PApplication
- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	OFString *displayName, *uploadURI, *userName;
	const OFOptionsParserOption options[] = {{'l', @"list", 0, NULL, NULL},
	    {'s', @"select", 1, NULL, &displayName}, {'u', @"upload-to-host", 1, NULL, &uploadURI},
	    {'n', @"username", 1, NULL, &userName}, {'h', @"help", 0, NULL, NULL},
	    {'\0', @"version", 0, NULL, NULL}, {'\0', nil, 0, NULL, NULL}};

	OFUnichar option;
	OFOptionsParser *optionsParser;
	OFArray OF_GENERIC(OFString *) * remainingArguments;

	C2PEvolutionDataService *evolutionService = [[C2PEvolutionDataService alloc] init];

	optionsParser = [OFOptionsParser parserWithOptions:options];
	remainingArguments = optionsParser.remainingArguments;
	while ((option = [optionsParser nextOption]) != '\0') {
		switch (option) {
		case 'l':
			c2p_list(evolutionService);
			break;
		case 's':
			c2p_select(evolutionService, displayName);
			break;
		default:
		case 'h':
			c2p_usage();
			break;
		}
	}

	[evolutionService release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}

@end

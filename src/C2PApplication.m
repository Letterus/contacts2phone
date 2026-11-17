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

static void
c2p_usage()
{
	[OFStdOut writeLine:@"Usage:"];
	[OFStdOut writeFormat:@"%@ [-l|--list]\n", [OFApplication programName]];
	[OFStdOut
	    writeLine:@"\t[-s \"Addressbook Display Name\"|--select=\"Addressbook Display Name\""];
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

@interface C2PApplication: OFObject <OFApplicationDelegate>

@property (nonatomic, retain) OFString *selectedDisplayName;
@property (nonatomic, retain) C2PIpPhoneDirectory *phoneDirectory;
@property (nonatomic, retain) OFIRI *phoneBaseIRI;
@property (nonatomic, retain) OFString *username;

- (C2PIpPhoneDirectory *)phoneDirectoryForBookWithDisplayName:(OFString *)displayName
                                     fromEvolutionDataService:
                                         (C2PEvolutionDataService *)evolutionService;

- (void)upload;
- (void)applicationDidFinishLaunching:(OFNotification *)notification;

@end

OF_APPLICATION_DELEGATE(C2PApplication)

@implementation C2PApplication

- (instancetype)init
{
	self = [super init];

	_selectedDisplayName = nil;
	_phoneDirectory = nil;
	_phoneBaseIRI = nil;
	_username = nil;

	return self;
}

- (void)dealloc
{
	[_selectedDisplayName release];
	[_phoneDirectory release];
	[_phoneBaseIRI release];
	[_username release];

	[super dealloc];
}

- (C2PIpPhoneDirectory *)phoneDirectoryForBookWithDisplayName:(OFString *)displayName
                                     fromEvolutionDataService:
                                         (C2PEvolutionDataService *)evolutionService
{
	GList *entry, *addressbookList = [evolutionService addressbookSources];
	ESource *selectedAddressBook = NULL;

	for (entry = addressbookList; entry; entry = entry->next) {
		ESource *addressbook = E_SOURCE(entry->data);

		if (strcmp(e_source_get_display_name(addressbook), displayName.UTF8String) == 0) {
			selectedAddressBook = addressbook;
			break;
		}
	}

	if (selectedAddressBook == NULL) {
		// TODO: Throw exception
		OFLog(@"Addressbook with name \"%@\" not found.", displayName);
		[OFApplication terminateWithStatus:EXIT_FAILURE];
	}

	C2PIpPhoneDirectory *phoneDirectory = [[C2PIpPhoneDirectory alloc] init];
	GSList *contacts = [evolutionService contactsFromAddressbookSource:selectedAddressBook];

	[phoneDirectory importFromEvolutionBook:contacts];

	g_slist_free_full(contacts, g_object_unref);
	return phoneDirectory;
}

- (void)upload {
	
}

- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	const OFOptionsParserOption options[] = {{'l', @"list", 0, NULL, NULL},
	    {'s', @"select", 1, NULL, NULL}, {'u', @"upload-to-host", 1, NULL, NULL},
	    {'n', @"username", 1, NULL, NULL}, {'h', @"help", 0, NULL, NULL},
	    {'\0', @"version", 0, NULL, NULL}, {'\0', nil, 0, NULL, NULL}};

	OFUnichar option;
	OFOptionsParser *optionsParser;

	C2PEvolutionDataService *evolutionService = [[C2PEvolutionDataService alloc] init];

	@try {

		optionsParser = [OFOptionsParser parserWithOptions:options];
		while ((option = [optionsParser nextOption]) != '\0') {
			switch (option) {
			case 'l':
				c2p_list(evolutionService);
				[evolutionService release];
				[OFApplication terminate];
				break;
			case 's':
				self.selectedDisplayName = optionsParser.argument;
				break;
			case 'u':
				self.phoneBaseIRI = [OFIRI IRIWithString:optionsParser.argument];
				break;
			case 'n':
				self.username = optionsParser.argument;
				break;
			default:
			case 'h':
				c2p_usage();
				[evolutionService release];
				[OFApplication terminate];
				break;
			}
		}

		if (self.selectedDisplayName != nil) {
			self.phoneDirectory =
			    [self phoneDirectoryForBookWithDisplayName:self.selectedDisplayName
			                      fromEvolutionDataService:evolutionService];
		}

		if (self.phoneBaseIRI) {
			if (!self.username) {
				OFLog(@"Missing username for upload.");  // TODO: throw exception
				[OFApplication terminateWithStatus:EXIT_FAILURE];
			}

			[self upload];
			[evolutionService release];
			[OFApplication terminateWithStatus:EXIT_SUCCESS];
		}

		[OFStdOut writeString:self.phoneDirectory.stringBySerializing];

	} @catch (id e *) {
		[evolutionService release];
		@throw e;
	}

	[evolutionService release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}
@end
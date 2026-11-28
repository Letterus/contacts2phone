/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

// #import "Controller/GTK/C2PGTKAppController.h"
#import "Exception/C2PUploadException.h"
#import "Model/C2PIpPhoneDirectory.h"
#import "Service/C2PEvolutionDataService.h"
#import "Service/C2PUploadService.h"
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

	g_list_free_full(addressbookList, g_object_unref);
}

@interface C2PApplication: OFObject <OFApplicationDelegate>

@property (nonatomic, retain) OFString *selectedDisplayName;
@property (nonatomic, retain) OFString *phoneDirectory;
@property (nonatomic, retain) C2PUploadService *uploadService;

- (C2PIpPhoneDirectory *)phoneDirectoryForBookWithDisplayName:(OFString *)displayName
                                     fromEvolutionDataService:
                                         (C2PEvolutionDataService *)evolutionService;

- (void)applicationDidFinishLaunching:(OFNotification *)notification;

@end

OF_APPLICATION_DELEGATE(C2PApplication)

@implementation C2PApplication

- (instancetype)init
{
	self = [super init];

	_selectedDisplayName = nil;
	_phoneDirectory = nil;
	_uploadService = [[C2PUploadService alloc] init];

	return self;
}

- (void)dealloc
{
	[_selectedDisplayName release];
	[_phoneDirectory release];
	[_uploadService release];

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

	g_object_ref(selectedAddressBook);
	g_list_free_full(addressbookList, g_object_unref);

	if (selectedAddressBook == NULL)
		@throw [C2PDescriptionException
		    exceptionWithDescription:
		        [OFString
		            stringWithFormat:@"Addressbook with displayname \"%@\" not found.",
		            displayName]];

	C2PIpPhoneDirectory *phoneDirectory = [[[C2PIpPhoneDirectory alloc] init] autorelease];
	GSList *contacts = [evolutionService contactsFromAddressbookSource:selectedAddressBook];

	[phoneDirectory importFromEvolutionBook:contacts];

	g_slist_free_full(contacts, g_object_unref);
	g_object_unref(selectedAddressBook);
	return phoneDirectory;
}

- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	const OFOptionsParserOption options[] = {{'l', @"list", 0, NULL, NULL},
	    {'s', @"select", 1, NULL, NULL}, {'u', @"upload-to-host", 1, NULL, NULL},
	    {'n', @"username", 1, NULL, NULL}, {'p', @"password", 1, NULL, NULL},
	    {'h', @"help", 0, NULL, NULL}, {'\0', @"version", 0, NULL, NULL},
	    {'\0', nil, 0, NULL, NULL}};

	OFUnichar option;
	OFOptionsParser *optionsParser;

	C2PEvolutionDataService *evolutionService = [[C2PEvolutionDataService alloc] init];

	@try {

		optionsParser = [OFOptionsParser parserWithOptions:options];

		if (!optionsParser.remainingArguments.count) {
			c2p_usage();
			[evolutionService release];
			[OFApplication terminate];
		}

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
				self.uploadService.phoneBaseIRI =
				    [OFIRI IRIWithString:optionsParser.argument];
				break;
			case 'n':
				self.uploadService.username = optionsParser.argument;
				break;
			case 'p':
				self.uploadService.password = optionsParser.argument;
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
			                      fromEvolutionDataService:evolutionService]
			        .stringBySerializing;
		}

		if (self.uploadService.phoneBaseIRI) {

			@try {

				[self.uploadService upload:self.phoneDirectory];

			} @catch (C2PUploadException *e) {
				[OFStdErr
				    writeString:[OFString
				                    stringWithFormat:@"Upload failed, exception "
				                                     @"with error message: %@\n",
				                    e.description]];
				[evolutionService release];
				[OFApplication terminateWithStatus:EXIT_FAILURE];
			}

			[evolutionService release];
			[OFApplication terminateWithStatus:EXIT_SUCCESS];
		}

		[OFStdOut writeString:self.phoneDirectory];

	} @catch (C2PDescriptionException *de) {
		[OFStdErr writeString:[OFString stringWithFormat:@"Process failed, exception "
		                                                 @"with error message: %@\n",
		                                de.description]];
		[evolutionService release];
		[OFApplication terminateWithStatus:EXIT_FAILURE];

	} @catch (id e) {
		[evolutionService release];
		@throw e;
	}

	[evolutionService release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}

@end
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

	g_list_free_full (addressbookList, g_object_unref);
}

@interface C2PApplication: OFObject <OFApplicationDelegate, OFHTTPClientDelegate>

@property (nonatomic, retain) OFString *selectedDisplayName;
@property (nonatomic, retain) OFString *phoneDirectory;
@property (nonatomic, retain) OFIRI *phoneBaseIRI;
@property (nonatomic, retain) OFString *username;
@property (nonatomic, retain) OFString *password;

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
	_password = nil;

	return self;
}

- (void)dealloc
{
	[_selectedDisplayName release];
	[_phoneDirectory release];
	[_phoneBaseIRI release];
	[_username release];
	[_password release];

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
	g_list_free_full (addressbookList, g_object_unref);

	if (selectedAddressBook == NULL) {
		// TODO: Throw exception
		OFLog(@"Addressbook with name \"%@\" not found.", displayName);
		[OFApplication terminateWithStatus:EXIT_FAILURE];
	}

	C2PIpPhoneDirectory *phoneDirectory = [[[C2PIpPhoneDirectory alloc] init] autorelease];
	GSList *contacts = [evolutionService contactsFromAddressbookSource:selectedAddressBook];

	[phoneDirectory importFromEvolutionBook:contacts];

	g_slist_free_full(contacts, g_object_unref);
	g_object_unref(selectedAddressBook);
	return phoneDirectory;
}

- (void)upload
{
	OFHTTPClient *httpClient = [OFHTTPClient client];
	[httpClient setDelegate:self];

	OFIRI *uploadIRI = [self.phoneBaseIRI IRIByAppendingPathComponent:@"UploadFile.html"
	                                                      isDirectory:false];

	OFString *credentials = [OFString stringWithFormat:@"%@:%@", self.username, self.password];
	OFData *credentialData = [credentials dataWithEncoding:OFStringEncodingUTF8];

	OFString *basicAuthHeader =
	    [OFString stringWithFormat:@"Basic %@", credentialData.stringByBase64Encoding];

	OFMutableString *body = [OFMutableString stringWithString:@"\n--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"Directory\"; "
	                   @"filename=\"directory.xml\"\n"];
	[body appendString:@"Content-Type: application/xml\n\n"];
	[body appendString:self.phoneDirectory];
	[body appendString:@"\n--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"DST_PHB\";\n\n"];
	[body appendString:@"0\n"];
	[body appendString:@"--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"HttpRedirectUrl\";\n\n"];
	[body appendString:@"ContactList.html"];
	[body appendString:@"\n--ofhttpclientdelimiter--"];

	OFData *bodyData = [body dataWithEncoding:OFStringEncodingUTF8];
	OFString *contentLengthValue = [OFString stringWithFormat:@"%llu", bodyData.count];

	OFLog(@"Content-Length: %@", contentLengthValue);

	OFHTTPRequest *request = [OFHTTPRequest requestWithIRI:uploadIRI];
	[request setHeaders:@{
		@"User-Agent" : @"OFHTTPClient",
		@"Accept" : @"text/html,application/xhtml+xml,application",
		@"Authorization" : basicAuthHeader,
		@"Content-Type" : @"multipart/form-data;boundary=ofhttpclientdelimiter",
		@"Content-Length" : contentLengthValue
	}];
	[request setMethod:OFHTTPRequestMethodPost];
	request.body = bodyData;

	[httpClient performRequest:request];
}

- (void)client:(nonnull OFHTTPClient *)client
    didPerformRequest:(nonnull OFHTTPRequest *)request
             response:(nullable OFHTTPResponse *)response
            exception:(nullable id)exception
{
	OFLog(@"Response headers are %@", response.headers);
	OFLog(@"Response is %@", response.readString);
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

	//@try {

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
		case 'p':
			self.password = optionsParser.argument;
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

	if (self.phoneBaseIRI) {
		if (!self.username) {
			OFLog(@"Missing username for upload.");  // TODO: throw exception
			[OFApplication terminateWithStatus:EXIT_FAILURE];
		}

		if (!self.password) {
			OFLog(@"Missing password for upload.");  // TODO: throw exception
			[OFApplication terminateWithStatus:EXIT_FAILURE];
		}

		[self upload];
		[evolutionService release];
		[OFApplication terminateWithStatus:EXIT_SUCCESS];
	}

	[OFStdOut writeString:self.phoneDirectory];

	// } @catch (id e *) {
	// 	[evolutionService release];
	// 	@throw e;
	// }

	[evolutionService release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}

@end
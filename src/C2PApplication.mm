/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

//#import "Controller/GTK/C2PGTKAppController.h"
#import "Model/C2PIpPhoneDirectory.h"
#import "Service/EvolutionDataService.h"
#import <ObjFW/ObjFW.h>

using namespace peel;

@interface C2PApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(C2PApplication)

@implementation C2PApplication
- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	auto evolutionService = new C2P::EvolutionDataService();
	RefPtr<Gio::ListStore> addressbookListStore = evolutionService->getAddressbookSources();

	//C2PGTKAppController *gtkAppController = [[[C2PGTKAppController alloc]
	//       initWithEDS:evolutionService
	//    phoneDirectory:phoneDirectory] autorelease];

	RefPtr<EDataServer::Source> myAddressBook = nullptr;
	for(int i = 0; RefPtr<EDataServer::Source> addressBook = reinterpret_cast<EDataServer::Source *>(addressbookListStore->get_item(i)); i++) {
		if(strcmp(addressBook->get_display_name(), "Adressbuch") == 0) {
			myAddressBook = addressBook;
			break;
		}
	}

	if(myAddressBook == nullptr)
		[OFApplication terminateWithStatus:EXIT_FAILURE];

	// General model
	C2PIpPhoneDirectory *phoneDirectory =
	    [[C2PIpPhoneDirectory alloc] init];

	UniquePtr<GLib::SList> contacts = evolutionService->retrieveContactsFromAddressbookSource(myAddressBook);

	[phoneDirectory importFromEvolutionBook:std::move(contacts)];
	[OFStdOut writeString:phoneDirectory.stringBySerializing];

	[phoneDirectory release];
	[OFApplication terminateWithStatus:EXIT_SUCCESS];
}

@end

/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PGTKAppController.h"
#include "../../View/GTK/C2PAddressBookListBoxRow.h"
#import <OGAdw/OGAdw-Umbrella.h>
#import <OGdk4/OGdk4-Umbrella.h>
#import <OGio/OGio-Umbrella.h>
#include <gtk/gtk.h>

static GtkWidget *createAddressbookRow(GObject *item, gpointer user_data)
{
	C2PAddressBookListBoxRow *row = c2p_addressbook_list_box_row_new();

	g_object_bind_property(item, "display-name", row, "label", G_BINDING_SYNC_CREATE);

	return GTK_WIDGET(row);
}

@implementation C2PGTKAppController
@synthesize app = _app;
@synthesize evolutionService = _evolutionService;
@synthesize phoneDirectory = _phoneDirectory;

- (void)dealloc
{

	[super dealloc];
}

- (instancetype)initWithEDS:(C2PEvolutionDataService *)evolutionService
             phoneDirectory:(C2PIpPhoneDirectory *)phoneDirectory
{
	self = [super init];

	@try {
		_evolutionService = [evolutionService retain];
		_phoneDirectory = [phoneDirectory retain];
	} @catch (OFException *e) {
		[self release];
		@throw e;
	}

	return self;
}

- (int)launch
{
	int *argc;
	char ***argv;
	int ret;

	// GTK runloop
	self.app =
	    [OGTKApplication applicationWithApplicationId:@"org.codeberg.Letterus.contacts2phone"
	                                            flags:G_APPLICATION_DEFAULT_FLAGS];

	[self.app connectSignal:@"activate" target:self selector:@selector(activateApplication:)];

	// ObjFW runloop
	[[OFApplication sharedApplication] getArgumentCount:&argc andArgumentValues:&argv];

	return [self.app runWithArgc:*argc argv:*argv];
}

- (void)activateApplication:(OGTKApplication *)app
{
	[self bindUI:app];

	// Setup controller
	// Bind actions
}

- (void)bindUI:(OGTKApplication *)app
{
	OGTKBuilder *builder = [OGTKBuilder builderFromFileWithFilename:@"res/GTK/UI/MainView.ui"];

	OGTKWindow *mainWindow = (OGTKWindow *)[builder objectWithName:@"mainWindow"];
	[mainWindow setApplication:app];
	[mainWindow present];

	OGTKButton *transferButton = (OGTKButton *)[builder objectWithName:@"transferButton"];
	[transferButton connectSignal:@"clicked" target:self selector:@selector(transfer:)];

	OGListStore *addressBooksModel = self.evolutionService.addressbookSources;
	OGTKListBox *addressBooksList = (OGTKListBox *)[builder objectWithName:@"addressBooksList"];

	[addressBooksList bindModel:(GListModel *)[addressBooksModel castedGObject]
	           createWidgetFunc:(GtkListBoxCreateWidgetFunc)createAddressbookRow
	                   userData:NULL
	           userDataFreeFunc:NULL];
}

// Action
- (void)transfer:(id)emitter
{
	[self.phoneDirectory importFromEvolutionBook:self.evolutionService.contacts];
	[OFStdOut writeString:self.phoneDirectory.stringBySerializing];
}

@end

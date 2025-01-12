/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PGTKAppController.h"
#import <OGAdw/OGAdw-Umbrella.h>
#import <OGdk4/OGdk4-Umbrella.h>
#import <OGio/OGio-Umbrella.h>

static GtkWidget *createAddressbookRow(GObject *item, gpointer user_data)
{
	OGAdwActionRow *row = [OGAdwActionRow actionRow];
	row.title = @"Address book";
	g_object_bind_property(item, "display-name", [row castedGObject],
	    "subtitle", G_BINDING_SYNC_CREATE);

	[row addCssClass:@"property"];

	return GTK_WIDGET([row castedGObject]);
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
	self.app = [OGTKApplication
	    applicationWithApplicationId:@"org.codeberg.Letterus.contacts2phone"
	                           flags:G_APPLICATION_DEFAULT_FLAGS];

	/*	[self.app connectSignal:@"startup"
	                         target:self
	                       selector:@selector(loadCSS:)];*/

	[self.app connectSignal:@"activate"
	                 target:self
	               selector:@selector(activateApplication:)];

	// ObjFW runloop
	[[OFApplication sharedApplication] getArgumentCount:&argc
	                                  andArgumentValues:&argv];

	return [self.app runWithArgc:*argc argv:*argv];
}

/*- (void)loadCSS:(OGTKApplication *)app;
{
        OGTKCssProvider *provider = [[[OGTKCssProvider alloc] init]
autorelease]; [provider loadFromString:@"style.css"];

        [OGTKStyleContext
            addProviderForDisplayWithDisplay:[OGGdkDisplay default]
                                    provider:[provider castedGObject]
                                    priority:
                                        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION];
}*/

- (void)activateApplication:(OGTKApplication *)app
{
	[self buildUI:app];

	// Setup controller
	// Bind actions
}

- (void)buildUI:(OGTKApplication *)app
{
	// TODO: Use
	// `Gtk::Widget::Class::set_template_from_resource()` over explicit
	// `Gtk::Builder`
	OGTKBuilder *builder =
	    [OGTKBuilder builderFromFile:@"res/GTK/UI/MainView.ui"];

	OGTKWindow *mainWindow = (OGTKWindow *)[builder object:@"mainWindow"];
	[mainWindow setApplication:app];

	[mainWindow present];

	// [transferButton connectSignal:@"clicked"
	//                        target:self
	//                      selector:@selector(transfer:)];

	// OGListStore *addressBooksModel =
	//     self.evolutionService.addressbookSources;

	// [addressBooksList
	//     bindModelWithModel:(GListModel *)[addressBooksModel
	//     castedGObject]
	//       createWidgetFunc:(GtkListBoxCreateWidgetFunc)createAddressbookRow
	//               userData:NULL
	//       userDataFreeFunc:NULL];
}

// Action
- (void)transfer:(id)emitter
{
	[self.phoneDirectory
	    importFromEvolutionBook:self.evolutionService.contacts];
	[OFStdOut writeString:self.phoneDirectory.stringBySerializing];
}

@end

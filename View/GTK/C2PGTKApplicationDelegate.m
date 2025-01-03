/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PGTKApplicationDelegate.h"
#import <OGAdw/OGAdw-Umbrella.h>
#import <OGdk4/OGdk4-Umbrella.h>
#import <OGio/OGio-Umbrella.h>
#include <adwaita.h>

static GtkWidget *createAddressbookRow(GObject *item, gpointer user_data)
{
	OGAdwActionRow *row = [[[OGAdwActionRow alloc] init] autorelease];
	row.title = @"Address book";
	g_object_bind_property(item, "display-name", [row castedGObject],
	    "subtitle", G_BINDING_SYNC_CREATE);

	[row addCssClass:@"property"];

	return [row castedGObject];
}

@implementation C2PGTKApplicationDelegate
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
	self.app = [[OGTKApplication alloc]
	    initWithApplicationId:@"org.codeberg.Letterus.contacts2phone"
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
	// Window
	OGTKApplicationWindow *window =
	    [[OGTKApplicationWindow alloc] init:self.app];

	[window setDefaultSizeWithWidth:640 height:480];
	window.title = @"Transfer contacts to SNOM IP phone base";

	OGAdwClamp *addressBooksClamp = [[OGAdwClamp alloc] init];

	// Left/start widget
	OGTKListBox *addressBooksList = [[OGTKListBox alloc] init];

	OGTKLabel *addressBooksLabel =
	    [[OGTKLabel alloc] init:@"Address books - select one to transfer:"];
	addressBooksLabel.halign = GTK_ALIGN_START;

	OGTKBox *addressBooksListBox =
	    [[OGTKBox alloc] initWithOrientation:GTK_ORIENTATION_VERTICAL
	                                 spacing:24];
	addressBooksListBox.marginTop = 12;
	addressBooksListBox.marginBottom = 12;
	addressBooksListBox.marginStart = 12;
	addressBooksListBox.marginEnd = 12;

	[addressBooksListBox append:addressBooksLabel];
	[addressBooksListBox append:addressBooksList];

	addressBooksClamp.child = addressBooksListBox;

	OGTKScrolledWindow *scrolledFirstWindow =
	    [[OGTKScrolledWindow alloc] init];
	scrolledFirstWindow.child = addressBooksClamp;

	// Right/last widget
	OGTKHeaderBar *headerBar = [[OGTKHeaderBar alloc] init];
	headerBar.showTitleButtons = false;
	OGTKGrid *nullTitle = [[OGTKGrid alloc] init];
	nullTitle.visible = false;
	headerBar.titleWidget = nullTitle;

	OGTKButton *transferButton =
	    [[OGTKButton alloc] initWithLabel:@"Transfer"];
	OGTKActionBar *leftActionBar = [[OGTKActionBar alloc] init];
	[leftActionBar packEnd:transferButton];

	OGTKScrolledWindow *scrolledSecondWindow =
	    [[OGTKScrolledWindow alloc] init];
	OGAdwToolbarView *toolbarSecond = [[OGAdwToolbarView alloc] init];
	toolbarSecond.bottomBarStyle = ADW_TOOLBAR_RAISED;
	toolbarSecond.content = scrolledSecondWindow;
	[toolbarSecond addTopBar:headerBar];
	[toolbarSecond addBottomBar:leftActionBar];

	// Left/start widget
	OGAdwClamp *phoneBaseCredentialsClamp = [[OGAdwClamp alloc] init];

	OGAdwPreferencesGroup *phoneBaseCredentials =
	    [[OGAdwPreferencesGroup alloc] init];
	[phoneBaseCredentials setTitle:@"Phone Base Credentials"];
	[phoneBaseCredentials
	    setDescription:
	        @"Enter IP and admin credentials for your snom M300:"];

	OGAdwEntryRow *ipAddressOrHostnameInput = [[OGAdwEntryRow alloc] init];
	[ipAddressOrHostnameInput setTitle:@"IP address or hostname"];
	[ipAddressOrHostnameInput
	    setTooltipText:@"You don't need to prepend http(s)://"];
	ipAddressOrHostnameInput.showApplyButton = true;
	[phoneBaseCredentials add:ipAddressOrHostnameInput];

	OGAdwEntryRow *adminUserNameInput = [[OGAdwEntryRow alloc] init];
	[adminUserNameInput setTitle:@"Admin user name"];
	[adminUserNameInput setTooltipText:@"Usually \"admin\""];
	[phoneBaseCredentials add:adminUserNameInput];

	OGAdwPasswordEntryRow *adminUserPasswordInput =
	    [[OGAdwPasswordEntryRow alloc] init];
	[adminUserPasswordInput setTitle:@"Admin user password"];
	[phoneBaseCredentials add:adminUserPasswordInput];

	OGTKBox *phoneBaseCredentialsBox =
	    [[OGTKBox alloc] initWithOrientation:GTK_ORIENTATION_VERTICAL
	                                 spacing:24];

	[phoneBaseCredentialsBox setValign:GTK_ALIGN_CENTER];
	phoneBaseCredentialsBox.marginTop = 12;
	phoneBaseCredentialsBox.marginBottom = 12;
	phoneBaseCredentialsBox.marginStart = 12;
	phoneBaseCredentialsBox.marginEnd = 12;

	[phoneBaseCredentialsBox append:phoneBaseCredentials];

	phoneBaseCredentialsClamp.child = phoneBaseCredentialsBox;

	scrolledSecondWindow.child = phoneBaseCredentialsClamp;

	// Put together
	[scrolledFirstWindow setSizeRequestWithWidth:160 height:-1];
	[toolbarSecond setSizeRequestWithWidth:160 height:-1];

	OGTKPaned *hpaned = [[OGTKPaned alloc] init:GTK_ORIENTATION_HORIZONTAL];

	hpaned.startChild = scrolledFirstWindow;
	hpaned.endChild = toolbarSecond;

	window.child = hpaned;

	// Bindings - move to controller
	[window present];

	[transferButton connectSignal:@"clicked"
	                       target:self
	                     selector:@selector(transfer:)];

	OGListStore *addressBooksModel =
	    self.evolutionService.addressbookSources;

	[addressBooksList
	    bindModelWithModel:(GListModel *)[addressBooksModel castedGObject]
	      createWidgetFunc:(GtkListBoxCreateWidgetFunc)createAddressbookRow
	              userData:NULL
	      userDataFreeFunc:NULL];
}

// Action
- (void)transfer:(id)emitter
{
	[self.phoneDirectory
	    importFromEvolutionBook:self.evolutionService.contacts];
	[OFStdOut writeString:self.phoneDirectory.stringBySerializing];

	[OFStdErr writeLine:@"Finished!"];
}

@end

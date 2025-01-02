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

@implementation C2PGTKApplicationDelegate
@synthesize app = _app;
@synthesize evolutionService = _evolutionService;
@synthesize phoneDirectory = _phoneDirectory;

- (void)dealloc
{
	[_app release];
	[_evolutionService release];
	[_phoneDirectory release];

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
	[self.app connectSignal:@"activate"
	                 target:self
	               selector:@selector(activateApplication:)];

	// ObjFW runloop
	[[OFApplication sharedApplication] getArgumentCount:&argc
	                                  andArgumentValues:&argv];

	return [self.app runWithArgc:*argc argv:*argv];
}

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
	window.title = @"Transfer contacts to IP phone";

	// Left/start widget
	OGTKListBox *addressBooksListBox = [[OGTKListBox alloc] init];
	addressBooksListBox.hexpand = true;
	addressBooksListBox.vexpand = true;

	OGTKScrolledWindow *scrolledWindow = [[OGTKScrolledWindow alloc] init];
	scrolledWindow.child = addressBooksListBox;

	OGTKHeaderBar *headerBar = [[OGTKHeaderBar alloc] init];
	headerBar.showTitleButtons = false;
	OGTKGrid *nullTitle = [[OGTKGrid alloc] init];
	nullTitle.visible = false;
	headerBar.titleWidget = nullTitle;

	OGTKButton *transferButton =
	    [[OGTKButton alloc] initWithLabel:@"Transfer"];
	OGTKActionBar *leftActionBar = [[OGTKActionBar alloc] init];
	[leftActionBar packEnd:transferButton];

	OGAdwToolbarView *toolbarLeft = [[OGAdwToolbarView alloc] init];
	toolbarLeft.bottomBarStyle = ADW_TOOLBAR_RAISED;
	toolbarLeft.content = scrolledWindow;
	[toolbarLeft addTopBar:headerBar];
	[toolbarLeft addBottomBar:leftActionBar];

	// Right/last widget
	OGTKBox *box =
	    [[OGTKBox alloc] initWithOrientation:GTK_ORIENTATION_VERTICAL
	                                 spacing:0];
	box.halign = GTK_ALIGN_CENTER;
	box.valign = GTK_ALIGN_CENTER;

	// Put together
	[toolbarLeft setSizeRequestWithWidth:320 height:-1];
	[box setSizeRequestWithWidth:320 height:-1];

	OGTKPaned *hpaned = [[OGTKPaned alloc] init:GTK_ORIENTATION_HORIZONTAL];

	hpaned.startChild = toolbarLeft;
	hpaned.endChild = box;

	window.child = hpaned;

	// Bindings - move to controller
	[window present];

	[transferButton connectSignal:@"clicked"
	                       target:self
	                     selector:@selector(transfer:)];
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

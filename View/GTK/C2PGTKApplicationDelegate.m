/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PGTKApplicationDelegate.h"
#include <ObjFW/OFException.h>

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

	// Load addressbooks
	// Bind data
}

- (void)buildUI:(OGTKApplication *)app
{
	OGTKApplicationWindow *window =
	    [[OGTKApplicationWindow alloc] init:self.app];
	window.title = @"Transfer Contacts to IP Phone";

	[window setDefaultSizeWithWidth:640 height:480];

	OGTKBox *box =
	    [[OGTKBox alloc] initWithOrientation:GTK_ORIENTATION_VERTICAL
	                                 spacing:0];
	box.halign = GTK_ALIGN_CENTER;
	box.valign = GTK_ALIGN_CENTER;

	window.child = box;

	OGTKButton *button = [[OGTKButton alloc] initWithLabel:@"Import"];
	[button connectSignal:@"clicked"
	               target:self
	             selector:@selector(import:)];

	[box append:button];
	[window present];
}

// Action
- (void)import:(id)emitter
{
	[self.phoneDirectory
	    importFromEvolutionBook:self.evolutionService.contacts];
	[OFStdOut writeString:self.phoneDirectory.stringBySerializing];

	[OFStdErr writeLine:@"Finished!"];
}

@end

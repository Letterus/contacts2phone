/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "Model/C2PIpPhoneDirectory.h"
#import "Service/C2PEvolutionDataService.h"
#import <ObjFW/ObjFW.h>

@interface C2PApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(C2PApplication)

@implementation C2PApplication
- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	C2PEvolutionDataService *evolutionService =
	    [[C2PEvolutionDataService alloc] init];

	C2PIpPhoneDirectory *phoneDirectory =
	    [[C2PIpPhoneDirectory alloc] init];

	[phoneDirectory importFromEvolutionBook:evolutionService.contacts];

	[OFStdOut writeString:phoneDirectory.stringBySerializing];

	[OFStdErr writeLine:@"Finished!"];

	[evolutionService release];
	[phoneDirectory release];
	[OFApplication terminate];
}

@end

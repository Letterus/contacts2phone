/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "../../Model/C2PIpPhoneDirectory.h"
#import "../../Service/EvolutionDataService.h"
#import <ObjGTK4/ObjGTK4-Umbrella.h>

OF_ASSUME_NONNULL_BEGIN

@interface C2PGTKAppController: OFObject
{
	OGTKApplication *_app;
	C2P::EvolutionDataService *_evolutionService;
	C2PIpPhoneDirectory *_phoneDirectory;
	OGListStore *_addressBooksModel;
	OGTKListBox *_addressBooksList;
}

@property (assign) OGTKApplication *app;
@property (assign) C2P::EvolutionDataService *evolutionService;
@property (assign) C2PIpPhoneDirectory *phoneDirectory;
@property (assign) OGListStore *addressBooksModel;
@property (assign) OGTKListBox *addressBooksList;

- (instancetype)initWithEDS:(C2P::EvolutionDataService *)evolutionService
             phoneDirectory:(C2PIpPhoneDirectory *)phoneDirectory;

- (int)launch;

- (void)activateApplication:(OGTKApplication *)app;

@end

OF_ASSUME_NONNULL_END

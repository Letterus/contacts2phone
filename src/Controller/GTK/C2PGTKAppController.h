/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import <ObjGTK4/ObjGTK4-Umbrella.h>
#import "../../Service/C2PEvolutionDataService.h"
#import "../../Model/C2PIpPhoneDirectory.h"

OF_ASSUME_NONNULL_BEGIN

@interface C2PGTKAppController: OFObject
{
	OGTKApplication *_app;
	C2PEvolutionDataService *_evolutionService;
	C2PIpPhoneDirectory *_phoneDirectory;
}

@property (assign) OGTKApplication *app;
@property (assign) C2PEvolutionDataService *evolutionService;
@property (assign) C2PIpPhoneDirectory *phoneDirectory;

- (instancetype)initWithEDS:(C2PEvolutionDataService *)evolutionService
             phoneDirectory:(C2PIpPhoneDirectory *)phoneDirectory;

- (int)launch;

// - (void)loadCSS:(OGTKApplication *)app;

- (void)activateApplication:(OGTKApplication *)app;

@end

OF_ASSUME_NONNULL_END

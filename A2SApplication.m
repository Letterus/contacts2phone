/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "A2SEvolutionDataService.h"
#import "Model/A2SIpPhoneDirectory.h"
#import <ObjFW/ObjFW.h>

@interface A2SApplication : OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(A2SApplication)

@implementation A2SApplication
- (void)applicationDidFinishLaunching
{
    A2SEvolutionDataService* evolutionService = [[A2SEvolutionDataService alloc] init];
    A2SIpPhoneDirectory* phoneDirectory = [[A2SIpPhoneDirectory alloc] init];

    [phoneDirectory importFromEvolutionBook:evolutionService.contacts];

    [OFStdOut writeString:phoneDirectory.stringBySerializing];

    [OFStdErr writeLine:@"Finished!"];
    [OFApplication terminate];
}

@end

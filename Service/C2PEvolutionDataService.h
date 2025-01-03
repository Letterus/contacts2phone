/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#import <ObjFW/ObjFW.h>

#import <OGEBook/OGEBook-Umbrella.h>
#import <OGEDataServer/OGEDataServer-Umbrella.h>
#import <OGio/OGio-Umbrella.h>

OF_ASSUME_NONNULL_BEGIN

@interface C2PEvolutionDataService: OFObject

@property (nonatomic, retain) OGESourceRegistry *registry;
@property (nonatomic, retain) OGESource *defaultAddressbookSource;
@property (nonatomic, retain) OGEBookClient *client;
@property (nonatomic) GSList *contacts;

- (OGListStore *)addressbookSources;

@end

OF_ASSUME_NONNULL_END

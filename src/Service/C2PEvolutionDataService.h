#pragma once

/*
 * Copyright 2021-2026 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#import <ObjFW/ObjFW.h>

#include <gio/gio.h>
#include <libebook/libebook.h>
#include <libedataserver/libedataserver.h>

OF_ASSUME_NONNULL_BEGIN

@interface C2PEvolutionDataService: OFObject

- (GList *)addressbookSources;
- (GSList *)contactsFromAddressbookSource:(ESource *)addressbook;

@end

OF_ASSUME_NONNULL_END
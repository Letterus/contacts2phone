/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "Exception/A2SEDSException.h"
#import <ObjFW/ObjFW.h>

#include <gio/gio.h>
#include <glib.h>
#include <libebook/libebook.h>
#include <libedataserver/libedataserver.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SEvolutionDataService: OFObject

@property (nonatomic) ESourceRegistry *registry;
@property (nonatomic) ESource *defaultAddressbookSource;
@property (nonatomic) EBookClient *client;
@property (nonatomic) GSList *contacts;

@end

OF_ASSUME_NONNULL_END

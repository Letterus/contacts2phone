/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import <ObjFW/ObjFW.h>

#include <gio/gio.h>
#include <glib.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SIpPhoneDirectory: OFObject

@property (retain, nonatomic) OFMutableArray *entries;

/**
 * @brief The object serialized into an IPPhoneDirectory XML element.
 */
@property (readonly, nonatomic) OFXMLElement *XMLElementBySerializing;

- (OFString *)stringBySerializing;

- (void)importFromEvolutionBook:(GSList *)evolutionContacts;

@end

OF_ASSUME_NONNULL_END

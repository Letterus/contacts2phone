/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import <ObjFW/ObjFW.h>
#include <libebook-contacts/libebook-contacts.h>

OF_ASSUME_NONNULL_BEGIN

@interface C2PIpPhoneDirectoryEntry: OFObject
{
	OFCharacterSet *_allowedCharsInPhoneNumber;
	OFCharacterSet *_cleanNumberCharsToKeep;
}

@property (retain, nonatomic) OFString *name;
@property (retain, nonatomic) OFString *telephone;
@property (retain, nonatomic) OFString *office;
@property (retain, nonatomic) OFString *mobile;

/**
 * @brief The object serialized into an DirectoryEntry XML element.
 */
@property (readonly, nonatomic) OFXMLElement *XMLElementBySerializing;

- (instancetype)addNameFromEvolutionContact:(EContact *)econtact;
- (instancetype)setTelephoneValuesForKeysWithDictionary:(OFDictionary *)keyValueMapping
                                   fromEvolutionContact:(EContact *)econtact;
- (OFString *)description;

@end

OF_ASSUME_NONNULL_END

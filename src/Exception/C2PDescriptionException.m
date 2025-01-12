/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "C2PDescriptionException.h"

@implementation C2PDescriptionException

@synthesize description = _description;

+ (instancetype)exceptionWithDescription:(OFString *)description
{
	return [[[self alloc] initWithDescription:description] autorelease];
}

+ (instancetype)exceptionWithDescriptionCString:(char *)cdescription
{
	return [[[self alloc] initWithDescriptionCString:cdescription]
	    autorelease];
}

- (instancetype)initWithDescription:(OFString *)description
{
	self = [super init];

	_description = description;

	return self;
}

- (instancetype)initWithDescriptionCString:(char *)cdescription
{
	self = [super init];

	_description = [OFString stringWithCString:cdescription
	                                  encoding:OFStringEncodingUTF8];

	return self;
}

- (void)setDescription:(OFString *)description
{
	_description = description;
	[description autorelease];
}

- (void)setDescriptionCString:(char *)cdescription
{
	_description = [OFString stringWithCString:cdescription
	                                  encoding:OFStringEncodingUTF8];
}

- (OFString *)description
{
	return _description;
}
@end

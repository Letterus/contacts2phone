/*
 * Copyright 2021-2023 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "A2SEDSException.h"

@implementation A2SEDSException

- (OFString *)description
{
	return [OFString
	    stringWithFormat:@"Evolution Data Server reports error: %@",
	    [super description]];
}
@end

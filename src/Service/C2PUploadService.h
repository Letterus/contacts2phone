/*
 * Copyright 2021-2026 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface C2PUploadService: OFObject <OFHTTPClientDelegate>
{
	OFIRI *_phoneBaseIRI;
	OFString *_username;
	OFString *_password;
}

@property (nonatomic, retain) OFIRI *phoneBaseIRI;
@property (nonatomic, retain) OFString *username;
@property (nonatomic, retain) OFString *password;

- (void)upload:(OFString *)xmlPhoneDirectory;
- (void)client:(nonnull OFHTTPClient *)client
    didPerformRequest:(nonnull OFHTTPRequest *)request
             response:(nullable OFHTTPResponse *)response
            exception:(nullable id)exception;

@end

OF_ASSUME_NONNULL_END

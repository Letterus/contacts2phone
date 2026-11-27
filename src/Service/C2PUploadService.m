/*
 * Copyright 2021-2026 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#import "C2PUploadService.h"

@implementation C2PUploadService
@synthesize phoneBaseIRI = _phoneBaseIRI;
@synthesize username = _username;
@synthesize password = _password;

- (void)dealloc
{
	objc_release(_phoneBaseIRI);
	objc_release(_username);
	objc_release(_password);

	[super dealloc];
}

- (void)upload:(OFString *)xmlPhoneDirectory
{
	if (!self.username) {
		OFLog(@"Missing username for upload.");  
		[OFApplication terminateWithStatus:EXIT_FAILURE]; // TODO: throw UploadException instead
	}

	if (!self.password) {
		OFLog(@"Missing password for upload.");
		[OFApplication terminateWithStatus:EXIT_FAILURE]; // TODO: throw UploadException instead
	}

	OFHTTPClient *httpClient = [OFHTTPClient client];
	[httpClient setDelegate:self];

	OFIRI *uploadIRI = [self.phoneBaseIRI IRIByAppendingPathComponent:@"UploadFile.html"
	                                                      isDirectory:false];

	OFString *credentials = [OFString stringWithFormat:@"%@:%@", self.username, self.password];
	OFData *credentialData = [credentials dataWithEncoding:OFStringEncodingUTF8];

	OFString *basicAuthHeader =
	    [OFString stringWithFormat:@"Basic %@", credentialData.stringByBase64Encoding];

	OFMutableString *body = [OFMutableString stringWithString:@"\n--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"Directory\"; "
	                   @"filename=\"directory.xml\"\n"];
	[body appendString:@"Content-Type: application/xml\n\n"];
	[body appendString:xmlPhoneDirectory];
	[body appendString:@"\n--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"DST_PHB\";\n\n"];
	[body appendString:@"0\n"];
	[body appendString:@"--ofhttpclientdelimiter\n"];
	[body appendString:@"Content-Disposition: form-data; name=\"HttpRedirectUrl\";\n\n"];
	[body appendString:@"ContactList.html"];
	[body appendString:@"\n--ofhttpclientdelimiter--"];

	OFData *bodyData = [body dataWithEncoding:OFStringEncodingUTF8];
	OFString *contentLengthValue = [OFString stringWithFormat:@"%llu", bodyData.count];

	OFLog(@"Content-Length: %@", contentLengthValue);

	OFHTTPRequest *request = [OFHTTPRequest requestWithIRI:uploadIRI];
	[request setHeaders:@{
		@"User-Agent" : @"OFHTTPClient",
		@"Accept" : @"text/html,application/xhtml+xml,application",
		@"Authorization" : basicAuthHeader,
		@"Content-Type" : @"multipart/form-data;boundary=ofhttpclientdelimiter",
		@"Content-Length" : contentLengthValue
	}];
	[request setMethod:OFHTTPRequestMethodPost];
	request.body = bodyData;

	[httpClient performRequest:request];
}

- (void)client:(nonnull OFHTTPClient *)client
    didPerformRequest:(nonnull OFHTTPRequest *)request
             response:(nullable OFHTTPResponse *)response
            exception:(nullable id)exception
{
	OFLog(@"Response headers are %@", response.headers);
	OFLog(@"Response is %@", response.readString);
}
@end

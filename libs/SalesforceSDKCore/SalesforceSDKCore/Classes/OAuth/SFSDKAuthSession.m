/*
Copyright (c) 2019-present, salesforce.com, inc. All rights reserved.

Redistribution and use of this software in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior written
permission of salesforce.com, inc.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SFSDKAuthSession.h"
#import "SFSDKAuthRequest.h"
#import "SFOAuthCredentials+Internal.h"
#import "SFUserAccountManager+Internal.h"
#import "SFOAuthCoordinator+Internal.h"
#import "SFIdentityCoordinator.h"

@interface SFSDKAuthSession()
@end

@implementation SFSDKAuthSession
-(instancetype)initWith:(SFSDKAuthRequest *)request {
    if (self = [super init]) {
        _oauthRequest = request;
        _credentials = [self newClientCredentials];
        _credentials.jwt = request.jwtToken;
        [self initCoordinator];
    }
    return self;
}

-(void)initCoordinator {
    self.oauthCoordinator = [[SFOAuthCoordinator alloc] initWithAuthSession:self];
    self.oauthCoordinator.additionalOAuthParameterKeys = self.oauthRequest.additionalOAuthParameterKeys;
    self.oauthCoordinator.additionalTokenRefreshParams = self.oauthRequest.additionalTokenRefreshParams;
    self.oauthCoordinator.scopes = self.oauthRequest.scopes;
    self.oauthCoordinator.brandLoginPath = self.oauthRequest.brandLoginPath;
    self.oauthCoordinator.useBrowserAuth = self.oauthRequest.useBrowserAuth;
    self.oauthCoordinator.userAgentForAuth = self.oauthRequest.userAgentForAuth;
}

- (SFOAuthCredentials *)newClientCredentials{
    NSString *identifier = [self uniqueUserAccountIdentifier:self.oauthRequest.oauthClientId];
    SFOAuthCredentials *creds = [[SFOAuthCredentials alloc] initWithIdentifier:identifier clientId:self.oauthRequest.oauthClientId encrypted:YES];
    creds.redirectUri = self.oauthRequest.oauthCompletionUrl;
    creds.domain = self.oauthRequest.loginHost;
    creds.accessToken = nil;
    return creds;
}

- (NSString*)uniqueUserAccountIdentifier:(NSString *)clientId {
    NSSet *existingAccountNames = [[SFUserAccountManager sharedInstance] allExistingAccountNames];

    // Make sure to build a unique identifier
    NSString *identifier = nil;
    while (nil == identifier || [existingAccountNames containsObject:identifier]) {
        u_int32_t randomNumber = arc4random();
        identifier = [NSString stringWithFormat:@"%@-%u", clientId, randomNumber];
    }

    return identifier;
}

@end

//
//  AppDelegate.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/20/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "MultipeerServer.h"
#import "MultipeerClient.h"
#import "MultipeerSession.h"

@implementation AppDelegate
{
    MultipeerServer *_server;
    MultipeerClient *_client;
    UILabel *_label;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self.window makeKeyAndVisible];

    BOOL isServer = [[[NSProcessInfo processInfo] arguments][2] boolValue];
    if (isServer) {
        _server = [[MultipeerServer alloc] init];
        [_server startAdvertise];

        //for debugging
        _label = [[UILabel alloc] initWithFrame:self.window.bounds];
        [self.window addSubview:_label];

        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];

    } else {
        _client = [[MultipeerClient alloc] init];
        [_client startBrowsing];
    }

    return YES;
}

- (void)update
{
    [_label removeFromSuperview];
    NSLog(@"_server.description = %@", _server.description);
    [self.window addSubview:_label];
    _label.text = _server.description;
    _label.numberOfLines = 0;
    _label.font = [UIFont systemFontOfSize:8];
    _label.frame = self.window.bounds;
//    [self.window bringSubviewToFront:_label];
}

@end

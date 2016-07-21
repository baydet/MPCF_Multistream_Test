//
//  Constants.h
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define SERVICE_NAME @"baydet-mltstrm"

static NSUInteger const kStreamReadMaxLength = 512;
static NSUInteger const kStreamWriteMaxLength = 512 * 8;
static UInt32 const kPacketLength = 1024*1024*10;

#endif /* Constants_h */

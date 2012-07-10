//
//  PBIUUID.h
//  WODCoach
//
//  Created by Casey Marshall on 6/14/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBIUUID : NSObject<NSCoding, NSCopying>
{
    CFUUIDBytes _bytes;
}

- (id) initWithString: (NSString *) uuidStr;
- (id) initWithUUIDRef: (CFUUIDRef) uuid;
- (id) initWithUUIDBytes: (CFUUIDBytes) uuidBytes;
- (id) initWithData: (NSData *) data;

+ (id) uuidWithString: (NSString *) uuidStr;
+ (id) uuidWithUUIDRef: (CFUUIDRef) uuid;
+ (id) uuidWithUUIDBytes: (CFUUIDBytes) uuidBytes;
+ (id) uuidWithData: (NSData *) data;
+ (id) randomUuid;
+ (id) nullUuid;

- (NSString *) stringValue;
- (CFUUIDBytes) bytes;
- (NSData *) data;
- (BOOL) isNullUuid;

@end

CFUUIDRef CFUUIDCreateFromNSUUID(PBIUUID *uuid);
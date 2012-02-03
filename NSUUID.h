//
//  NSUUID.h
//  WODCoach
//
//  Created by Casey Marshall on 6/14/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUUID : NSObject<NSCoding, NSCopying>
{
    CFUUIDBytes bytes;
}

- (id) initWithString: (NSString *) uuidStr;
- (id) initWithUUIDRef: (CFUUIDRef) uuid;
- (id) initWithUUIDBytes: (CFUUIDBytes) uuidBytes;
- (id) initWithData: (NSData *) data;

+ (NSUUID *) uuidWithString: (NSString *) uuidStr;
+ (NSUUID *) uuidWithUUIDRef: (CFUUIDRef) uuid;
+ (NSUUID *) uuidWithUUIDBytes: (CFUUIDBytes) uuidBytes;
+ (NSUUID *) uuidWithData: (NSData *) data;
+ (NSUUID *) randomUuid;
+ (NSUUID *) nullUuid;

- (NSString *) stringValue;
- (CFUUIDBytes) bytes;
- (NSData *) data;
- (BOOL) isNullUuid;

@end

CFUUIDRef CFUUIDCreateFromNSUUID(NSUUID *uuid);
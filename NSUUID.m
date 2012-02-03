//
//  NSUUID.m
//  WODCoach
//
//  Created by Casey Marshall on 6/14/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import "NSUUID.h"

@implementation NSUUID

- (id) initWithString: (NSString *) uuidStr
{
    if (self = [super init])
    {
        CFUUIDRef u = CFUUIDCreateFromString(NULL, (__bridge CFStringRef) uuidStr);
        bytes = CFUUIDGetUUIDBytes(u);
        CFRelease(u);
    }
    return self;
}

- (id) initWithUUIDRef: (CFUUIDRef) uuid
{
    if (self = [super init])
    {
        bytes = CFUUIDGetUUIDBytes(uuid);
    }
    return self;
}

- (id) initWithUUIDBytes: (CFUUIDBytes) uuidBytes
{
    if (self = [super init])
    {
        bytes = uuidBytes;
    }
    return self;
}

- (id) initWithData: (NSData *) data
{
    if ([data length] < 16)
    {
      return nil;
    }
    else if (self = [super init])
    {
        [data getBytes: &bytes length: sizeof(bytes)];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBytes:(void *) &bytes length: sizeof(bytes)];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
      NSUInteger length;
      void *decodedBytes = [coder decodeBytesWithReturnedLength:&length];
      NSAssert(length == sizeof(bytes), 
               @"Got a non-uuid size back when decoding: %d != %d", length, sizeof(bytes));
      memcpy(&bytes, decodedBytes, sizeof(bytes));
    }
    return self;
}


+ (NSUUID *) uuidWithString: (NSString *) uuidStr
{
    return [[NSUUID alloc] initWithString: uuidStr];
}

+ (NSUUID *) uuidWithUUIDRef: (CFUUIDRef) uuid
{
    return [[NSUUID alloc] initWithUUIDRef: uuid];
}

+ (NSUUID *) uuidWithUUIDBytes: (CFUUIDBytes) uuidBytes
{
    return [[NSUUID alloc] initWithUUIDBytes: uuidBytes];
}

+ (NSUUID *) uuidWithData: (NSData *) data
{
    return [[NSUUID alloc] initWithData: data];
}

+ (NSUUID *) randomUuid
{
    CFUUIDRef cfuuid = CFUUIDCreate(NULL);
    NSUUID *uuid = [NSUUID uuidWithUUIDRef: cfuuid];
    CFRelease(cfuuid);
    return uuid;
}

+ (NSUUID *) nullUuid
{
    CFUUIDBytes bytes;
    memset(&bytes, 0, sizeof(bytes));
    return [NSUUID uuidWithUUIDBytes: bytes];
}

- (NSString *) stringValue
{
    return [NSString stringWithFormat: @"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            bytes.byte0,  bytes.byte1,  bytes.byte2,  bytes.byte3,
            bytes.byte4,  bytes.byte5,  bytes.byte6,  bytes.byte7,
            bytes.byte8,  bytes.byte9,  bytes.byte10, bytes.byte11,
            bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15];
            
}

- (NSComparisonResult) compareTo: (NSUUID *) that
{
    CFUUIDBytes thatbytes = [that bytes];
    int result = memcmp(&bytes, &thatbytes, sizeof(bytes));
    if (result < 0)
        return NSOrderedAscending;
    if (result > 0)
        return NSOrderedDescending;
    return NSOrderedSame;
}

- (BOOL) isEqual: (id) object
{
    if (object == nil || ![object isKindOfClass: [NSUUID class]])
        return NO;
    
    NSUUID *that = (NSUUID *) object;
    CFUUIDBytes thatbytes = [that bytes];
    return memcmp(&bytes, &thatbytes, sizeof(bytes)) == 0;
}

- (NSUInteger) hash
{
    long long mostSigBits = 
        ((long long)bytes.byte15 << 56) |
        ((long long)bytes.byte14 << 48) |
        ((long long)bytes.byte13 << 40) |
        ((long long)bytes.byte12 << 32) |
        ((long long)bytes.byte11 << 24) |
        ((long long)bytes.byte10 << 16) |
        ((long long)bytes.byte9 << 8) |
        ((long long)bytes.byte8 << 0);
    long long leastSigBits = 
        ((long long)bytes.byte7 << 56) |
        ((long long)bytes.byte6 << 48) |
        ((long long)bytes.byte5 << 40) |
        ((long long)bytes.byte4 << 32) |
        ((long long)bytes.byte3 << 24) |
        ((long long)bytes.byte2 << 16) |
        ((long long)bytes.byte1 << 8) |
        ((long long)bytes.byte0 << 0);
    
    long long hilo = mostSigBits ^ leastSigBits;
    return ((NSUInteger)(hilo >> 32)) ^ (NSUInteger) hilo;
}

- (NSString *) description
{
    return [self stringValue];
}

- (CFUUIDBytes) bytes
{
    CFUUIDBytes ret = bytes;
    return ret;
}

- (NSData *) data
{
    return [NSData dataWithBytes: (void *) &bytes
                          length: sizeof(bytes)];
}

- (BOOL) isNullUuid
{
    return (bytes.byte0 == 0
            && bytes.byte1 == 0
            && bytes.byte2 == 0
            && bytes.byte3 == 0
            && bytes.byte4 == 0
            && bytes.byte5 == 0
            && bytes.byte6 == 0
            && bytes.byte7 == 0
            && bytes.byte8 == 0
            && bytes.byte9 == 0
            && bytes.byte10 == 0
            && bytes.byte11 == 0
            && bytes.byte12 == 0
            && bytes.byte13 == 0
            && bytes.byte14 == 0
            && bytes.byte15 == 0);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSUUID allocWithZone:zone] initWithUUIDBytes:bytes];
}

@end

CFUUIDRef CFUUIDCreateFromNSUUID(NSUUID *uuid)
{
    CFUUIDBytes bytes = uuid.bytes;
    return CFUUIDCreateWithBytes(NULL, bytes.byte0, bytes.byte1, bytes.byte2, bytes.byte3,
                                 bytes.byte4, bytes.byte5, bytes.byte6, bytes.byte7,
                                 bytes.byte8, bytes.byte9, bytes.byte10, bytes.byte11,
                                 bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15);
}

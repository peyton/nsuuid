//
//  NSUUID.m
//  WODCoach
//
//  Created by Casey Marshall on 6/14/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import "PBIUUID.h"

@implementation PBIUUID

- (id) initWithString: (NSString *) uuidStr
{
    if (self = [super init])
    {
        CFUUIDRef u = CFUUIDCreateFromString(NULL, (__bridge CFStringRef) uuidStr);
        _bytes = CFUUIDGetUUIDBytes(u);
        CFRelease(u);
    }
    return self;
}

- (id) initWithUUIDRef: (CFUUIDRef) uuid
{
    if (self = [super init])
    {
        _bytes = CFUUIDGetUUIDBytes(uuid);
    }
    return self;
}

- (id) initWithUUIDBytes: (CFUUIDBytes) uuidBytes
{
    if (self = [super init])
    {
        _bytes = uuidBytes;
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
        [data getBytes: &_bytes length: sizeof(_bytes)];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBytes:(void *) &_bytes length: sizeof(_bytes)];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
      NSUInteger length;
      void *decodedBytes = [coder decodeBytesWithReturnedLength:&length];
      NSAssert(length == sizeof(self.bytes),
               @"Got a non-uuid size back when decoding: %d != %lu", length, sizeof(_bytes));
      memcpy(&_bytes, decodedBytes, sizeof(_bytes));
    }
    return self;
}


+ (id) uuidWithString: (NSString *) uuidStr
{
    return [[[self class] alloc] initWithString: uuidStr];
}

+ (id) uuidWithUUIDRef: (CFUUIDRef) uuid
{
    return [[[self class] alloc] initWithUUIDRef: uuid];
}

+ (id) uuidWithUUIDBytes: (CFUUIDBytes) uuidBytes
{
    return [(PBIUUID *)[[self class] alloc] initWithUUIDBytes: uuidBytes];
}

+ (id) uuidWithData: (NSData *) data
{
    return [[[self class] alloc] initWithData: data];
}

+ (id) randomUuid
{
    CFUUIDRef cfuuid = CFUUIDCreate(NULL);
    PBIUUID *uuid = [[self class] uuidWithUUIDRef: cfuuid];
    CFRelease(cfuuid);
    return uuid;
}

+ (id) nullUuid
{
    CFUUIDBytes bytes;
    memset(&bytes, 0, sizeof(bytes));
    return [[self class] uuidWithUUIDBytes: bytes];
}

- (NSString *) stringValue
{
    return [NSString stringWithFormat: @"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            _bytes.byte0,  _bytes.byte1,  _bytes.byte2,  _bytes.byte3,
            _bytes.byte4,  _bytes.byte5,  _bytes.byte6,  _bytes.byte7,
            _bytes.byte8,  _bytes.byte9,  _bytes.byte10, _bytes.byte11,
            _bytes.byte12, _bytes.byte13, _bytes.byte14, _bytes.byte15];
            
}

- (NSComparisonResult) compareTo: (PBIUUID *) that
{
    CFUUIDBytes thatbytes = [that bytes];
    int result = memcmp(&_bytes, &thatbytes, sizeof(_bytes));
    if (result < 0)
        return NSOrderedAscending;
    if (result > 0)
        return NSOrderedDescending;
    return NSOrderedSame;
}

- (BOOL) isEqual: (id) object
{
    if (object == nil || ![object isKindOfClass: [PBIUUID class]])
        return NO;
    
    PBIUUID *that = (PBIUUID *) object;
    CFUUIDBytes thatbytes = [that bytes];
    return memcmp(&_bytes, &thatbytes, sizeof(_bytes)) == 0;
}

- (NSUInteger) hash
{
    long long mostSigBits = 
        ((long long)_bytes.byte15 << 56) |
        ((long long)_bytes.byte14 << 48) |
        ((long long)_bytes.byte13 << 40) |
        ((long long)_bytes.byte12 << 32) |
        ((long long)_bytes.byte11 << 24) |
        ((long long)_bytes.byte10 << 16) |
        ((long long)_bytes.byte9 << 8) |
        ((long long)_bytes.byte8 << 0);
    long long leastSigBits = 
        ((long long)_bytes.byte7 << 56) |
        ((long long)_bytes.byte6 << 48) |
        ((long long)_bytes.byte5 << 40) |
        ((long long)_bytes.byte4 << 32) |
        ((long long)_bytes.byte3 << 24) |
        ((long long)_bytes.byte2 << 16) |
        ((long long)_bytes.byte1 << 8) |
        ((long long)_bytes.byte0 << 0);
    
    long long hilo = mostSigBits ^ leastSigBits;
    return ((NSUInteger)(hilo >> 32)) ^ (NSUInteger) hilo;
}

- (NSString *) description
{
    return [self stringValue];
}

- (CFUUIDBytes) bytes
{
    CFUUIDBytes ret = _bytes;
    return ret;
}

- (NSData *) data
{
    return [NSData dataWithBytes: (void *) &_bytes
                          length: sizeof(_bytes)];
}

- (BOOL) isNullUuid
{
    return (_bytes.byte0 == 0
            && _bytes.byte1 == 0
            && _bytes.byte2 == 0
            && _bytes.byte3 == 0
            && _bytes.byte4 == 0
            && _bytes.byte5 == 0
            && _bytes.byte6 == 0
            && _bytes.byte7 == 0
            && _bytes.byte8 == 0
            && _bytes.byte9 == 0
            && _bytes.byte10 == 0
            && _bytes.byte11 == 0
            && _bytes.byte12 == 0
            && _bytes.byte13 == 0
            && _bytes.byte14 == 0
            && _bytes.byte15 == 0);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [(PBIUUID *)[[self class] allocWithZone:zone] initWithUUIDBytes:self.bytes];
}

@end

CFUUIDRef CFUUIDCreateFromNSUUID(PBIUUID *uuid)
{
    CFUUIDBytes bytes = uuid.bytes;
    return CFUUIDCreateWithBytes(NULL, bytes.byte0, bytes.byte1, bytes.byte2, bytes.byte3,
                                 bytes.byte4, bytes.byte5, bytes.byte6, bytes.byte7,
                                 bytes.byte8, bytes.byte9, bytes.byte10, bytes.byte11,
                                 bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15);
}

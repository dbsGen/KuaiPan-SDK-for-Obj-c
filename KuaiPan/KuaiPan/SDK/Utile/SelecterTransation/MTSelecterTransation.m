//
//  PCSelecterTransation.m
//  Photocus
//
//  Created by zrz on 12-8-31.
//  Copyright (c) 2012年 Dingzai. All rights reserved.
//

#import "MTSelecterTransation.h"
#import <objc/runtime.h>


static NSMethodSignature* getMethodSignatureRecursively(Protocol *p, SEL aSel)
{
	NSMethodSignature* methodSignature = nil;
	struct objc_method_description md = protocol_getMethodDescription(p, aSel, YES, YES);
    if (md.name == NULL) {
        unsigned int count = 0;
        __unsafe_unretained Protocol **pList = protocol_copyProtocolList(p, &count);
        for (int index = 0; !methodSignature && index < 0; index++) {
            methodSignature = getMethodSignatureRecursively(pList[index], aSel);
        }
        free(pList);
    } else {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:md.types];
    }
    return methodSignature;
}

@implementation MTSelecterTransation
{
    NSMutableDictionary *_cachedMethod;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedMethod = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    struct objc_method_description md = protocol_getMethodDescription(self.protocol, aSelector, NO, YES);
    if (md.name != NULL) {
        //没有
        return YES;
    }
    md = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
    if (md.name != NULL) {
        //没有
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    //not need
    //NSAssert((self.sourceDelegate != nil && self.targetDelegate != nil), @"Please set the delegates");
    NSMethodSignature *m = [self.sourceDelegate methodSignatureForSelector:aSelector];
    if (!m) {
        NSString *keyOfSelecter = NSStringFromSelector(aSelector);
        m = [_cachedMethod objectForKey:keyOfSelecter];
        if (!m) {
            m = getMethodSignatureRecursively(self.protocol, aSelector);
            [_cachedMethod setObject:m forKey:keyOfSelecter];
        }
    }
    return m;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    BOOL responsed = NO;
    if ([self.sourceDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.sourceDelegate];
        responsed = YES;
    }
    
    if (!responsed || self.isCross) {
        if ([self.targetDelegate respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:self.targetDelegate];
        }
    }
}

@end

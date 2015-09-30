//
//  TLMacros.h
//  TLTCPClient
//
//  Created by lichuanjun on 15/9/29.
//  Copyright © 2015年 lichuanjun. All rights reserved.
//

#ifndef TLMacros_h
#define TLMacros_h

//
// 单例定义和实现宏
//
#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	IMP_SINGLETON
#define IMP_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}


#endif /* TLMacros_h */

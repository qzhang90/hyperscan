#ifndef UTIL_BYTESWAP_H_
#define UTIL_BYTESWAP_H_

#include "ue2common.h"

// u64a byteSwapu64a(u64a n);

// u32 byteSwapu32(u32 n);

// u16 byteSwapu16(u16 n);

static really_inline
u64a byteSwapu64a(u64a n){
    u64a ans = 0;
    u64a byte;
    unsigned int i;

    for(i = 0; i < 64; i+=8){
        byte = (n>>i)&0xFF;
        ans |= byte<<(64-8-i);
    }
    return ans;
}

static really_inline
u32 byteSwapu32(u32 n){
    u32 ans = 0;
    u32 byte;
    unsigned int i;

    for(i = 0; i < 32; i+=8){
        byte = (n>>i)&0xFF;
        ans |= byte<<(32-8-i);
    }
    return ans;
}

static really_inline
u16 byteSwapu16(u16 n){
    u16 ans = 0;
    u16 byte;
    unsigned int i;

    for(i = 0; i < 16; i+=8){
        byte = (n>>i)&0xFF;
        ans |= byte<<(16-8-i);
    }
    return ans;
}
#endif // UTIL_BYTESWAP_H_

# detect architecture features
#
# must be called after determining where compiler intrinsics are defined

if (HAVE_C_X86INTRIN_H)
    set (INTRIN_INC_H "x86intrin.h")
elseif (HAVE_C_INTRIN_H)
    set (INTRIN_INC_H "intrin.h")
elseif (HAVE_CXX_S390INTRIN_H)
    set (INTRIN_INC_H "s390intrin.h")
else ()
    message (FATAL_ERROR "No intrinsics header found")
endif ()

if (BUILD_AVX512)
    CHECK_C_COMPILER_FLAG(${SKYLAKE_FLAG} HAS_ARCH_SKYLAKE)
    if (NOT HAS_ARCH_SKYLAKE)
        message (FATAL_ERROR "AVX512 not supported by compiler")
    endif ()
endif ()

if (FAT_RUNTIME)
    # test the highest level microarch to make sure everything works
    if (BUILD_AVX512)
        set (CMAKE_REQUIRED_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_C_FLAGS} ${SKYLAKE_FLAG}")
    else ()
        # set (CMAKE_REQUIRED_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_C_FLAGS} -march=core-avx2")
        set (CMAKE_REQUIRED_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_C_FLAGS} -march=z14")
    endif ()
else (NOT FAT_RUNTIME)
    # if not fat runtime, then test given cflags
    set (CMAKE_REQUIRED_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_C_FLAGS} ${ARCH_C_FLAGS}")
endif ()

# ensure we have the minimum of SSSE3 - call a SSSE3 intrinsic
CHECK_C_SOURCE_COMPILES("#include <${INTRIN_INC_H}>
#include <simde/x86/ssse3.h>
int main() {
    simde__m128i a = simde_mm_set1_epi8(1);
    (void)simde_mm_shuffle_epi8(a, a);
}" HAVE_SSSE3)

# now look for AVX2
CHECK_C_SOURCE_COMPILES("#include <${INTRIN_INC_H}>
#include <simde/x86/avx2.h>

int main(){
    simde__m256i z = simde_mm256_setzero_si256();
    (void)simde_mm256_xor_si256(z, z);
}" HAVE_AVX2)

# and now for AVX512
CHECK_C_SOURCE_COMPILES("#include <${INTRIN_INC_H}>
#if !defined(__AVX512BW__)
#error no avx512bw
#endif

int main(){
    __m512i z = _mm512_setzero_si512();
    (void)_mm512_abs_epi8(z);
}" HAVE_AVX512)

# and now for AVX512VBMI
CHECK_C_SOURCE_COMPILES("#include <${INTRIN_INC_H}>
#if !defined(__AVX512VBMI__)
#error no avx512vbmi
#endif

int main(){
    __m512i a = _mm512_set1_epi8(0xFF);
    __m512i idx = _mm512_set_epi64(3ULL, 2ULL, 1ULL, 0ULL, 7ULL, 6ULL, 5ULL, 4ULL);
    (void)_mm512_permutexvar_epi8(idx, a);
}" HAVE_AVX512VBMI)

if (FAT_RUNTIME)
    if (NOT HAVE_SSSE3)
        message(FATAL_ERROR "SSSE3 support required to build fat runtime")
    endif ()
    if (NOT HAVE_AVX2)
        message(FATAL_ERROR "AVX2 support required to build fat runtime")
    endif ()
    if (BUILD_AVX512 AND NOT HAVE_AVX512)
        message(FATAL_ERROR "AVX512 support requested but not supported")
    endif ()
else (NOT FAT_RUNTIME)
    if (NOT HAVE_AVX2)
        message(STATUS "Building without AVX2 support")
    endif ()
    if (NOT HAVE_AVX512)
        message(STATUS "Building without AVX512 support")
    endif ()
    if (NOT HAVE_SSSE3)
        message(FATAL_ERROR "A minimum of SSSE3 compiler support is required")
    endif ()
endif ()

unset (CMAKE_REQUIRED_FLAGS)
unset (INTRIN_INC_H)

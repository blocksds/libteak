// SPDX-License-Identifier: Zlib
// SPDX-FileNotice: Modified from the original version by the BlocksDS project.
//
// Copyright (C) 2017-2018 Dave Murphy (WinterMute)

#ifndef LIBNDS_ASMINC_H__
#define LIBNDS_ASMINC_H__

#if !__ASSEMBLER__
#    error "This header file is only for use in assembly files!"
#endif

// clang-format off

.macro BEGIN_ASM_FUNC name section=text
    .section .\section\().\name\(), "ax", %progbits
    .global \name
    .type \name, %function
\name:
.endm

// clang-format on

#endif // LIBNDS_ASMINC_H__

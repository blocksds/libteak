// SPDX-License-Identifier: Zlib
// SPDX-FileNotice: Modified from the original version by the BlocksDS project.
//
// Copyright (C) 2020 Gericom
// Copyright (C) 2023 Antonio Niño Díaz

#include <teak/cpuregs.h>

#define BIT(n)                          (1 << (n))

#define ICU_IRQ_MASK_TMR0               BIT(10)

#define REG_ICU_IRQ_REQ                 0x8204

// Vector table
// ------------

.section .text.start

.global _start
_start:

    br      start, always               // 0x00000
    br      trapHandlerAsm, always      // 0x00002
    br      nmiHandlerAsm, always       // 0x00004
    br      irqHandlerInt0Asm, always   // 0x00006
    nop
    nop
    nop
    nop
    nop
    nop
    br      irqHandlerInt1Asm, always   // 0x0000E
    nop
    nop
    nop
    nop
    nop
    nop
    br      irqHandlerInt2Asm, always   // 0x00016

.text

// Start of the boot code
// ----------------------

start:

    dint
    mov     (MOD3_IRQ_DISABLE | MOD3_STACK_ORDER_NORMAL), mod3

    // prpage isn't used in DSi code because there are only 64 kilowords of
    // code in the available address space. The following two nops ensure that
    // the write is in effect.
    mov     0, prpage
    nop
    nop

    // Allocate space for the stack
    mov     0, sp
    addv    0x4ff, sp

    // Set default values to config registers
    mov     (MOD3_IRQ_DISABLE | MOD3_STACK_ORDER_NORMAL), mod3
    call    initConfigRegs, always
    call    initConfigRegsShadow, always

    // Make sure that interrupts are disabled before jumping to the user code
    dint
    call    main, always

exit:
    br      exit, always

// Initialize config registers to some default values
// --------------------------------------------------

initConfigRegs:

    rst     (MOD0_SATURATION_MASK | MOD0_SATURATION_STORE_MASK | \
             MOD0_HW_MUL_MASK | MOD0_SHIFT_MODE_MASK | \
             MOD0_PRODUCT_SHIFTER_P0_MASK | MOD0_PRODUCT_SHIFTER_P1_MASK), mod0
    set     (MOD0_SATURATION_ON | MOD0_SATURATION_STORE_ON), mod0
    load    0u8, page
    rst     (MOD1_BANKE_OPCODE | MOD1_EPI | MOD1_EPJ), mod1
    set     MOD1_MODULO_MODE_TL1, mod1
    mov     0, mod2
    mov     0, cfgi
    mov     0, cfgj
    mov     0, stepi0
    mov     0, stepj0
    mov     (AR0_PM1_POST_MODIFY_STEP_P2 | AR0_CS1_OFFSET_P1 | \
             AR0_PM0_POST_MODIFY_STEP_P0 | AR0_CS0_OFFSET_P1 | \
             AR0_RN1_REGISTER_Rn(4) | AR0_RN0_REGISTER_Rn(0)), ar0
    mov     (AR1_PM3_POST_MODIFY_STEP_PS | AR1_CS3_OFFSET_P1 | \
             AR1_PM2_POST_MODIFY_STEP_M2 | AR1_CS2_OFFSET_P1 | \
             AR1_RN3_REGISTER_Rn(5) | AR1_RN2_REGISTER_Rn(2)), ar1
    mov     (ARPn_PMIn_POST_MODIFY_STEP_P1 | ARPn_CIn_OFFSET_P0 | \
             ARPn_PMJn_POST_MODIFY_STEP_P1 | ARPn_CJn_OFFSET_P0 | \
             ARPn_RIn_REGISTER_Rn(0) | ARPn_RJn_REGISTER_Rn(4)), arp0
    mov     (ARPn_PMIn_POST_MODIFY_STEP_P2 | ARPn_CIn_OFFSET_P1 | \
             ARPn_PMJn_POST_MODIFY_STEP_P2 | ARPn_CJn_OFFSET_P1 | \
             ARPn_RIn_REGISTER_Rn(1) | ARPn_RJn_REGISTER_Rn(5)), arp1
    mov     (ARPn_PMIn_POST_MODIFY_STEP_M2 | ARPn_CIn_OFFSET_M1 | \
             ARPn_PMJn_POST_MODIFY_STEP_M2 | ARPn_CJn_OFFSET_M1 | \
             ARPn_RIn_REGISTER_Rn(2) | ARPn_RJn_REGISTER_Rn(6)), arp2
    mov     (ARPn_PMIn_POST_MODIFY_STEP_M1 | ARPn_CIn_OFFSET_P0 | \
             ARPn_PMJn_POST_MODIFY_STEP_M1 | ARPn_CJn_OFFSET_P0 | \
             ARPn_RIn_REGISTER_Rn(1) | ARPn_RJn_REGISTER_Rn(4)), arp3
    ret     always

// Initialize shadow config registers to some default values
// ---------------------------------------------------------

initConfigRegsShadow:

    cntx    s
    mov     (ST0_SATURATION_ON | ST0_IRQ_DISABLE | ST0_IRQ_INT0_DISABLE | \
             ST0_IRQ_INT1_DISABLE), st0
    mov     (ST1_DATA_MEMORY_PAGE(0) | ST1_PRODUCT_SHIFTER_P0_OFF), st1
    mov     (ST2_IRQ_INT2_DISABLE | ST2_SHIFT_MODE_ARITHMETIC), st2
    mov     (AR0_PM1_POST_MODIFY_STEP_P2 | AR0_CS1_OFFSET_P1 | \
             AR0_PM0_POST_MODIFY_STEP_P0 | AR0_CS0_OFFSET_P1 | \
             AR0_RN1_REGISTER_Rn(4) | AR0_RN0_REGISTER_Rn(0)), ar0
    mov     (AR1_PM3_POST_MODIFY_STEP_PS | AR1_CS3_OFFSET_P1 | \
             AR1_PM2_POST_MODIFY_STEP_M2 | AR1_CS2_OFFSET_P1 | \
             AR1_RN3_REGISTER_Rn(5) | AR1_RN2_REGISTER_Rn(2)), ar1
    mov     (ARPn_PMIn_POST_MODIFY_STEP_P1 | ARPn_CIn_OFFSET_P0 | \
             ARPn_PMJn_POST_MODIFY_STEP_P1 | ARPn_CJn_OFFSET_P0 | \
             ARPn_RIn_REGISTER_Rn(0) | ARPn_RJn_REGISTER_Rn(4)), arp0
    mov     (ARPn_PMIn_POST_MODIFY_STEP_P2 | ARPn_CIn_OFFSET_P1 | \
             ARPn_PMJn_POST_MODIFY_STEP_P2 | ARPn_CJn_OFFSET_P1 | \
             ARPn_RIn_REGISTER_Rn(1) | ARPn_RJn_REGISTER_Rn(5)), arp1
    mov     (ARPn_PMIn_POST_MODIFY_STEP_M2 | ARPn_CIn_OFFSET_M1 | \
             ARPn_PMJn_POST_MODIFY_STEP_M2 | ARPn_CJn_OFFSET_M1 | \
             ARPn_RIn_REGISTER_Rn(2) | ARPn_RJn_REGISTER_Rn(6)), arp2
    mov     (ARPn_PMIn_POST_MODIFY_STEP_M1 | ARPn_CIn_OFFSET_P0 | \
             ARPn_PMJn_POST_MODIFY_STEP_M1 | ARPn_CJn_OFFSET_P0 | \
             ARPn_RIn_REGISTER_Rn(1) | ARPn_RJn_REGISTER_Rn(4)), arp3
    cntx    r
    ret     always

// Global NMI handler
// ------------------

    .global nmiHandlerAsm
    .weak nmiHandlerAsm
nmiHandlerAsm:

    cntx    s
    rst     MOD0_SHIFT_MODE_MASK, mod0 // Set mode arithmetic
    retic   always

// Trap handler that converts the trap to a timer 0 IRQ
// ----------------------------------------------------

    .global trapHandlerAsm
    .weak trapHandlerAsm
trapHandlerAsm:

    push    stt0
    push    r0

    // Convert this trap to a proper timer 0 IRQ that can be routed
    mov     REG_ICU_IRQ_REQ, r0
    set     ICU_IRQ_MASK_TMR0, [r0] // Set and clear the bit
    rst     ICU_IRQ_MASK_TMR0, [r0]

    pop     r0
    pop     stt0
    reti    always

// Global interrupt handler for INT0
// ---------------------------------

    .global irqHandlerInt0Asm
    .weak irqHandlerInt0Asm
irqHandlerInt0Asm:

    cntx    s
    load    0, ps01
    rst     MOD0_SHIFT_MODE_MASK, mod0 // Set mode arithmetic
    push    a0e
    pusha   a0
    push    a1e
    pusha   a1
    push    b0e
    pusha   b0
    push    b1e
    pusha   b1
    push    p0
    push    p1
    push    sv
    push    r0

    call    irqHandlerInt0, always

    pop     r0
    pop     sv
    pop     p1
    pop     p0
    popa    b1
    pop     b1e
    popa    b0
    pop     b0e
    popa    a1
    pop     a1e
    popa    a0
    pop     a0e
    retic   always

// Global interrupt handler for INT1
// ---------------------------------

    .global irqHandlerInt1Asm
    .weak irqHandlerInt1Asm
irqHandlerInt1Asm:

    cntx    s
    load    0, ps01
    rst     MOD0_SHIFT_MODE_MASK, mod0 // Set mode arithmetic
    push    a0e
    pusha   a0
    push    a1e
    pusha   a1
    push    b0e
    pusha   b0
    push    b1e
    pusha   b1
    push    p0
    push    p1
    push    sv
    push    r0

    call    irqHandlerInt1, always

    pop     r0
    pop     sv
    pop     p1
    pop     p0
    popa    b1
    pop     b1e
    popa    b0
    pop     b0e
    popa    a1
    pop     a1e
    popa    a0
    pop     a0e
    retic   always

// Global interrupt handler for INT2
// ---------------------------------

    .global irqHandlerInt2Asm
    .weak irqHandlerInt2Asm
irqHandlerInt2Asm:

    cntx    s
    load    0, ps01
    rst     MOD0_SHIFT_MODE_MASK, mod0 // Set mode arithmetic
    push    a0e
    pusha   a0
    push    a1e
    pusha   a1
    push    b0e
    pusha   b0
    push    b1e
    pusha   b1
    push    p0
    push    p1
    push    sv
    push    r0

    call    irqHandlerInt2, always

    pop     r0
    pop     sv
    pop     p1
    pop     p0
    popa    b1
    pop     b1e
    popa    b0
    pop     b0e
    popa    a1
    pop     a1e
    popa    a0
    pop     a0e
    retic   always

// Default trap handler
// --------------------

    .global trapHandler
    .weak trapHandler
trapHandler:

    ret     always

// Default INT0 IRQ handler
// ------------------------

    .global irqHandlerInt0
    .weak irqHandlerInt0
irqHandlerInt0:

    ret     always

// Default INT1 IRQ handler
// ------------------------

    .global irqHandlerInt1
    .weak irqHandlerInt1
irqHandlerInt1:

    ret     always

// Default INT2 IRQ handler
// ------------------------

    .global irqHandlerInt2
    .weak irqHandlerInt2
irqHandlerInt2:

    ret     always

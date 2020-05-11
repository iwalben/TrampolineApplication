//
//  Trampolinetemplate.s
//  TrampolineApplication
//
//  Created by iwalben on 2020/5/7.
//  Copyright © 2020 WM. All rights reserved.
//


#if __arm64__

#include <mach/vm_param.h>

.text
.align PAGE_MAX_SHIFT
.globl _trampolinetemplate

dosomething:
.quad 0

.align PAGE_MAX_SHIFT
_trampolinetemplate:

nop

mov x2, x1
mov x1, x0
ldr x0, PAGE_MAX_SIZE - 12
ldr x3, PAGE_MAX_SIZE - 8
br x3



#endif

//
//  ViewController.m
//  TrampolineApplication
//
//  Created by iwalben on 2020/5/7.
//  Copyright © 2020 WM. All rights reserved.
//

#import "ViewController.h"

#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>


extern void *trampolinetemplate;

typedef struct
{
    int age;
    char *name;
}student_t;

//按年龄升序排列的函数
int  ageidxcomparfn(student_t students[], const int *idx1ptr, const int *idx2ptr)
{
    return students[*idx1ptr].age - students[*idx2ptr].age;
}


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vm_address_t thunkaddr = 0;
    vm_size_t page_size = 0;
    host_page_size(mach_host_self(), &page_size);
    //分配2页虚拟内存，
    kern_return_t ret = vm_allocate(mach_task_self(), &thunkaddr, page_size * 2, VM_FLAGS_ANYWHERE);
    if (ret == KERN_SUCCESS)
    {
        //第一页用来重映射到thunktemplate地址处。
        vm_prot_t cur,max;
        ret = vm_remap(mach_task_self(), &thunkaddr, page_size, 0, VM_FLAGS_FIXED | VM_FLAGS_OVERWRITE, mach_task_self(), (vm_address_t)&trampolinetemplate, false, &cur, &max, VM_INHERIT_SHARE);
        if (ret == KERN_SUCCESS)
        {
            student_t students[5] = {{20,"Tom"},{15,"Jack"},{30,"Bob"},{10,"Lily"},{30,"Joe"}};
            int idxs[5] = {0,1,2,3,4};
            
            //第二页的对应位置填充数据。
            void **p = (void**)(thunkaddr + page_size);
            p[0] = students;
            p[1] = ageidxcomparfn;
            
            //将thunkaddr作为回调函数的地址。
            qsort(idxs, 5, sizeof(int), (int (*)(const void*, const void*))thunkaddr);
            for (int i = 0; i < 5; i++)
            {
                printf("student:[age:%d, name:%s]\n", students[idxs[i]].age, students[idxs[i]].name);
            }
        }
        
        vm_deallocate(mach_task_self(), thunkaddr, page_size * 2);
    }
}






@end

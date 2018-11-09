## 脑外伤病人删除过程

1. 总实例数为2862人
2. 删除年龄为18岁以下的人39人
3. 删除入住icu小于24小时的人，536
4. 删除没有尿量评级的人，共523个
5. 删除没有肌酐评级的人，共6个
6. esrd: 110

现在总计：1758个

## 特殊变量描述

1. stage_rifie_7day_admin_uo: rifie根据尿量评级
2. stage_kdigo_7day_admin_uo: kdigo根据尿量评级
3. stage_kdigo_creat_by_min: kdigo根据肌酐最大值比最小值评级
4. stage_rifie_creat_by_min：rifie根据肌酐最大值比最小值评级
5. stage_kdigo_by_min：kdigo有限制的根据尿量和肌酐评级
6. stage_rifie_by_min：rifie有限制的根据尿量和肌酐评级
7. stage_kdigo_by_min_without_limit: kdigo无限制根据尿量和肌酐评级
8. stage_rifie_by_min_without_limit: rifie无限制根据尿量和肌酐评级
9. has_kdigo_by_min: 是否达到有限制的kdigo最低评级标准
10. has_kdigo_by_min_without_limit: 是否达到无限制的kdigo最低评级标准


注：有限制和无限制的区别在于有限制的必须要求肌酐大于等于1，尿量的评级才生效
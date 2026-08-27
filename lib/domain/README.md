# domain/（预留）

卦眼 2.0 领域模型属于下一阶段 **GUAYAN-2.0-DOMAIN**，本阶段不实现。

将在此建立：

- `HexagramCase`
- `LineState`
- `RelationInstance`
- `RelationNote`
- `CalendarInput`
- `GanzhiSnapshot`

关键设计目标：为 `RelationInstance` 获得稳定身份，从架构根部保证关系重算时
Relation Note 不丢（原总计划 Gate C）。

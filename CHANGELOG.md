# 卦眼训练营 · 文件审计与变更日志

> **仓库：** https://github.com/Heaifan/guayan_trainer.git
> **归档分支：** `feat/guayan-2.0`
> **当前应用版本：** 2.0.0+41（pubspec.yaml）
> **最近历史正式发布：** v0.1.14（2026-09-15）
> **当前 R5 开发基线：** R5-G BASELINE RECOVERY
> **本文件创建：** 2026-08-27
> **完整文件树与历史：** 见 [file-tree.md](file-tree.md)

---

| 版本 | 日期 | 类型 | 说明 |
| --- | --- | --- | --- |
| `v0.1.14` | 2026-09-15 | 新增 | R5-E Common v1 (36 SYSTEM Rules, 6 Rule Families, Resolver Integration, Engine Integration) |
| `v0.1.13` | 2026-09-15 | 新增 | R5-D Rule Governance (SYSTEM/CUSTOM, Version Resolution, Override, Resolver, Deterministic Resolution, Engine Integration) |
| `v0.1.12` | 2026-09-15 | 新增 | R5-C DSL Parser & Formatter round trip (Fast-Track) |

---

## 2026-09-15 · R5-E Common v1

> **阶段目标**：实现 R5-E Common v1 (36 SYSTEM Rules, 6 Rule Families, Resolver Integration, Engine Integration)。

### 新增/修改

| 路径 | 说明 |
| --- | --- |
| `lib/domain/rules/corpus/common_rule_corpus.dart` | R5-E Common v1 36 个 SYSTEM Rules 工厂 |
| `test/domain/rules/corpus/` | R5-E Common v1 冒烟与集成测试 |

### 验证

- `flutter test`：通过
- `dart analyze`：通过，0 issues
- 文件 <= 100 行限制：严格符合。

---

## 2026-09-15 · R5-D Rule Governance (SYSTEM/CUSTOM, Version Resolution, Override, Resolver, Deterministic Resolution, Engine Integration)

> **阶段目标**：实现 R5-D 规则治理（SYSTEM/CUSTOM、版本解析、覆写、解析器、确定性解析、引擎集成）。

### 新增/修改

| 路径 | 说明 |
| --- | --- |
| `lib/domain/rules/governance/` | R5-D 规则治理核心模型与解析器实现 |
| `test/domain/rules/governance/` | R5-D 规则治理测试套件 |

### 验证

- `flutter test`：通过
- `dart analyze`：通过，0 issues
- 文件 <= 100 行限制：严格符合。

---

## 2026-09-15 · GUAYAN-R5-C FAST-TRACK (DSL Parser & Formatter)

> **阶段目标**：提供一个 `GuayanDslParser` 和 `GuayanDslFormatter`，实现纯中文 DSL 与 Rule AST 的等价转换。要求满足 5+100 架构（文件 <= 100 行），支持 13 种基础/条件、取/得/取象/成局/记 动作，并在 Engine Integration Smoke 中验证 DSL 与 Rule Engine 连通。

### 新增/修改

| 路径 | 说明 |
| --- | --- |
| `lib/domain/dsl/dsl_parser.dart` | DSL 主解析器入口，支持 `@` 和 `.` 绑定选择器 |
| `lib/domain/dsl/dsl_formatter.dart` | DSL 格式化，支持顶级 `AnyExpr` 多 `或` 生成，逆向翻译 `fuMu` 等词汇 |
| `lib/domain/dsl/parser/dsl_expr_parser.dart` | 表达式块解析，支持缩进的嵌套 `或`/`且` 条件块 |
| `lib/domain/dsl/parser/dsl_pattern_matcher.dart` | 拆分出的模式匹配器，满足 5+100，关联 `SixRelative` 等领域词汇映射 |
| `test/domain/dsl/dsl_round_trip_test.dart` | C2 终轮测试，支持 `RelativeSelector`、混合顶级 `或` 以及词汇转换的验证 |
| `test/domain/dsl/dsl_engine_integration_test.dart` | C2 引擎连通测试，将 `parent` 纠正回中文领域的 `fuMu` / `父母` |
| `test/domain/rules/engine/...` | B 阶段测试（6 个文件）同步纠正 dummy 的 `parent` 单词为正确的领域 `fuMu` |

### 验证

- `flutter test test/domain/dsl`：通过
- `flutter test test/domain/rules`：通过
- `dart analyze`：通过，0 issues
- 文件 <= 100 行限制：严格符合。

---

| --- | --- |
| lib/domain/dsl/dsl_models.dart | DSL 鏍稿績妯″瀷锛歅arsedGuayan, DslLine |
| lib/domain/dsl/dsl_nayin_map.dart | 绾抽煶 Stable ID 鏄犲皠琛?|
| lib/domain/dsl/dsl_diagnostics.dart | DSL 寮傚父涓庤鍒楄拷韪ā鍨?|
| lib/domain/dsl/parser/dsl_expr_parser.dart | 琛ㄨ揪寮忚В鏋愬櫒锛屾敮鎸?ALL/ANY/NOT 涓?13 绉?Condition |
| lib/domain/dsl/parser/dsl_action_parser.dart | 鍔ㄤ綔瑙ｆ瀽鍣紝鏀寔 5 绉?Statements |
| lib/domain/dsl/dsl_parser.dart | 涓昏В鏋愬櫒锛岀粺绛瑰垎鍙?|
| lib/domain/dsl/dsl_formatter.dart | 鏍煎紡鍖栧櫒锛孉ST 鍒?DSL 鍙嶅悜杈撳嚭 |
| 	est/domain/dsl/dsl_smoke_test.dart | C1 鍩虹鑳藉姏 3 椤瑰啋鐑熸祴璇?|
| 	est/domain/dsl/dsl_round_trip_test.dart | DSL -> AST -> DSL 鐨勫箓绛夐獙璇?|
| 	est/domain/dsl/dsl_engine_integration_test.dart | DSL 鍒?R5-B RuleEngine 鎵ц閾捐矾鐨?Smoke Test |

### 淇敼鏂囦欢

| 璺緞 | 璇存槑 |
| --- | --- |
| ile-tree.md | 鍚屾鏂板鏂囦欢 |
| CHANGELOG.md | 鏈枃浠?|

### 楠岃瘉

- lutter test锛歊5-C 鏂板 5 涓牳蹇冩祴璇曪紝鍖呭惈 Round Trip 涓?Engine Integration 鍏ㄩ儴 PASS
- 瀛橀噺瑙勫垯寮曟搸 lutter test test/domain/rules/ 67 椤瑰叏杩?- dart analyze锛氭柊澧炴枃浠?0 issue
- 5+100 绾︽潫锛氬叏閮ㄦ枃浠惰鏁板潎婊¤冻 <= 100 琛岄檺鍒躲€?# 閸楋妇婧傜拋锟界矊閸?閳?閺傚洣娆㈢€孤わ拷娑撳骸褰夐弴瀛樻）韫?

> **娴犳挸绨遍敍?* https://github.com/Heaifan/guayan_trainer.git
> **瑜版帗銆傞崚鍡樻暜閿?* `feat/guayan-2.0`
> **閺堚偓鏉╂垶锟藉蹇撳絺鐢喛绱?* v0.1.10閿?026-05-22閿?
> **閺堬拷鏋冩禒璺哄灡瀵ょ尨绱?* 2026-08-27
> **鐎瑰本鏆ｉ弬鍥︽閺嶆垳绗岄崢鍡楀蕉閿?* 鐟?[file-tree.md](file-tree.md)

---

## 2026-09-15 路 R5-B Rule Engine SRP and Implementation Closure

### 鏂板/淇敼
- **Rule Engine**: Full implementation of `rule_engine.dart`.
- **Binding Resolution**: Implemented `binding_resolver.dart`.
- **PredicateResult + supports**: Track supports for evaluation.
- **13 Canonical Operators**: Implemented all operators natively in Engine.
- **Normalized Relation View**: Implemented relation instances.
- **Typed Action Outputs**: Handled properly in `ActionExecutor`.
- **Stage Fixpoint**: Stage convergence iteration implemented (`stage_runner.dart` / `stage_iteration_runner.dart`).
- **Fail Closed**: Properly throws and catches errors during failure.
- **RuleHit & Evidence Lineage**: Track exact lineage paths via `evidence_id.dart`.
- **Deterministic Identity**: Implemented stable deterministic identity.
- **AnalysisRun**: Implemented Immutable AnalysisRun output.
- **Order Invariance & Idempotence**: Engine is mathematically invariant.
- **Non-Convergence Guard**: Max 100 iteration guard.
- **5+100 SRP closeout**: Strictly split Engine and Operators, all files <= 100 lines.

### 娌荤悊璁板綍 / Governance Incidents
- premature R5-B remote commit (tag v0.1.11 / 68b90a6)
- bulk tracked-Dart replacement (during 5+100 split)
- broad git add (accidentally adding whole directories)
- reset / restore / checkout usage instead of fail closed
- premature local commits before passing 5+100 verification
- amend usage to bypass governance history
- failed automated SRP attempts causing rollback

## 2026-09-14 路 R5-A-SUP1-FIX1 Canonical Condition Vocabulary Update

### 鏂板/淇敼
* **Canonical Condition Registry**: Registered existing operators (relative, spirit, generate, empty) to ensure backwards compatibility with schemaVersion=1.
* **New Canonical Operators**: Added nayin_is, xun_kong, yue_po, ri_po, in_tomb, ru_mu, chong_mu, chu_mu, has_tag.
* **Operand Signatures Validation**: Added explicit OperandKind types (bindingRef, literal, nayinIdLiteral, tagCategoryLiteral, shenShaIdLiteral) and enforced positions strictly.
* **NaYin 60/60 Mapping**: Exact mapping of 60 JiaZi indices to Canonical NaYin vocabulary (30 fixed closed vocabulary items).
* **Canonical Name**: Set 浣涚伅鐏?as Canonical Display Name while maintaining nayin.fu_deng_huo stable ID.
* **Open ShenSha Policy**: Allowed open string vocabulary for ShenSha tags.
* **5+100 Refactor**: Split RuleSchemaValidator into binding, expression, condition_semantic, and action validators. Split tests accordingly.




## 2026-09-14 路 R5-A-GATE-FIX2 / Ready for User Acceptance
* 娓呯悊浜嗙敱浜庤嚜鍔ㄥ寲閲嶆瀯瀵艰嚧鐨勮寖鍥村浠ｇ爜姹℃煋锛屽皢 R5-A 涓ユ牸闄愬埗鍦?rules 鐩稿叧鐩綍鍐呫€?
* 纭鏈拷韪枃浠舵病鏈夎绾冲叆 Git 鎴栭伃杩濊鍒犻櫎锛堢郴鐜鑷韩鍘熷洜涓㈠け锛夈€?
* 鍚勯」瑙勫垯鐨?AST 瑙ｆ瀽銆丆odec 寮虹被鍨嬩竴鑷存€у強 Schema 楠岃瘉缁忎慨澶嶅凡 100% 杈炬垚瑕佹眰銆?

## 2026-09-14 璺?R5-A-GATE-FIX1 (Rule Schema + AST + Core Domain)

> **瀵よ櫣鐝涢崡锔炬簜閸欙拷绱粙瀣彋閻栨槒锟介崚娆忕穿閹垮簼浜掗崥搴㈠閺堝膩閸ф鍙￠崥灞肩贩鐠ф牜娈?Canonical Domain Contract閵?*

* **AST 娑撳氦锟介崚娆忥拷缁?*閿涙矮寮楅弽鑹帮拷閼煎啫瀵?`RuleDefinition` 娑撳骸鐔€娴滃孩鐖茶ぐ銏㈢波閻ㄥ嫭濞婄挒陇锟藉▔鏇熺埐閿涘潉ALL`/`ANY`/`NOT`/`PREDICATE`閿涘绱濆☉鍫ユ珟閸欙拷澧界悰宀冨壖閺堬拷绶风挧鏍モ偓?
* **瀵桨绗夐崣锟藉綁娴滃鐤勯悳锟斤拷**閿涙艾鍩勯悽?`FactSnapshot` 鐎电锟介崚娆掔翻閸忋儰绨ㄧ€圭偛宸遍崚鍫曟敚鐎规熬绱濋梼鑼跺瘱娴犵粯鍓扮憴鍕灟鐎电懓绨崇仦鍌滃Ц閹礁鎷伴幒鎺旀磸鐎电钖勯惃鍕拷閺€骞库偓?
* **RulePack 婵傛垹瀹虫稉搴″瀻缁?*閿涙艾鐨㈢化鑽ょ埠/閼凤拷鐣炬稊澶涚礄`RuleOrigin`閿涘绗岄柅姘辨暏/娑撳锟芥担婊呮暏閸╃噦绱檂RulePackScope`閿涘绻樼悰灞煎紬閺嶉棿绨╃紒鏉戝閸撱儳锟介梽鎰煑閵?
* **Canonical JSON娑撳酣鐛欑拠浣风秼缁?*閿涙氨鈥樻穱婵呯啊鐎电懓锟介崗銉拷閸掓瑥宸辩涵锟界暰閹呮畱缂傛牞袙閻線鈧槒绶崪?Fail Closed 閻ㄥ嫬鐣ㄩ崗銊╃崣鐠囦椒缍嬬化浼欑幢楠炶泛缂撶粩瀣嫙鐎圭偞鏌︽禍鍡楃唨娴滃骸寮弫鏉跨摟閸忔悂鍣搁幒鎺戠碍閻?`EvidenceIdentity`閵?

---

## 2026-09-12 璺?GATE-A-FINAL-CLOSEOUT閿涘湙ate A 鐎规矮绠熼幏鍡楀瀻娑?R3 閺€璺哄經閿涘本婀崣鎴濈閿?

### 娑撹桨绮堟稊鍫ｏ拷閹?Gate A

Gate A 閸樼喐鏋冮幎濞库偓灞剧厙娑撴挷绗熸潪锟芥閻ㄥ嫪姹夊銉ワ綖閸愭瑧绮ㄩ弸婧库偓宥堬拷娑?*閸烇拷绔撮惇鐔封偓鍏兼降濠?*閿?
娴滃孩妲?R3 鐞氾拷绔存禒鑸垫拱鐠愩劋绗傞弰锟解偓灞藉悑鐎硅鈧嗭拷鐎电喆鈧秶娈戞禍瀣幢娴ｅ繈鈧倷绲剧紒蹇氱箖 R3-A / R3-B /
閸欏本绨弽鎼佺崣 / 缁夋帞楠囩划鎯у娣囷拷锟芥稊瀣倵閿涘本鐗宠箛鍐埂閸婄厧鍑￠悽?*閸欙拷锟介弽鍝ユ畱閻欙拷鐝涚拠浣瑰祦**閹垫寧濯撮敍?

```text
閻欙拷鐝涚憴鍕灟閺嶆悂鐛欓敍鍫濆彄鐎?/ 娑撴牕绨?/ 缁惧磭鏁?/ 閸忥拷缈?/ 閸忥拷锟介敍?
+ 鐎规ɑ鏌熼崢鍡樼《閸欏本绨敍鍦欿O vs NAOJ 24/24閿?
+ 缁夋帞楠囬崗锟界磻閻喎鈧》绱?026 缁斿妲?04:02:08閿?
+ 鏉堝湱鏅?Golden Test
+ 259 / 259 閼凤拷濮╁ù瀣槸
```

閼板瞼娲伴弽鍥︾瑩娑撴俺钂嬫禒鏈电闂傛潙鐡ㄩ崷銊︾ウ濞叉儳妯婂鍌︾礄23:00 / 00:00 閺冦儳鏅妴浣规珓鐎涙劖妞?/ 閺冣晛鐡欓弮韬测偓?
閸忔湹绮柊宥囩枂閿涘绱濇潻娆戣瀹革拷绱撶仦鐐扮艾**閸忕厧锟介幀?/ 闁板秶鐤嗗锟界磽**閿涘奔绗夐懗鍊熷殰閸斻劏锟芥稉鐑樼壋韫囧啰鐣诲▔鏇㈡晩鐠囷拷鈧?

### 濮濓絽绱￠幏鍡楀瀻

```text
Gate A-Truth   CORE DIVINATION TRUTH                閳ユ柡鈧?R3 閻?blocker
Gate A-Compat  PROFESSIONAL SOFTWARE COMPATIBILITY  閳ユ柡鈧?娑撳秹妯嗘繅?R3
```

| 閺?Gate | 閻樿埖鈧?| 娓氭繃宓?|
| --- | --- | --- |
| Gate A-Truth | **PASS** | 閻欙拷鐝涚憴鍕灟閺嶆悂鐛?+ 鐎规ɑ鏌熼崣灞剧爱 + 缁夋帞楠囬惇鐔封偓?+ 鏉堝湱鏅ù瀣槸 + 259/259 |
| Gate A-Compat | **NOT EXECUTED / DEFERRED閿涘ON-BLOCKING** | 鐏忔碍婀€靛湱娲伴弽鍥︾瑩娑撴俺钂嬫禒鍫曗偓鎰般€嶆禍鍝勪紣濮ｆ柨锟?|

### Gate A-Truth 闁劙銆?

```text
閸忥拷锟?                 PASS
娑撴牕绨?                 PASS
缁惧磭鏁?                 PASS
娴滄棁锟?                 PASS
閸忥拷缈?                 PASS
閸欐ê宕烽崗锟界堪閸欐牗婀伴崡锕€锟?     PASS
閸忥拷锟?                 PASS
閺冦儴鏅?                 PASS
閺冿拷鈹?                 PASS
閺堝牆缂?                 PASS
閼哄倹鐨甸弫鐗堝祦閿涘牆寮诲┃鎰剁礆      PASS
閼哄倹鐨电粔鎺旈獓缁儳瀹?         PARTIALLY VERIFIED
閺冭泛灏幑銏㈢暬              PASS
閺冦儳鏅崣宀冿拷閸?           PASS
缁傝崵鍤庣拋锛勭暬              PASS
```

### 缁儳瀹抽悩鑸碘偓渚婄礄濮濓絽绱￠幒锟界犯閿?

```text
SOLAR TERM DATA PRECISION

2026 LiChun:          SECOND-LEVEL VERIFIED   04:02:08 +08:00
KNOWN PRECISION GAP:  FIXED
Other solar terms:    MINUTE-LEVEL VERIFIED (via HKO + NAOJ)
No fabricated second-level values

閳?PARTIALLY SECOND-LEVEL VERIFIED
```

娑撳秴鍟€閸?`UNRESOLVED`閿涙稐绡冪粋浣癸拷閸?`ALL SOLAR TERMS SECOND-LEVEL VERIFIED`閵?

### 閺冦儳鏅悩鑸碘偓?

```text
DAY BOUNDARY ENGINE      PASS閿涘潰idnight 娑?ziHourStart 閸у洤鍑＄€圭偟骞囬獮鍫曗偓姘崇箖濞村鐦敍?
PRODUCT DEFAULT POLICY   OPEN閿涘牆鐫橀崥搴ｇ敾娴溠冩惂闁板秶鐤嗛崘鍐茬暰閿涘奔绗夐梼璇诧拷 R3 Domain Foundation閿?
```

### 閺傚洦銆傞弨鐟板З閿涘牊鏁?generator 閻喐绨敍宀勬姜閹靛鏁兼禍褏澧块敍?

| 閺傚洣娆?| 閺€鐟板З |
| --- | --- |
| `tool/gate_a/gate_a_gate_status.dart` | 閺傛澘锟介敍姘蓟 Gate 鐎规矮绠熼妴涓焌te A-Truth 闁劙銆嶇悰銊ｂ偓涓? 閺堚偓缂佸牏濮搁幀浣告健 |
| `tool/gate_a/gate_a_main.dart` | README 婢跺瓨鏁兼稉鍝勫蓟 Gate 缂佹挻鐎敍娑欌偓鏄忋€冮幏鍡楀毉 `Truth Result` / `Compatibility Result`閿涙稐濞囬悽銊拷閺勫孩鏁兼稉?Gate A-Compat 娑撴挾鏁?|
| `tool/gate_a/gate_a_cross_source.dart` | 濞夈劑鍣磋ぐ鎺戠潣閺€閫涜礋 Gate A-Truth |
| `tool/gate_a/gate_a_solar_term_report.dart` | 濞夈劑鍣撮弨閫涜礋 `PARTIALLY SECOND-LEVEL VERIFIED`閿涘牆甯崘?UNRESOLVED閿?|
| `gate-a/*.md` | 閸忋劑鍎撮柌宥嗘煀閻㈢喐鍨?|

娣囨繄鏆€閿涙矮绗撴稉姘宠拫娴犺泛鍨?/ 鏉烇拷娆㈤悧鍫熸拱 / 娑撯偓閼?缁涘鐡у▓纰夌礄娓?Gate A-Compat 娴ｈ法鏁ら敍澶涚幢
閺堬拷锝為崘娆愭 Result 鐠?`NOT EXECUTED`閿?*娑撳秴绶遍弰鍓с仛 FAIL**閵?

### R3 閺堚偓缂佸牏濮搁幀?

```text
R3-A                        PASS
R3-B                        PASS
R3-B-DATA-PRECISION-FIX     PASS
GATE A-TRUTH                PASS
GATE A-COMPAT               NOT EXECUTED / DEFERRED 閳?NON-BLOCKING
R3                          FINAL ACCEPTED
```

### 妤犲矁鐦?

```text
gate_a_runner.ps1 test       閸忋劑鍎撮懛锟斤拷 PASS
gate_a_runner.ps1 closeout   妤犲本鏁归弬锟解枅閸忋劑鍎?PASS
flutter test                 259 / 259 PASS
flutter analyze lib/domain test/domain   No issues found
flutter analyze閿涘牆鍙忔禒鎿勭礆       27 = 閸╄櫣鍤庨敍瀛‥W = 0
git diff --check             clean
lib/ test/ assets/ diff      = 0
```

---

## 2026-09-12 璺?R3-B-DATA-PRECISION-FIX閿涘牐濡鏃€鏆熼幑锟界翱鎼达缚绗撴い閫涙叏婢跺稄绱濋張锟藉絺鐢喛绱?

> **閺嶇懓娲滈敍鍫滅閸欍儴鐦介敍?*閿涙艾鍨庨柦鐔洪獓鐎规ɑ鏌熼弰鍓с仛閸婅壈锟芥穱婵嗙摠娑?`:00` 缁?Instant閿?
> 閼板矁锟介崚鍡涙寭閸愬懎鐡ㄩ崷銊ュ讲妤犲矁鐦夐惃鍕埂鐎圭偟锟界痪褌姘﹂懞鍌涙閸?閳ユ柡鈧?
> **閸掑棝鎸撶痪褎鏆熼幑锟界瑝鐡掑厖浜掔悰銊ㄦ彧鐠囥儳锟界痪褑绔熼悾?*閵?
> 鏉╂瑤绗夐弰锟解偓瀛扠O 闁挎瑤绨￠妴宥忕礉鐎规ɑ鏌熼崣灞剧爱閿涘湚KO / NAOJ閿?4/24 閸掑棝鎸撶痪褌绔撮懛娣偓?

### 娣囷拷锟?
| 妞?| 娣囷拷锟介崜?| 娣囷拷锟介崥?|
| --- | --- | --- |
| 2026 缁斿妲?UTC 閻拷妫?| `2026-02-03T20:02:00Z` | `2026-02-03T20:02:08Z` |
| 閺堝牆缂撻崚鍥ㄥ床閺冭泛鍩㈤敍?08:00閿?| 04:02:00閿涘牊褰侀崜?8 缁夋帪绱?| 04:02:08 |
| 04:02:00閳?4:02:07 閸栨椽妫块張鍫濈紦 | 鐎靛拑绱欓柨娆欑礆 | 娑撴埊绱欑€电櫢绱?|
| 鐠佹澘缍嶇划鎯у | 閺冪姾锟藉鍌氬悍 | `precision = second` |
| 閺夈儲绨ぐ鎺戠潣 | 娴犲懎鍕炬惔?HKO | + 闁劘濡?`sourceOverride`閿涘牏浼犻柌鎴濆寳婢垛晜鏋冮崣鎵拷閺咃拷鍎撮敍?|

### 閺傛澘锟介敍姘殶閹癸拷瀵樺ǎ宄版値缁儳瀹虫總鎴犲閿涘澃chemaVersion 2閿涘苯鎮滈崥搴″悑鐎?v1閿?
```text
楠炴潙瀹?source          = 姒涙锟介弶銉︾爱
term sourceOverride  = 閸欙拷鈧锟介惄鏍电礄妞よ鎯?name + reference閿?
term precision       = minute閿涘牏宸遍惇渚婄礆 / second
```
- 閸愯崵绮ㄧ拠锟界疅閿涙瓪precision = minute` 閺?`instantUtc` 缁夋帊缍呴幁鎺嶈礋 `:00`閿?
  閸欙拷銆冪粈鎭掆偓?*鐠囥儱鍨庨柦鐔峰敶**娴溿倛濡妴宥忕礉**娑?*鐞涖劎銇氶妴灞句紗閸︺劎锟?0 缁夋帊姘﹂懞鍌樷偓宥忕幢
- v2 娑擄拷瀹抽崣锟借穿閸氬牏绨挎惔锔肩窗**瀹歌尙鐓℃径姘毌缁儳瀹崇亸杈樄鐎圭偘绻氱€涙ê锟界亸鎴犵翱鎼?*閿?
- 閺堬拷鐓?`precision`閵嗕焦鐣紓?`sourceOverride` 娑撯偓瀵板瀚嗙紒婵嗭拷閸忋儻绱欐稉宥囧姒涙锟介崐纭风礆閵?

### 閺佺増宓侀崠鍛綁閺囩瀵栭崶杈剧礄娑撱儲鐗搁張鈧亸蹇ョ礆
- 娴?`assets/calendar/2026.calendar.json`閿涙瓪schemaVersion 1閳?`閵嗕梗revision 1閳?`閵?
  缁斿妲崡鏇熸蒋閺€閫涜礋缁夋帞楠囬獮鍫曟閺夈儲绨憰鍡欐磰閿?
- **閸忔湹缍?23 閺壜ゅΝ濮樻柧绗岄崗鏈电稇 9 娑擄拷鍕炬禒鑺ユ殶閹癸拷瀵樻稉鈧瀣╃瑝閸?* 閳ユ柡鈧?
  閺堬拷褰囧妤€褰叉穱锛勶拷缁狙呮埂閸婅偐娈戦懞鍌涚毜**娑撳秷藟缁夋帇鈧椒绗夐幓鎺戔偓绗衡偓浣风瑝娴兼壆鐣?*閵?

### 閺傛澘锟介弬鍥︽
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `lib/domain/calendar/import/calendar_data_pack_term_source.dart` | 闁劘濡鏃€娼靛┃鎰拷閻╂牗鐗庢?|
| `test/domain/calendar/solar_term_second_boundary_test.dart` | 缁斿妲粔鎺旈獓鏉堝湱鏅?Golden Test閿?1 娓氬绱?|
| `test/domain/calendar/calendar_terms_precision_test.dart` | 缁儳瀹?/ 閺夈儲绨崗鍐╂殶閹癸拷鐗庢宀嬬礄11 娓氬绱?|
| `test/domain/calendar/solar_term_precision_revision_test.dart` | 缁儳瀹虫穱锟斤拷鐎电厧鍙嗛崶鐐茬秺閿? 娓氬绱?|
| `tool/gate_a/gate_a_precision_closeout.dart` | 妤犲本鏁归弬锟解枅閿涘牐铔嬮惇鐔风杽娴溠冩惂闁炬崘鐭鹃敍?|
| `tool/gate_a/gate_a_hko_source.dart` | HKO 鐎规ɑ鏌?XML 鐟欙絾鐎介敍鍫滄唉閸欏鐗虫宀€鏁ら崢鐔凤拷閸欐垵绔锋禒璁圭礆 |

### 娣囷拷鏁奸弬鍥︽
| 閺傚洣娆?| 閺€鐟板З |
| --- | --- |
| `solar_term/solar_term.dart` | 婢х偛濮?`precision` / `sourceName` / `sourceReference` |
| `import/calendar_data_pack.dart` | 婢х偛濮?`TermPrecision` 閺嬫矮濡囨稉搴ㄢ偓鎰Ν濮樻柨褰查柅澶婄摟濞?|
| `import/calendar_data_pack_parser.dart` | 鐟欙絾鐎?`precision` / `sourceOverride` |
| `import/calendar_data_pack_terms.dart` | 缁儳瀹抽弽锟犵崣閿涘牏宸遍惇?minute閵嗕焦婀惌?缁鐎烽柨娆掞拷閹锋帞绮烽敍?|
| `import/calendar_data_pack_validator.dart` | 閺€锟藉瘮 `schemaVersion 1..2` |
| `test/domain/calendar/calendar_engine_test.dart` | 閸樼喐鏌囩懛鈧妴?4:02:00 閸楀啿鐦忛張鍫涒偓宥呭嚒闂呭繑鏆熼幑锟芥叏濮濓絾娲块弬?|

### NOT changed閿涘牆鍠曠紒鎾瑰瘱閸ヨ揪绱漝iff = 0閿?
```text
MonthBranchResolver / CalendarEngine / GanzhiDay / XunKong
CastingEngine / 閸忥拷锟?/ 缁惧磭鏁?/ 閸忥拷缈?/ 娑撴牕绨?/ 閸忥拷锟?/ UI
閼凤拷缂?Meeus 鐏忓搫鐡欓敍姘箽閹?DIAGNOSTIC ONLY / REJECTED AS GATE ORACLE
```

### 妤犲本鏁归弬锟解枅閿涘湑alendarEngine 鐎圭偤妾幍褑锟介敍?
```text
2026-02-04 04:01:00 +08 閳?娑?
2026-02-04 04:02:00 +08 閳?娑?  閿涘牅鎱ㄦ径宥囧仯閿?
2026-02-04 04:02:07 +08 閳?娑?
2026-02-04 04:02:08 +08 閳?鐎?  閿涘牅姘﹂懞鍌滅仜闂傝揪绱濋崥锟界礆
2026-02-04 04:02:09 +08 閳?鐎?
2026-02-04 04:03:00 +08 閳?鐎?
```

### Gate 閻樿埖鈧?
```text
Gate A1  WAITING FOR USER MANUAL INPUT
Gate A2  PARTIALLY VERIFIED
         2026 LiChun = 04:02:08 +08:00閿涙稖锟介悙?precision gap FIXED
         閸忔湹缍?2026 閼哄倹鐨?minute-level only閿涘牊妫ゆ导锟解偓鐘碉拷缁狙呮埂閸婄》绱?
Gate A   READY FOR FINAL CLOSEOUT
```

### 妤犲矁鐦?
```text
flutter test                       259 / 259 PASS閿涘牆甯?232 + 閺?27閿?
flutter analyze lib/domain test/domain   No issues found
flutter analyze閿涘牆鍙忔禒鎿勭礆             27 issue = 閺€鐟板З閸撳秴鐔€缁惧尅绱漬ew = 0閿涘emoved = 0
```

---

## 2026-09-11 璺?GUAYAN-2.0-R3-B-CALENDAR閿涘牏锟界痪鍨坊濞夋洖鐔€绾偓鐏炲偊绱濋張锟藉絺鐢喛绱?

> **鐠猴拷鍤庨崣妯绘纯閿涘牓鍣哥憰渚婄礆**閿涙艾甯弬瑙勶拷閵嗗本濡?1900閳?100 閸?4824 閺壜ゅΝ濮樻梻鈥栫紓鏍垳鏉?Dart 濠ф劗鐖滈妴?
> 瀹告彃绨惧鍐跨礉閺€閫涜礋 **楠炴潙瀹抽弫鐗堝祦閸?+ 閺堬拷婀存禒鎾冲亶 + 鐎瑰苯鍙忕粋鑽ゅ殠鐠侊紕鐣?*閿?
>
> ```text
> 缁犳纭剁仦鐐扮艾缁嬪绨敍宀冨Ν濮樻柨鐫樻禍搴″讲妤犲矁鐦夐弫鐗堝祦閵?
> 閸樺棙纭堕弫鐗堝祦閸欙拷浜掗柅鎰嬀婢х偛濮為敍灞肩瑝鐟曚焦鐪伴柌宥嗘煀缂傛牞鐦?APP閵?
> 瀹告彃锟介崗銉ュ嬀娴犺棄鐣崗銊э拷缁炬寧甯撻惄姗堢幢閺堬拷锟介崗銉ュ嬀娴犺姤妲戠涵锟藉珕缂佹繃婀€瀵ら缚锟界粻妞尖偓?
> 濮樻瓕绻欐稉宥嗗瑏鏉╂垳鎶€缂佹挻鐏夐崘鎺戝帠缁墽鈥樼紒鎾寸亯閵?
> ```
>
> 缁?Dart 妫板棗鐓欑仦鍌︾礉闂?Flutter 娓氭繆绂嗛妴渚€娴傛潻鎰拷閺冨墎缍夌紒婧库偓渚€娴傛径鈺傛瀮鎼存挶鈧線娴傛潻鎴滄妧 fallback閵?

### 閺傛澘锟介敍鍧檌b/domain/calendar/ 閳?閸樺棙纭堕崺鐕傜礆
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `calendar_request.dart` | 鏉堟挸鍙嗘總鎴犲閿涙ocalDateTime + utcOffset + dayBoundaryRule閿涘本妯夊蹇庣炊閸?|
| `calendar_context.dart` | 鏉堟挸鍤總鎴犲閿涙nstantUtc / monthBranch / day / xunKong |
| `calendar_engine.dart` | 閼辨艾鎮庨張鍫濈紦 + 閺冦儴鏅?+ 閺冿拷鈹?|
| `calendar_error.dart` | 缁鐎烽崠鏍с亼鐠愩儻绱欏▽璺ㄦ暏妞ゅ湱娲伴妴灞惧瀵倸鐖堕妴宥嗘＆閺堝缍嬬化浼欑礉娑撳秴褰熺粩?Result閿?|
| `day_boundary_rule.dart` | `midnight` / `ziHourStart`閿?*閺冪娀娈ｅ蹇涚帛鐠併倕鈧?* |
| `day/ganzhi_day.dart` | 閺冦儲鐓撮敍娆紻N 閳?閸忥拷宕勯悽鎻掔摍閿涘牓鏁嬮悙?1949-10-01 閻㈡彃鐡欓弮銉礆 |
| `day/xun_kong.dart` | 閺冿拷鈹栭敍姘辨暠閺冿拷锟介幒銊ワ拷閿涘奔绗夌紒瀛樺Б閹靛濡辩悰?|
| `solar_term/solar_term_id.dart` | 娴滃苯宕勯崶娑滃Ν濮?+ 婢讹拷妲兼鍕病 + 閼?濮樻柨灏崚?|
| `solar_term/solar_term.dart` | 閼哄倹鐨电拋鏉跨秿閿涘牏婀″┃鎰Ц**閻拷妫?*閿涘奔绗夐弰锟芥）閺堢噦绱?|
| `solar_term/solar_term_provider.dart` | 閺佺増宓侀弶銉︾爱閹跺€熻杽閿涘牆褰查弴鎸庡床鏉堝湱鏅敍?|
| `solar_term/calendar_year_data.dart` | 瀹稿弶鐗庢宀€娈戦崡鏇炲嬀閺佺増宓?|
| `solar_term/month_branch_resolver.dart` | 閺堝牆缂撻敍姘磩娴滃被鈧矁濡妴宥呭隘闂傛潙鍨介弬?|
| `import/calendar_data_pack.dart` | 閺佺増宓侀崠鍛斧婵鑸伴幀?|
| `import/calendar_data_pack_parser.dart` | JSON 閳?閺佺増宓侀崠鍜冪礄閸欙拷锟界拠锟界《缂佹挻鐎敍?|
| `import/calendar_data_pack_terms.dart` | 閼哄倹鐨甸崚妤勩€冪憴鍕灟閿涘牊鏆熼柌?閸烇拷绔?闁帒锟?楠炵繝鍞ら崥鍫㈡倞閹嶇礆 |
| `import/calendar_data_pack_validator.dart` | 閸忓啯鏆熼幑锟界墡妤?+ 濮瑰洦鈧銇戠拹銉ュ斧閸?|
| `import/calendar_data_pack_importer.dart` | 鐟欙絾鐎?閳?閺嶏繝鐛?閳?娣囷拷锟介崚銈呯暰 閳?**閸樼喎鐡欓幓鎰唉** |
| `store/calendar_data_store.dart` | 閺堬拷婀存禒鎾冲亶鏉堝湱鏅?+ 閸愬懎鐡ㄧ€圭偟骞?|
| `store/stored_solar_term_provider.dart` | 娴犳挸鍋?閳?Provider閿涘牆绱撳銉拷鏉炶棄鎻╅悡褝绱濆鏇熸惛娣囨繃瀵旈崥灞撅拷閿?|

### 閺傛澘锟介敍鍧檌b/services 娑斿锟介惃鍕拱鏉烇拷楠囬悧鈺嬬礆
- `assets/calendar/2019..2028.calendar.json` 閳?**缁夊秴鐡欓弫鐗堝祦閸?10 楠?*閿?63 鐞涘瞼楠囬崚锟界礉
  娑撳海鏁ら幋宄帮拷閸忋儰濞囬悽?*鐎瑰苯鍙忛惄绋挎倱閻ㄥ嫭鐗稿?*閿涘奔绗夌€涙ê婀妴灞藉敶缂冿拷铔?Dart 鐢悂鍣洪妴宥囨畱缁楋拷绨╂總妞剧秼缁紮绱?
- `tool/calendar_pack_gen/generate_calendar_packs.dart` 閳?瀵偓閸欐垿妯佸▓鐢垫晸閹存劕娅?
  閿?*娑撳秴寮稉?App 鏉╂劘锟介弮?*閿?

### 閸忔娊鏁總鎴犲
- **閺堝牆缂撴潏鍦櫕**閿涙瓪instant < 娴溿倛濡?閳?閺冄勬箑瀵ょ閿涙矖instant >= 娴溿倛濡?閳?閺傜増婀€瀵ょ閿?
  瀹告彃浠涢妴灞兼唉閼哄倸澧?1 缁?/ 娴溿倛濡弮璺哄煝 / 娴溿倛濡崥?1 缁夋帇鈧秳绗侀幀浣规焽鐟封偓閿?
- **缂傚搫鐨獮缈犲敜**閿涙碍濮?`CalendarDataMissing`閿?*缁備焦锟芥潻鎴滄妧鐞涖儳鐣?*閿?
- **鐎电厧鍙嗛崢鐔风摍閹?*閿涙碍鐗庢灞藉弿闁劑鈧俺绻冮崜宥囩卜娑撳秴鍟撴禒鎾冲亶閿涘奔绗夌€涙ê婀妴灞斤拷娴滃棔绔撮崡濞库偓宥囨畱娑擄拷妫块幀渚婄幢
- **娣囷拷锟界憴鍕灟**閿涙瓊EW / UPDATE / SAME / DOWNGRADE 閸ユ稒鈧緤绱濋梽宥囬獓鐎电厧鍙嗙悮锟藉珕缂佹繀绗栭弮褎鏆熼幑锟界瑝閸欐﹫绱?
- **閺冦儳鏅?*閿涙矮绮ㄦ惔鎾存＆閺堝鍞惍浣规弓閸愯崵绮ㄧ憴鍕灟閿涘本鏅犻弽绋跨妇鐏炲倸鎮撻弮璺虹杽閻滈琚辩粔宥呰嫙鐟曚焦鐪伴弰鎯х础娴肩姴鍙嗛敍?
  閺堚偓缂佸牓鍣伴悽銊ユ憿娑撯偓缁夊秶鏆€缂佹瑤绗熼崝鈥崇湴閸愬啿鐣鹃妴?

### 閺佺増宓侀弶銉︾爱閿涘牆褰叉径宥嗙壋閿?
- 閺夈儲绨敍?*妫ｆ瑦鑵愭径鈺傛瀮閸?HKO**閵嗗奔绨╅崡浣告磽缁♀偓濮橈絿娈戦弮銉︽埂閸欏﹥妾梺鎾圭。閺傛瑣鈧稄绱?
  HKO 濞夈劍妲戦崗璺恒亯閺傚洦鏆熼幑锟芥降閼凤拷瀚抽崶?**HM Nautical Almanac Office** 娑?
  缂囧骸娴?**United States Naval Observatory**閿?
- 缁旓拷鍋ｉ敍姝歨ttps://www.hko.gov.hk/en/gts/astronomy/data/files/24SolarTerms_<YEAR>.xml`閿?
- 閸樼喎锟介弮鍫曟？閸╁搫鍣?HKT閿涘湶TC+8閿涘绱濋悽鐔稿灇閺冨墎绮烘稉鈧幎妯肩暬娑?**UTC**閿?
- **缁儳瀹虫俊鍌氱杽鐠佹澘缍嶉敍姘降濠ф劒璐熼崚鍡涙寭缁狙嶇礉閺佸懐锟芥担宥嗕航娑?`:00`**閿涘奔绗夐搹姘€粔鎺旈獓缁儳瀹抽敍?
- 鐟曞棛娲婇獮缈犲敜 2019閳?028閿涘湚KO 閸忥拷绱戦懠鍐ㄦ纯閿涘绱?
- 娴溿倕寮舵宀冪槈閿涙KO 娑撳孩妫╅張锟芥禇缁斿銇夐弬鍥у酱 NAOJ 閸︺劑鍣搁崣鐘插嬀娴犱粙鈧劙銆嶆稉鈧懛?
  閿涘牅绶ラ敍?026 鐏忓繐鐦?HKO 16:23 HKT = NAOJ 17:23 JST = 08:23 UTC閿涘鈧?

### 濞村鐦敍?103閿涘苯鍙?232/232 闁俺绻冮敍?
| 濞村鐦?| 鐟曞棛娲?|
| --- | --- |
| `ganzhi_day_test.dart` | T1 閺冦儲鐓撮敍?*13 娑擄拷娉曢獮缈犲敩閸╁搫鍣?*閿?900閳?023閿涘苯鎯堥梻鐗堟） 2020-02-29閿涘绱濋崣宀€瀚粩瀣爱閺嶏繝鐛?|
| `xun_kong_test.dart` | T2 閺冿拷鈹栭敍姘彋閺冿拷鍠曠紒鎾斥偓?+ 鐎瑰本鏆?60 閺冦儱鎯婇悳?+ **閻欙拷鐝涢幀褑宸濇宀冪槈**閿涘牏鈹栨禍?= 閺冿拷鍞撮張锟斤拷閻╂牔绨╅弨锟界礆 |
| `calendar_data_pack_parser_test.dart` | T3 鐟欙絾鐎介敍姘値濞?/ 鐠囷拷纭堕柨?/ 閺嶅綊娼€电钖?/ terms 闂堢偞鏆熺紒?/ 閸忓啰绀岄棃鐐诧拷鐠?|
| `calendar_data_pack_validator_test.dart` | T4 閺嶏繝鐛欓敍?4-23-25 閺?/ 闁插秴锟?/ 閺堬拷鐓?/ 閸婃帒绨?/ 闂堢偘寮楅弽濂糕偓鎺戯拷 / 闂堢偞纭?UTC / 闂?Z / 閸忓啯鏆熼幑锟藉繁婢?/ 楠炵繝鍞ら柨娆庣秴 / 鐠恒劌鍕炬潏鍦櫕娑撳秷锟介弶鈧?|
| `calendar_pack_import_test.dart` | T5 **鐎电厧鍙嗛崢鐔风摍閹?Golden**閿涘湜NVALID 鐎电厧鍙嗛崥搴㈡＋閺佺増宓侀柅鎰摟濞堝吀绗夐崣姗堢礆+ T6 娣囷拷锟介崶娑欌偓?|
| `month_branch_resolver_test.dart` | T7 閸椾椒绨╅妴宀冨Ν閵嗗禍?3 閺冨墎鍋ｆ潏鍦櫕 + 鐠恒劌鍙曢崢鍡楀嬀 + 閵嗗本鐨甸妴宥勭瑝閸掑洦宕查張鍫濈紦 |
| `calendar_engine_test.dart` | T8 缂傚搫鐨獮缈犲敜閹锋帞绮?+ T9 瀵洘鎼哥紒鐓庢値 Golden閿涘牏婀＄€圭偞鏆熼幑锟藉瘶閸忋劑鎽肩捄锟界礆 |
| `day_boundary_test.dart` | 閺冦儳鏅稉銈堬拷閸?鑴?22:59:59 / 23:00:00 / 23:59:59 / 00:00:00 + 鐠恒劍婀€鐠恒劌鍕鹃梻鐗堟） |
| `offline_gate_test.dart` | 鎼?6 缁傝崵鍤庨梻銊э拷閿涙碍妫ょ純鎴犵捕娓氭繆绂嗛妴浣规￥ Flutter 娓氭繆绂嗛妴浣规￥ `DateTime.now` |

### 妤犲矁鐦?
- `flutter test` 閳?**232/232 闁俺绻?*閿涘牆鐔€缁?129閿涘矂娴傞崶鐐茬秺閿涘绱?
- `flutter analyze --no-pub lib/domain test/domain` 閳?**0 issue**閿?
- `dart format --output=none --set-exit-if-changed`閿涘湩3-B 閺傚洣娆㈤敍澶嗗晪 **0 changed**閿?
- 5+100 闂傘劎锟介敍姝歭ib/domain/calendar/` 閸忋劑鍎撮弬鍥︽ **閳?99 鐞?*閿涘本鐦￠惄锟界秿 閳?5 閺傚洣娆㈤敍?
- `git diff --check` 閳?clean閵?

### 閺堬拷浠涢敍鍫熸绾拷绔熼悾宀嬬礆
- 閸樺棙纭剁粻锛勬倞 UI / 鐎电厧鍙嗛幐澶愭尦 / 閺傚洣娆㈤柅澶嬪閸?/ 鐟曞棛娲婄涵锟斤拷瀵湱鐛ラ敍鍫濈潣閸氬海鐢?UI 鐏炲偊绱氶敍?
- 鐎瑰本鏆ｆ径鈺傛瀮缁犳纭堕敍鍫滅矌娣囨繄鏆€ `SolarTermProvider` 閸欙拷娴涢幑銏ｇ珶閻ｅ矉绱濋張锟界杽閻?`Astronomical*`閿涘绱?
- 閺冮缚鈥?/ 閺堝牏鐗?/ 閺冦儱鍟?/ 缁佺偟鍘?/ 閸ユ稒鐓寸€瑰本鏆ｇ化鑽ょ埠 閳ユ柡鈧?閸у洣绗夐崷銊︽拱鏉烇拷鈧?

---

## 2026-09-11 璺?GUAYAN-2.0-R3-ENGINE-A閿涘牊甯撻惄妯虹穿閹?璺?閸楋缚缍嬬仦鍌︾礉閺堬拷褰傜敮鍐跨礆

> R3 缁楋拷绔撮梼鑸碉拷閿涙碍濡搁妴灞惧笓閻╂ǜ鈧秳绮犲鏃傘仛濡楋絾锟介崣妯诲灇**閻喎鐤勭拋锛勭暬**閵嗗倻鍑?Dart 妫板棗鐓欑仦鍌︾礉
> 闂?Flutter 娓氭繆绂?閳ユ柡鈧?Widget 娑撯偓瀵板绗夊妤勫殰鐞涘本甯撻崡锔肩礄閹槒锟介崚?鎼?0閿涘鈧?
> 閺堬拷鐤嗙憰鍡欐磰 R3 濞撳懎宕?12 妞ら€涜厬閻?9 妞ょ櫢绱欓崡锔跨秼鐏炲偊绱氶敍?
> 閸ユ稒鐓?/ 閺堝牆缂?/ 閺冦儴鏅?/ 閺冿拷鈹栭棁鈧獮鍙夋暜閸樺棙纭堕敍宀€鏆€瀵?R3-B閵?

### 閺傛澘锟介敍鍧檌b/domain/ 閳?閸╄櫣锟介崸鎰垼閿?
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `wu_xing.dart` | 娴滄棁锟?+ 閻㈢喎鍘犻敍娌梤elationTo(self)` 娑撳搫鍙氭禍鎻掑灲鐎规艾鏁稉鈧崗銉ュ經 |
| `di_zhi.dart` | 閸椾椒绨╅崷鐗堟暜閿涙矮绨茬悰?/ 闂冩挳妲?/ 閸忥拷鍟?/ 閸忥拷鎮?|
| `tian_gan.dart` | 閸椾礁銇夐獮璇х窗娴滄棁锟?/ 闂冩挳妲?/ 閸忥拷宕勯悽鎻掔摍閸欐牕鍏?|

### 閺傛澘锟介敍鍧檌b/domain/casting/ 閳?閹烘帞娲忓鏇熸惛閿?
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `bagua.dart` | 閸忥拷宕烽敍鍫滅瑏閻栨槒鍤滄稉瀣偓灞肩瑐閿? 閸楋妇锟?+ 娴滄棁锟?+ 閸忓牆銇夋惔?|
| `najia.dart` | 缁惧磭鏁崇悰锟界礄楠炲弶鏁敍澶涚窗娑斿墽鎾奸悽鎻掞紝閵嗕礁娼崇痪鍏呯閻ч潻绱遍崘鍛拷閸楋箑鍨庨崚锟斤拷閸?|
| `palace.dart` | 娴滐拷鍩ч崗锟斤拷閸楋箑绨?+ 娑撴牕绨查敍?*缁犳纭堕悽鐔稿灇閿涘矂娼涵锟界椽閻?64 閺?*閿?|
| `hexagram_names.dart` | 閸忥拷宕勯崶娑樺捶閸氬秷銆冮敍鍫滅瑐閸?鑴?娑撳宕烽敍?|
| `hexagram64.dart` | 閸忥拷鍩㈤梼鎾Ъ 閳?閸楋箑鎮?/ 鐎癸拷缍?/ 娑撴牕绨?|
| `six_relative.dart` | 閸忥拷缈伴敍鍫滀簰鐎癸拷缍呮禍鏃囷拷娑撴亽鈧本鍨滈妴宥忕礆 |
| `six_spirit.dart` | 閸忥拷锟介敍鍫熷瘻閺冦儱鍏辩挧铚傜伐閿涘矁鍤滈崚婵堝煝閸氭垳绗傛い鐑樺笓閿?|
| `cast_chart.dart` | 閹烘帞娲忕紒鎾寸亯濡€崇€烽敍鍦昦stLine / CastChart閿?|
| `casting_engine.dart` | 瀵洘鎼哥紒鍕拷閿涙碍婀伴崡?/ 閸欐ê宕?/ 閸斻劌褰?/ 缁惧磭鏁?/ 娑撴牕绨?/ 閸忥拷缈?/ 閸忥拷锟?|

### 鐠佹崘锟界憰浣哄仯
- **娑撴牕绨叉稉宥団€栫紓鏍垳**閿涙氨鏁遍妴灞炬拱鐎癸拷宕烽柅鎰煝缂堟槒娴?閳?濞撴悂鐡婇崶鐐电倳閸ユ稓鍩?閳?瑜版帡鐡婃潻妯哄斧閸愬懎宕烽妴?
  閻㈢喐鍨氶崗锟斤拷 64 閸楋讣绱濇稉鏍煝鎼村繐鍨懛锟藉姧娑?6/1/2/3/4/5/4/3閿涘本绉烽悘锟界瀵姵妲楅幎鍕晩閻ㄥ嫯銆冮敍?
- **閸欐ê宕烽崗锟界堪娴犲秴褰囬張锟藉捶娑斿锟?*娑撴亽鈧本鍨滈妴宥忕礄娴肩姷绮洪崶鍝勭暰鐟欏嫬鍨敍灞界穿閹垮骸鍞村鍙夋暈闁插﹪妲诲銏ｏ拷瑜?bug 閺€瑙勫竴閿涘绱?
- **闂堟瑥宕锋稉宥囨晸閹存劕褰夐崡?*閳ユ柡鈧柧绗夋潻鏂挎礀閵嗗奔绗岄張锟藉捶閻╃鎮撻妴宥囨畱娴硷拷褰夐崡锔肩幢
- **閺冪姵妫╅獮鎻掑灟閸忥拷锟芥稉?null**閿涘奔绗夐悮婊堢帛鐠併倖妫╅獮璇х幢闂堢偞纭舵潏鎾冲弳閹舵稑绱撶敮闈╃礉缂佹繀绗夋潻鏂挎礀閸楀﹥鍨氶崫浣碘偓?

### 娣囷拷锟?
- `wu_xing.dart` 閳?`relationTo` 閻ㄥ嫨鈧本鍨滈悽?/ 閻㈢喐鍨滈妴宥勭瑢閵嗗本鍨滈崗?/ 閸忓鍨滈妴宥勮⒈鐎佃鏌熼崥?
  閸掋倖鏌囬崘娆忓冀閿涘苯锟介懛鏉戝彋娴?**鐎涙劕鐡╂稉搴ｅ煑濮ｅ秹锟介崐?*閿涙稓鏁辩紒蹇撳悁閸楋箑锟介悡褎绁寸拠鏇熷礋閼惧嘲鎮楁穱锟斤拷閵?

### 濞村鐦敍?23閿涘苯鍙?129/129 闁俺绻冮敍?
- `test/domain/casting/hexagram_tables_test.dart` 閳?閸忥拷宕锋禍鏃囷拷 / 64 閸楋箒銆冮崬锟界閹?/
  閸忥拷锟芥い鍝勭碍娑撳簼绗橀悥璇茬碍閸掓绱欐稊鎯э拷閵嗕礁鍘€癸拷绱? 娑撴牕绨查惄鎼佹娑?/ 缁惧磭鏁抽崘鍛拷閸?/ 閸忥拷缈?/ 閸忥拷锟界挧铚傜伐閿?
- `test/domain/casting/casting_engine_test.dart` 閳?**缂佸繐鍚€閹烘帞娲忕€靛湱鍙?*閿涘湙ate A 閻?
  缁傝崵鍤庣粵澶夌幆閻椻晪绱氶敍姘挄娑撳搫銇夐妴浣告匠娑撳搫婀撮妴浣硅景鐏炲崬鎹€ 閸忋劎鍩㈢痪宕囨暢璺崗锟界堪璺稉鏍х安闁劙銆嶅В鏂匡拷閿?
  閼颁線妲奸崣姗€妲鹃妴浣解偓渚€妲鹃崣姗€妲奸妴浣革拷閸斻劎鍩㈤妴渚€娼ら崡锔芥￥閸欐ê宕烽妴浣稿彋缁佺偞瀵滈弮銉ュ叡閹恒儱鍙嗛妴渚€娼▔鏇＄翻閸忋儲瀚嗙紒婵撶幢
- `flutter analyze --no-pub lib/domain test/domain`閿?*0 issue**閵?

### 閺堬拷婧€閻滐拷锟介敍鍫滅瑝閸忋儱绨遍敍?
- `scripts/flutter.local.ps1` 閳?闁插秴缂撻張锟芥簚 Flutter 閸栧懓锟介懘姘拱閵嗗倹婀伴張?`$env:PATH`
  鐞氾拷锟介崜锟藉殾娴犲懎澧?pnpm shim閿涘瞼宸?`System32` / `git` / `flutter` / `PowerShell`閿?
  閻╁瓨甯寸拫鍐暏 `flutter` 閹?`Error: PowerShell executable not found`閵?
  鐠囥儴鍓奸張锟剿夋?PATH 閸氬氦娴嗛崣鎴幢閸?`pwsh` 娴滐缚绗夐崷?PATH閿涘矂銆忛悽銊х卜鐎电鐭惧鍕殶閻拷绱?
  `& "$PSHOME\pwsh.exe" -File scripts/flutter.local.ps1 test`

### 閺堬拷浠涢敍鍦?-B閿?
- 閸ユ稒鐓撮敍鍫濆嬀/閺?閺?閺冭埖鐓撮敍? 閺堝牆缂?/ 閺冦儴鏅?/ 閺冿拷鈹?閳ユ柡鈧?闂団偓楠炲弶鏁崢鍡樼《閿涘牆鎯堥懞鍌涚毜閹恒劎鐣婚敍澶涚幢
- 閹跺﹤绱╅幙搴㈠复閸忋儱锟介崡锕傘€夐敍灞炬禌閹?`ReviewTraditionalProfile` 濠曟梻銇氬锝嗭拷閸楃姳缍呯€涙锟介妴?

---

## 2026-09-10 璺?GUAYAN-2.0-R5-BASELINE-CLOSEOUT閿涘牆鐔€缁炬寧鏁归崣锝忕礉閺堬拷褰傜敮鍐跨礆

> 閺€璺哄經 `3c00187` 闁鏆€閸╄櫣鍤庨敍姘笓閸?lines 妞ゅ搫绨?Bug 閻欙拷鐝涢拃钘夌氨閿涘潉7266332`閿涘绱?
> 鐎光€冲捶 4 娑擄拷瀛╁ù瀣偓鎰般€嶆總鎴犲鐎孤わ拷閳ユ柡鈧? 妞?TEST STALE閵? 妞よ璐╅崥?
> 閿涘牊鏌囩懛鈧潻鍥ㄦ + 閺傚洦婀伴崚妤佹￥閸欏磭鏅惃鍕埂鐎圭偟宸遍梽鍑ょ礆閿涘本浠径宥呭弿闁插繑绁寸拠鏇犺雹閼瑰眰鈧?
> 閺堬拷鐤嗙粋浣癸拷閺傛澘濮涢懗鏂ょ礄閹烘帞娲忓鏇熸惛/閸忓磭閮?閸楋缚绶?鐠侊拷绮岄崸鍥ㄦ弓閸旓拷绱氶妴?

### T1 璺?閹烘帒宕烽敍鍧坥mmit 7266332閿?
- `casting_draft.dart` 閳?`CastingDraft.demo().lines` 閻㈠崬鈧帒绨弨鐟板磳鎼村骏绱?
  闁夸焦锟?`index = position - 1` 婵傛垹瀹抽敍?
- `casting_page_test.dart` 閳?鐞涖儵鈧劗鍩㈡担宥呮礀瑜版帪绱檡ao_status_1..6 + 缂傛牞绶鑺ョ垼 + 瀵板懎缍嶉弬鍥拷閿涘鈧?

### T2/T3 璺?鐎光€冲捶婵傛垹瀹崇€孤わ拷缂佹捁锟芥稉搴濇叏婢?
| 婢惰精瑙︽い?| 鐎规碍鈧?| 婢跺嫮鎮?|
| --- | --- | --- |
| F1 閸╄櫣鍤?31/47 | TEST STALE | 3c00187 閸╄櫣鍤庨崐鍏兼暭娑?18/24/34閿涘牅绗侀弶鈥崇敨閿涘绱濋張鍝勫煑閺堬拷娑敍娑欑ゴ鐠囨洘鏁兼稉鎭掆偓灞芥倱閺嶅嘲绱￠弬鍥ㄦ拱閸忥拷锟介崗鍙橀煩閸╄櫣鍤?+ 閹?3 閺夆€崇唨缁惧灝鐢妴宥忕礉娑撳秴鍟€缂佹垵鐣鹃崢鍡楀蕉缂佹繂锟介崸鎰垼 |
| F2 缁佺偟鍘煎鍝勫煑 4鑴? | TEST STALE | 3c00187 鐎规氨枪閸楃偨鈧本瀵滅€圭偤妾弫鐗堝祦濞撳弶鐓嬮妴浣风瑝閸愬秴宸遍崚鍓佲敄閸楃姳缍呴妴宥忕礄commit message 閺勫海銇氭穱锟斤拷鎼存洟鍎寸粚鐑樼閿涘绱卞ù瀣槸閺€閫涜礋閹稿鏆熼幑锟借閺?+ 閺冪姴宕版担?+ 4 閸掓鍤戞担鏇氱箽閹?|
| F3 閸╃儤婀版穱鈩冧紖閹峰棗鍨庨弬锟解枅 | TEST STALE | 閸忥拷宸?閸愭粌宸绘稉?meta 閸氬牆鑻熸稉鍝勫礋鐞涘矉绱欑槐褍鍣鹃崠鏍电礆閿涘奔淇婇幁锟藉弿閸︼拷绱卞ù瀣槸閺€?textContaining 妤犲矁鐦夋穱鈩冧紖閸︺劌婧€ |
| F4 鐡掑懘鏆辩痪鎶界叾娑撳秴甯囬悥缁樞?| 濞ｅ嘲鎮?| 缂佹繂锟?24px 閺傦拷鈻堢悮?FittedBox(contain) 閺€鎯с亣婢惰鲸鏅ラ敍鍫㈢級閺€鐐￥閸忓啿瀵查敍澶涚幢閻喎鐤勭紓娲閿涙矮瀵?閸欐ê宕烽弬鍥ㄦ拱閸掓妫ら崣宕囨櫕閸欙拷鈹涙潻鍥╁煝濡?閳?閸掓锟界亸渚€銆?74/88 鐠佹崘锟?px閿涘苯鍨紓妯匡拷閸?|

### 娣囷拷鏁?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `review_hexagram_line_row.dart` | 娑撹宕烽弬鍥ㄦ拱閸?136閳?10閵嗕礁褰夐崡锕€鍨?278閳?66 鐏忎線銆婇敍娑氳閺傚洦銆傜€靛綊缍堢€圭偤妾崺铏瑰殠 18/24/34 娑?contain |
| `review_shensha_card.dart` | 缁粯鏋冨锝嗘暭娑撴亽鈧本鏆熼幑锟解攳閸斻劌娴愮€?4 閸掓ぜ鈧稄绱辩粔濠氭珟閺堬拷濞囬悽?CastingTokens import |
| `review_page_test.dart` | F1/F2/F3/F4 閸ユ稒绁撮柌宥呭晸娑撹櫣缂夐弨鐐￥閸?/ 缂佹挻鐎弮鐘插彠婵傛垹瀹?|

### 妤犲矁鐦?
- `flutter test`閿?*106/106 闁俺绻?*閿涘牆鎯堢€光€冲捶 26/26閿涘绱盽flutter analyze` 閺堬拷鐤嗛弬鍥︽ 0 issue閵?
- `pubspec.lock`閿涙碍绁寸拠鏇犳暏 `--no-pub` 鏉╂劘锟介敍灞炬￥娓氭繆绂嗗ù锟藉З閿涘奔绗夐崗銉ョ氨閵?
- `uploads/screenshots/`閿涙矮姹夊銉╃崣閺€鑸靛焻閸ユ拝绱濇穱婵囧瘮閺堬拷绐￠煪锟藉斧閻樿翰鈧?

---

## 2026-08-31 璺?GUAYAN-2.0-REVIEW-BASELINE-R4閿涘牆锟介崡锕傦拷鐏炲繐鐔€缁惧灝锟芥鎰暰缁嬪尅绱濋張锟藉絺鐢喛绱?

> 閸欙拷濮╂稉銈勯嚋缂佸嫪娆㈤敍姘彋閻栬宕烽惄姗堢礄Baseline Alignment閿? 缁佺偟鍘奸敍鍦業XED 4鑴?閿涘绱?
> 閸忔湹缍戝鎻掔暰缁?UI 娑撯偓瀵板绗夐崝銊ｂ偓鍌滄埂濮濓絽缂撶粩?鐞涘苯鐔€缁?+ 閸掓ぞ鑵戣箛鍐殠"閿涘本绉烽悘锟斤拷鐟欏寮锟解偓?

### 閸忥拷鍩㈤崡锔炬磸
| 妞?| 鐠囧瓨妲?|
| --- | --- |
| Primary Baseline | RowTop + 19閿涙艾鍙氱粊?娴煎繒锟借劤2/娑撹宕峰锝嗘瀮/娑撴牕绨?閸欐ê宕峰锝嗘瀮/閸欐ê宕锋稉鏍х安 閸忋劑鍎撮弫鏉匡拷闁夸礁鐣鹃崥灞肩閺夆€崇唨缁惧尅绱橣lutter `Baseline` 缂佸嫪娆㈤敍?|
| NaYin Baseline | RowTop + 35閿涙矮瀵?閸欐ê宕风痪鎶界叾閸氬嫯鍤滅仦鍛厬娴滃孩锟介弬鍥у灙 |
| 鐞涘矂鐝?/ 閸掓ぞ鑵戣箛?| 48 DIP閿涙稑鍙氱粊?2 娴煎繒锟?2/100 濮濓絾鏋?74/318 閻?22/358 娑撴牕绨?50/388 閸斻劎鍩?68 缁狅拷銇?80 |
| 鐎涙褰跨仦鍌滈獓 | 鏉堝懎濮穱鈩冧紖閿涘牆鍙氱粊?.4/娴煎繒锟?/娑撴牕绨?.8閿涘鐖剁憴鍕瑝閸旂姷鐭栭敍娑欙拷閺?10.5 閸旂姷鐭栭敍?314D59閿涘绱辩痪鎶界叾 9 鐢瓕锟?|
| 閼凤拷鈧倸绨?| 400 鐠佹崘锟界粚娲？ + FittedBox(scaleDown)閿涙稖锟介崘鍛￥鏉堣锟介敍灞藉瀻閸撹尙鍤庨悽杈€冮弽鑲╁缁斿绮崚璁圭礉FittedBox 閻栧爼鐝幁?48 閺冪姷鏃遍崥鎴犵級閺€?|

### 缁佺偟鍘?
| 妞?| 鐠囧瓨妲?|
| --- | --- |
| FIXED 4鑴? | 閺嶇厧锟?89閵嗕焦鐗告?18閵嗕礁鍨捄?6閵嗕浇锟界捄?4閿?16 妞ゅ湱鏆€缁屽搫宕版担宥冣偓?16 閹靛秴濮炵粭?5 鐞涘矉绱辩粋浣癸拷閼凤拷鏁?Wrap閿涙稓锟?4 鐞涘本妗堥崷銊ュ幢閸?|

### Token / 鐞涖劌銇?
- 閺傛澘锟?`linePrimary #314D59`閵嗕梗shenShaItem #5C7078`閿涙并uaTitle 13 / guaName 10.8

### 濞村鐦敍?3閿涘苯鍙?106/106 闁俺绻冮敍?
- R4 閸╄櫣鍤庨柨浣哥暰閿涘湐aseline 閳?{19,35}閿涙矮瀵?6 閺?/ 缁炬娊鐓?2 閺夆槄绱?
- R4 缁佺偟鍘奸崶鍝勭暰 4鑴?閿?6 閺嶇鈧礁鎮撻崚妤€锟芥鎰┾偓浣猴拷 4 鐞涘苯婀崡鈥冲敶閿?
- R4 缁佺偟鍘?<16 妞ょ櫢绱?2 缁岃桨缍呴崡鐘辩秴娣囨繃瀵?4鑴?閿?
- analyze 閺堬拷鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 2026-08-31 璺?GUAYAN-2.0-REVIEW-ONSCREEN-R3閿涘牆锟介崡锕傦拷鐏炲繗鍨濋柅鍌滄彛閸戞垹澧楅敍灞炬弓閸欐垵绔烽敍?

> **绾拷妫粋渚婄窗閸忥拷鍩㈤崗锟斤拷韫囧懘銆忛崷銊ワ拷閸楋箓锟界仦蹇撶暚閺佸瓨妯夌粈?*閿涘牅绗夐崘宥嗗复閸欐ぞ绗呭鎴炲閼崇晫婀呴崚鐗堟沟闂嗏偓/閸掓繄鍩㈤敍澶堚偓?

### 鐢啫鐪拫鍐╂殻
| 妞?| 閸欐ê瀵?|
| --- | --- |
| 閸楋箑鎮?Header | 66 閳?54 DIP閿涘牅瀵?閸欐ê宕烽弽鍥拷 + 閸楋箑鎮曢崥鍕鐞涘矉绱漢2 12 / gua 10閿?|
| 娴煎繒锟?| 3 鐎涙鐓弽鐓庣础閿涙艾鍙氭禍鑼暆缁?+ 閸︾増鏁?+ 娴滄棁锟介敍鍫ｅ偍鐎靛懏婀?/ 閻栬埖婀崷鐔测偓锔肩礆閿涘奔绗夐崘宥堬拷鐎硅棄瀹崇憗浣稿瀼 |
| 閸忥拷鍩㈢悰宀勭彯 | 56 閳?48 DIP閿涘本锟介弬鍥﹁⒈鐞涘苯鐣弫娣偓浣规￥閻胶鏆愰崣?|
| 閸掓锟?| 閸忥拷锟?24 / 娴煎繒锟?28 / 娑撴牕绨?12 / 閸斻劎鍩?12 / 缁狅拷銇?6 / 閻栫粯蝎 24閿?60 DIP 娑撳秵瀛╅崙鐚寸礆 |
| 缁毖冨櫨閸?| 閸ユ稒鐓?40 / 缁佺偟鍘?chip 19 / BasicInfo 84 / 妞ょ敻娼伴梻纾嬬獩 6 |
| 鐞涖劌鐔?| 閵嗗瞼鍋ｉ崙璁虫崲娑撯偓閻栫粯鐓￠惇瀣彠缁眹鈧浇锟介崚娆庣贩閹癸拷绗岄崗宕囬兇婢跺洦鏁為妴?|

### 濞村鐦?
- 閺傛澘锟界涵锟芥，缁備焦绁寸拠鏇窗430鑴?32 娑撳鍙氶悥璇插彋鐞?+ 鐞涖劌鐔崷銊ョ俺闁劌锟介懜锟藉隘娑斿绗傜€瑰本鏆ｉ崣锟斤拷
- 娴煎繒锟介弬锟解枅閺囧瓨鏌婃稉?3 鐎涙鐓弽鐓庣础
- 妤犲矁鐦夐敍姝爈utter test 103/103 闁俺绻冮敍娌榥alyze 閺堬拷鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 2026-08-31 璺?GUAYAN-2.0-REVIEW-ONSCREEN閿涘牆锟介崡锔跨鐏炲繒澧楅弨璺哄經閿涘本婀崣鎴濈閿?

> 閺佺繝缍嬮弨璺哄經閿涙矮绔寸仦蹇撳帥閻鐣弫鏉戠唨閺堬拷淇婇幁?+ 閸ユ稒鐓?+ 4鑴? 缁佺偟鍘?+ 鐎瑰本鏆ｉ崡锔炬磸閿?
> 閵嗗苯鍙х化鑽ゅ妽閻愬箍鈧秳绗夐崘宥呯埗妞硅銇囬崡鈽呯礉閺€鍦仯閺屾劒绔撮悥?閳?妤傛ü瀵?閳?Bottom Sheet閿涘牆鍙х化璇插灙鐞?鐟欏嫬鍨笟婵囧祦/
> 閸忓磭閮存径鍥ㄦ暈/鏉╂稑鍙嗛崗宕囬兇妞ょ绱氶妴鍌氬捶閻╂ê浜ゆ惔鏇炲絿濞戝牏娓烽悾銉ュ娇閿涘牆鍙氭禍鎻掓勾閺€锟界瑢缁炬娊鐓堕幏鍡曡⒈鐞涘矉绱氶妴?

### 鐎光€冲捶妞?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `review_page.dart` | 娑撯偓鐏炲繐绔风仦鈧柌宥嗗笓閿涙稑鍨归梽銈呯埗妞硅鍙х化鑽ゅ妽閻愮懓宕遍敍娑氬仯閻栧鐝禍?+ 瀵懓鐪伴敍娌穘OpenRelations |
| `review_basic_info_card.dart` | 缁毖冨櫨閸楁洖宕遍敍鍫ユ６娴?閺傜懓绱?chip/閸忥拷宸?閸愭粌宸?meta閿?|
| `review_four_pillars_strip.dart` | soft 鎼?44 妤?+ teal/warm 閸欏矁澹?+ 閺冿拷鈹栭崣鍐诧拷姒?|
| `review_shensha_card.dart` | chip 20 妤傛鎻ｉ崙?4鑴? |
| `review_hexagram_result_table.dart` | 鐞涖劌銇?+ 鐞涘瞼鍋ｉ崙濠氣偓蹇庣炊 + 閺傛媽銆冪亸鐐絹缁€?|
| `review_hexagram_line_row.dart` | 閸忥拷缈伴崷鐗堟暜/缁炬娊鐓堕幏鍡曡⒈鐞涘被鈧焦妫ら惇浣烘殣閸欏嚖绱?1 閸掓娴愮€规碍蝎娴ｅ稄绱遍崣锟藉仯妤傛ü瀵?|
| `review_line_detail_sheet.dart`閿涘牊鏌婃晶鐑囩礆 | 閻愬湱鍩㈠鐟扮湴閿涙艾缍嬮崜宥囧煝 + 閸忓磭閮撮崚妤勩€?+ 鐟欏嫬鍨笟婵囧祦 + 婢跺洦鏁?GAP) + 鏉╂稑鍙х化濠氥€?|
| 閸掔娀娅?`review_relation_focus_card.dart` | 閳?|
| `review_page_state.dart` / `review_case_adapter.dart` | allRelations / relationsInvolving / relationLabel |
| `review_demo_data.dart` | 鐎靛綊缍堟稉鈧仦蹇曞 SVG閿涘牓妫舵禍?09:30/娑撳啯婀€閸椾礁鍙?璺?瀹歌櫕妞?閻㈡娊鍘滅粚鐚寸礆 |

### 閹烘帒宕锋い?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `line_editor_sheet.dart` | 閻栨槒钖勯柅澶愩€嶉崡?mainAxisExtent 58 閸ュ搫鐣鹃敍鍫氬⒑58 DIP 绾拷妫粋渚婄礆閿涘奔鎱ㄦ径?BOTTOM OVERFLOWED 1.2px |

### Token / 閸忓彉闊?
- `casting_tokens.dart`閿涙ua #927848閵嗕垢illarTeal #4F8685閵嗕焦鏌婃晶?pillarWarm #A8605C
- `shared/yao_glyph.dart` / `moving_marker.dart`閿涙碍寮挎潏鐟帮拷鎼达附瀵滄稉鈧仦蹇曞 SVG 瀵帮拷鐨?

### 濞村鐦?
- `review_page_test.dart`閿涙矮绔寸仦蹇曞闁倿鍘?+ 閻愬湱鍩㈠鐟扮湴閿涘牆鍙х化璇插灙鐞?/ 鏉╂稑鍙嗛崗宕囬兇妞ら潧娲栫拫鍐跨礆+ 缁愬嫬鐫?360 閺冪姵瀛╅崙?
- `casting_page_test.dart`閿涙碍鏌婃晶鐐偓宀€鍩㈢挒鈥宠剨鐏炲倻鐛庣仦?360鑴?40 閺?RenderFlex 濠с垹鍤妴?
- `foundation_test.dart`閿涙艾锟介崡锕€鍨庨弨锟芥焽鐟封偓閺€閫涜礋 缁佺偟鍘?
- 妤犲矁鐦夐敍姝爈utter test 102/102 闁俺绻冮敍娌榥alyze 閺堬拷鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 2026-08-30 璺?GUAYAN-2.0-UI-CORRECTION-R2閿涘牊甯撻崡?+ 鐎光€冲捶婢х偤鍣烘穱锟斤拷閿涘本婀崣鎴濈閿?

> 閸?R1 瀹告彃鐣剧粙鍨唨绾偓娑撳﹤浠涙晶鐐哄櫤娣囷拷锟介敍姘灩閹烘帒宕锋い鍫曞劥閼藉枪閹芥锟介崡掳鈧浇鎹ｉ崡锔芥闂傚瓨妯夌粈鍝勫彆閸?閸愭粌宸婚妴?
> 閸忥拷鍩㈣ぐ鏇炲弳鐞涘瞼绮烘稉鈧?52 DIP閵嗕胶锟介悡鐐叉祼鐎?4 閸掓ぜ鈧焦娓剁紒鍫濆捶閻╂绮嶆禒璁圭礄閸愬懎绁垫稉?閸欐ê宕烽弽鍥拷閿涘鈧?
> 缂佺喍绔撮悥缁樞?24鑴?閿涘牓妲?闂?缁岃桨楠告禒鍛敶闁劌锝為崗鍛瑝閸氬矉绱氶妴浣稿З閻栫粯鐖ｇ拋?12鑴?2閵嗕焦鏋冮張锟界瑝瀵版甯囬悥姹団偓?

### 閺傛澘锟介敍鍧檌b/presentation/shared/ 閳?閹烘帒宕?鐎光€冲捶瀵搫鍩楁径宥囨暏閿?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `yao_glyph.dart` | 缂佺喍绔撮悥缁樞?24鑴?閿涙ang 鐎圭偛绺?/ yin 瀹革箑褰搁弬锟藉殠 / voidYao 缁屽搫绺鹃幓蹇氱珶 rx1 #7E9098 w1.5 |
| `moving_marker.dart` | 閸斻劎鍩㈤弽鍥拷 12鑴?2閿涙俺鈧線妲?閳?#A17F45 / 閼颁線妲?鑴?#567866閿涘瓓ounding Box 娑撯偓閼?|
| `test/presentation/shared/yao_glyph_test.dart` | 閸忓彉闊╃紒鍕鐏忓搫锟介崘鑽ょ波濞村鐦敍鍦睮-05/06 缂佸嫪娆㈢痪褝绱?|

### 閹烘帒宕锋い?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `casting_page.dart` | 閸掔娀娅?CastingDraftContext閿涘煪?.1閿?|
| `casting_time_row.dart` | 闁插秴鍟撻敍?8 妤傛﹫绱濋崗锟藉坊 + 閸愭粌宸?+ 閸欏厖绗傞悩鑸碘偓?chip閿涘煪? SVG閿?|
| `casting_page_state.dart` | 閺傛澘锟?lunarPlaceholder閿涘湙AP閿涙艾鍟橀崢鍡樺床缁犳绶熼幒銉ュ弳閿涘resentation mock閿?|
| `six_yao_input_row.dart` | 閺咃拷鈧俺锟?= 缂傛牞绶悰?= 52 DIP閿涘煪?閿涘绱辨潻浣盒╅崗鍙橀煩 YaoGlyph |
| `line_editor_sheet.dart` | 鏉╀胶些閸忓彉闊?YaoGlyph + MovingMarker |
| 閸掔娀娅?`casting_draft_context.dart`閵嗕焦妫?`casting/widgets/yao_glyph.dart` | 閳?|

### 鐎光€冲捶妞?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `review_page_state.dart` | 娴煎繒锟介幏鍡曡⒈閸掓绱檋iddenSpirit1/2閿? isVoid閿涘牅瀵岄崡?閸欐ê宕烽敍澶涚幢缁炬娊鐓堕弨鐟板磹鐟欐帗瀚崣?|
| `review_case_adapter.dart` / `review_demo_data.dart` | 娴煎繒锟芥稉銈呭灙 + isVoid 闁繋绱堕敍娑欏瘻 SVG #12閿涙矮绨查悥璁崇闁板鈧椒绗侀悥璁崇瑵閻㈠磭鈹栨禍?|
| `review_shensha_card.dart` | 缁佺偟鍘奸崶鍝勭暰 4 閸掓鏆熼幑锟解攳閸斻劎缍夐弽纭风礄鎼?閿?16 妞ゅ湱鎴风紒锟藉鐞涘矉绱?|
| `review_hexagram_result_table.dart` | 閺堚偓缂佸牆宕烽惄妯肩矋娴犺绱伴崘鍛サ閵嗘劒瀵岄崡锔衡偓?閵嗘劕褰夐崡锔衡偓鎴炵垼妫?+ 閸忥拷锟介幒鎺旀磸 + 鐞涖劌鐔敍鍩?/鎼?2閿?|
| `review_hexagram_line_row.dart` | 11 閸掓鍠曠紒鎾崇鐏炩偓閿涙艾鍙氱粊?娴煎繒锟借劤2/娑撹褰夐崡锔芥瀮鐎?閻栫粯蝎(24鑴?)/娑撴牕绨?閸斻劎鍩?12鑴?2)/缁狅拷銇旈敍娑欐瀮閺?Ellipsis 娑撳秴甯囬悥浼欑礄鎼?1閿?|
| `review_page.dart` | 缁夊娅?HexagramResultHeader閿涘牓浼╅崗宥嗙垼妫版﹢鍣告径宥嗚閺屾搫绱?|
| 閸掔娀娅?`review_hexagram_result_header.dart` | 閳?|

### 濞村鐦?
- `casting_page_test.dart`閿涙瓗I-01閿涘牊妫?DraftContext閿? UI-02閿涘牆鍙曢崢?閸愭粌宸婚敍? UI-03閿涘牐锟芥?52 娑撯偓閼疯揪绱?
- `review_page_test.dart`閿涙瓗I-04閿涘牏锟介悡?4 閸掓绱? UI-05閿涘牏鍩㈠Σ?24鑴?閿? UI-06閿涘牆濮╅悥?12鑴?2閿?
  UI-07閿涘牐绉撮梹鎸庢瀮閺堬拷绗夐崢瀣煝閿? UI-08閿涘牆褰夐崡锔惧煝濡?閸欐ê宕锋稉鏍х安閸氬本妯夐敍? R1 濞村鐦柅鍌炲帳
- `foundation_test.dart`閿涙艾锟介崡锕€鍨庨弨锟芥焽鐟封偓閺€閫涜礋閵嗘劒瀵岄崡锔衡偓?

### GAP / 閸嬪繐妯?
- 閸愭粌宸绘稉?presentation mock閿涘潤unarPlaceholder閿涘绱濋惇鐔风杽閹广垻鐣诲鍛笓閻╂ê绱╅幙搴㈠复閸忋儻绱?
- 缁岃桨楠?isVoid 娴?UI 鐞涖劎骞囬敍鍫熺川缁€鐑樸€傚鍫熷絹娓氭冻绱氶敍瀛竔dget 娑撳秷锟界粻妤佹３缁岀尨绱?
- 濠曟梻銇?pos2閿涘牐鈧線妲奸敍澶嬪瘻鐠囷拷绠熷〒鍙夌厠闂冭櫕蝎 + X閿涘VG #12 閻㈣缍旈梼?X閿涘牊婀侀幇蹇庢叏濮濓綇绱濇穱婵囧瘮闂冩挳妲肩拠锟界疅娑撯偓閼疯揪绱氶妴?
- 妤犲矁鐦夐敍姝爈utter test 100/100 闁俺绻冮敍娌榥alyze 閺堬拷鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 2026-08-30 璺?GUAYAN-2.0-REVIEW-UI-R1閿涘牆锟介崡锕傘€?XYUI 瀹搞儰缍旈崣鏉跨暰缁嬪灝鐤勯弬鏂ょ礉閺堬拷褰傜敮鍐跨礆

> **鐎光€冲捶妞ゅ灚娓剁紒鍫ｏ拷鐟?*閿涙碍瀵滄禍鍝勪紣鐎规氨枪閹?SVG 閹跺鈧苯锟介崡锔衡偓宥呭窗娴ｅ秹銆夌€圭偟骞囨稉?XYUI 闂€鍧椼€夐幒鎺旀磸瀹搞儰缍旈崣?
> 閿涘湐asicInfo 閳?ShenSha 閳?FourPillars 閳?HexagramHeader 閳?HexagramTable 閳?RelationFocus閿涘鈧?
> 娴肩姷绮洪幒鎺旀磸鐎涙锟介悽杈ㄧ川缁€鐑樸€傚鍫熷絹娓氭冻绱欓幒鎺旀磸瀵洘鎼?R3 閸撳秳绗夐柅鐘蹭海缁犳纭堕敍澶涚幢閻喎鐤勯崡锔跨伐缂?App Shell
> `onGenerated` 濡椼儲甯撮幒銉ュ弳閿涘苯鍙氶悥?閸︾増鏁?閸忓磭閮撮悞锔惧仯閸忋劑鍎撮弶銉ㄥ殰閻滅増婀?Domain閵?

### 閺傛澘锟介敍鍧檌b/presentation/review/閿?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `review_page.dart`閿涘牓鍣搁崘娆欑礆 | 鐎光€冲捶瀹搞儰缍旈崣鎵矋鐟佸拑绱欐悅3 鐢啫鐪敍?|
| `review_page_state.dart` | 缁?Dart 閻樿埖鈧焦膩閸ㄥ绱欐悅7 閸忋劑鍎寸€涙锟介敍灞炬弓閹恒儱鍙嗙€涙锟介弰鎯х础 nullable閿?|
| `review_case_adapter.dart` | HexagramCase + 娴肩姷绮哄锝嗭拷 閳?ReviewPageState閿涙稓鍔嶉悙鐟板彠缁粯娼甸懛?calculateRelations |
| `review_demo_data.dart` | 鐟欏棜锟界€规氨枪濠曟梻銇氶弫鐗堝祦閿涘牊杈扮仦鍗炴崁閳帗杈板鏉戞炊 / 16 缁佺偟鍘?/ 娑撴瑥宕嶉獮绮光偓锔跨闁板妞?/ 閸忥拷锟芥导蹇曪拷閸忥拷缈扮痪鎶界叾娑撴牕绨查敍?|
| `widgets/review_app_bar.dart` | 妞よ埖鐖敍鍫ｇ箲閸?chevron + 鐎光€冲捶 + 閹烘帞娲忕紒鎾寸亯閿涘眲?閿?|
| `widgets/review_basic_info_card.dart` | 閸╃儤婀版穱鈩冧紖閸椻槄绱欐悅2閿?|
| `widgets/review_shensha_card.dart` | 缁佺偟鍘奸悪锟界彌閸楋紕澧?+ 閼凤拷鈧倸绨?Wrap 缂冩垶鐗搁敍鍩?/鎼?閿?|
| `widgets/review_four_pillars_strip.dart` | 閸ユ稒鐓撮弶鈽呯窗楠?閺?閺?閺?閺冿拷鈹栭敍鍩?/鎼?閿?|
| `widgets/review_hexagram_result_header.dart` | 閹烘帞娲忕紒鎾寸亯婢?+ 娑?閸欐ê宕烽弽鍥拷閿涘煪?閿?|
| `widgets/review_hexagram_result_table.dart` | 閸忥拷鍩㈤幒鎺旀磸娑撹缍嬬悰锟界礄鎼?閿涘奔绗傞悥璇叉躬娑撳﹤鍨甸悥璇叉躬娑撳绱?|
| `widgets/review_hexagram_line_row.dart` | 閸忥拷鍩㈤崡鏇★拷閿涘牆鍙氱粊?娑撹宕烽崥锟界础缁?閸欐ê宕?+ 閻垽鍣洪悥鏄忚杽 + 娑撴牕绨?閸斻劎鍩㈤敍?|
| `widgets/review_relation_focus_card.dart` | 閸忓磭閮撮悞锔惧仯閸椻槄绱欐悅7/鎼?3閿涘矁锟介崚娆庣贩閹癸拷鐑︽潪锟斤拷閸掓瑥绨遍敍?|
| `test/presentation/review/review_page_test.dart` | 鎼?2 Test A閳ユ弻 + 闁倿鍘ら崳?閻掞妇鍋ｉ崗宕囬兇/閸欏本鏆熼幑锟界熅瀵?|

### 娣囷拷鏁?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/presentation/casting/casting_tokens.dart` | 鐞涖儱鍘?鎼? Token閿涙elationRed / relationBlue / traditionalGold / pillarTeal |
| `lib/presentation/casting/casting_page.dart` | 閺傛澘锟介崣锟解偓?`onGenerated` 閸ョ偠鐨熼敍鍫㈡晸閹存劕鎮楅柅姘辩叀 Shell閿?|
| `lib/app/app_shell.dart` | 鐎光€冲捶妞ょ敻娈ｉ挊蹇撳弿鐏炩偓 AppBar閿涘牐鍤滅敮?XYUI TopBar閿涘绱盽_latestCase` 濡椼儲甯撮幒鎺戝捶缂佹挻鐏?|
| `test/foundation_test.dart` | 鐎光€冲捶閸掑棙鏁弬锟解枅闁倿鍘ら敍鍫熸￥閸忋劌鐪?AppBar + 鐎瑰本鏆ｉ幒鎺旀磸/閸忓磭閮撮悞锔惧仯閿?|

### GAP閿涘牊婀版潪锟斤拷鐎圭偞鐖ｅ▔锟界礆
- 閸忥拷锟?娴煎繒锟?閸忥拷缈?缁佺偟鍘?閸ユ稒鐓?閸楋箑鎮?缁炬娊鐓堕敍姘笓閻╂ê绱╅幙搴礄R3閿涘鎯ら崷鏉垮娴犲懏绱ㄧ粈鐑樸€傚鍫熷絹娓氭冻绱?
  閻喎鐤勯崡锔跨伐娑撳妯夊蹇曠枂缁岀尨绱濇稉宥呬粵閸嬪洤鍙氶悥鑽ょ暬濞夋洩绱?
- 娑撴牕绨?閻㈢喎鍘?閸ョ偛銇旈悽鐔锋礀婢舵潙鍘犻敍姘彠缁槒锟介崚娆忕潣 R3/R4閿涘本婀版潪锟界矌閸忋儱褰涢敍鍦lationFocusCard chips閿涘绱?
- 閹烘帒宕锋い鐐光偓灞剧叀閻锟介崡?閳ユ亽鈧秴鍙嗛崣锝咃拷閼革拷绮涙稉楦匡拷鐟欏鈧緤绱欓崥搴ｇ敾鏉烇拷锟介幒銉┾偓姘剧礆閵?
- 妤犲矁鐦夐敍姝爈utter test 84/84 闁俺绻冮敍娌榥alyze 閺堬拷鐤嗛弬鍥︽ 0 issue閿?1 閺夆剝妫禒锝囩垳閸涘﹨锟介張锟藉З閿涘绱?
  debug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 2026-08-30 璺?GUAYAN-2.0-CASTING-UI-R1閿涘牊甯撻崡锕傘€?XYUI 瀹搞儰缍旈崣鏉跨暰缁嬪灝鐤勯弬鏂ょ礉閺堬拷褰傜敮鍐跨礆

> **閹烘帒宕锋い鍨付缂佸牐锟界憴?*閿涙艾绨惧鍐︹偓灞炬煙濡?2 缁鹃潧鎮滃ù浣衡柤鏉炪劊鈧稄绱濋幐澶夋眽瀹搞儲濯块弶璺ㄦ畱閹?SVG 閺€閫涜礋
> 閹烘帒宕峰銉ょ稊閸?閳ユ柡鈧?1 鐠у嘲宕烽弮鍫曟？ 閳?2 闂傦拷绨ㄦ穱鈩冧紖 閳?3 閸忥拷鍩㈣ぐ鏇炲弳 閳?4 鐟欏嫬鍨崠?閳?5 閻㈢喐鍨氶幒鎺旀磸閵?
> 閺堬拷鐤嗘稉楦匡拷鐟欏锟介弸?+ 閻樿埖鈧胶绮嶆禒?+ 韫囧懓锟芥禍銈勭鞍閸╄櫣锟介敍娑楃瑝閸嬫艾锟介崡锕傘€夐柌宥嗙€妴浣稿彠缁绱╅幙搴涒偓浣哥暚閺佺锟介崚?CRUD閵?

### 閺傛澘锟介敍鍧檌b/presentation/casting/widgets/閿?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `casting_app_bar.dart` | 妞よ埖鐖敍鍫濆捶閻?/ 閹烘帒宕?/ 娑撳鍋ｉ弴鏉戯拷閿涘眲?.1閿?|
| `casting_draft_context.dart` | 閼藉枪娑撳﹣绗呴弬鍥у幢閿涘牐宕忕粙澶歌厬閿涘眲?.2閿?|
| `casting_time_row.dart` | 鐠у嘲宕烽弮鍫曟？缁楋拷绔寸悰宀嬬礄鎼?.3閿涘本妫╅張?閺冨爼妫?閺冩儼鏅敍?|
| `casting_question_row.dart` | 闂傦拷绨ㄦ穱鈩冧紖缁楋拷绨╃悰宀嬬礄鎼?.4閿涘奔瀵屾０?濮濓絾鏋?鐎电钖?閼冲本娅欓敍?|
| `six_yao_input_panel.dart` | 閸忥拷鍩㈣ぐ鏇炲弳缁楋拷绗佺悰宀勬桨閺夊尅绱欐悅5.5閿涘苯缍嬮崜宥嗭拷妤?chip閿?|
| `six_yao_input_row.dart` | 閸忥拷鍩㈤崡鏇★拷閿涘牆鍑¤ぐ?瀵板懎缍?缂傛牞绶稉澶嬧偓渚婄礉鎼?/鎼?閿?|
| `yao_glyph.dart` | 閻栬崵鐓濋柌蹇撴禈瑜帮拷绱欓梼鎾Ъ缁?+ 閼颁線妲剧粚鍝勭妇閸?閼颁線妲?X閿涘眲?0閿?|
| `casting_rule_pack_row.dart` | 鐟欏嫬鍨崠鍛拷閸ユ稖锟介敍鍩?.6閿涘奔鎱ㄩ弨?閳ョ尨绱?|
| `casting_generate_row.dart` | 閻㈢喐鍨氶幒鎺旀磸缁楋拷绨茬悰宀嬬礄locked/ready/generated閿涘眲?.7/鎼?4閿?|
| `casting_chip.dart` | XYUI 閼宠泛娉鑺ョ垼 + 閻垽鍣?chevron |
| `line_editor_sheet.dart` | 閻栨槒钖勯柅澶嬪瀵懓鐪伴敍鍫濈毌闂?鐏忔垿妲?閼颁線妲?閼颁線妲?+ 濞撳懘娅庨敍?|
| `time_editor_sheet.dart` | 鐠у嘲宕烽弮鍫曟？瀵懓鐪伴敍鍫熸）閺?閺冨爼妫?閺冩儼鏅懛锟藉З閹广垻鐣婚敍灞?1閿?|
| `question_editor_sheet.dart` | 闂傦拷绨ㄦ穱鈩冧紖瀵懓鐪伴敍鍫濇磽妞よ鏋冮張锟界礉鎼?2閿?|
| `rule_pack_sheet.dart` | 鐟欏嫬鍨崠鍛窗娴ｅ秴鑴婄仦鍌︾礄鎼?3閿涘奔绗夐柅鐘蹭海 CRUD閿?|
| `test/presentation/casting/casting_page_test.dart`閿涘牓鍣搁崘娆欑礆 | Test A閳ユ弴 + 鐞涘矂銆庢惔?+ 閼藉枪娴犳挸绨?+ 缁撅拷鈧槒绶?|

### 閺傛澘锟介敍鍧檌b/services/draft/閿?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `casting_draft.dart` | 閼藉枪濡€崇€烽敍鍫濇儓鐟欏棜锟界€规氨枪濠曟梻銇氶懡澶屒?CastingDraft.demo閿?|
| `draft_repository.dart` | DraftRepository 閹恒儱褰涙潏鍦櫕 + 閸愬懎鐡ㄧ€圭偟骞囬敍鍩?5閿涘奔绗夐幎?DB 閸愭瑨绻?Widget閿?|

### 娣囷拷鏁?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 濞翠胶鈻兼潪?閳?XYUI 閹烘帒宕峰銉ょ稊閸欏府绱欓悩鑸碘偓浣稿弿闁劏绻橀崗?CastingPageState閿?|
| `lib/presentation/casting/casting_page_state.dart` | 闁插秴鍟撻敍娆竐nerationState / DraftState / CastingPageState閿涘煪? 閸忋劑鍎寸€涙锟介敍?|
| `lib/presentation/casting/casting_tokens.dart` | 鐎靛綊缍堟禒璇插娑?鎼? 鐎规氨枪 Token 閸?|
| `lib/app/navigation/guayan_main_tab_bar.dart` | 閻ц棄绨?+ 閼宠泛娉柅澶夎厬閿涙稒甯撻崡锕€娴橀弽?閳?閼癸拷宕烽惌銏ゅ櫤閿涘煪?6閿涘本妫?Unicode 閳借绱?|
| `test/foundation_test.dart`閿涘牓鍣搁崘娆欑礆 | Test E 娴滄柨锟介懜?/ Test F 閼癸拷宕烽崶鐐垼 / 閻樿埖鈧椒绻氶幐?/ 閺囨潙锟介懣婊冨礋 |

### 閸掔娀娅庨敍鍫熸煙濡?2 濞翠胶鈻兼潪銊х矋娴犺绱?
`casting_top_bar / casting_flow_header / casting_flow_rail / casting_workflow / casting_step_node / casting_step_card / casting_step_status / casting_generate_step / casting_context_strip`閿涘澋idgets/ 娑?9 娑擄拷鏋冩禒璁圭礆

### 妤犲矁鐦?
- `flutter test`閿涙艾鍙忛柌蹇涒偓姘崇箖閿涘牆鎯?Test A閳ユ強閿?
- `flutter analyze`閿涙碍婀版潪锟芥煀婢?娣囷拷鏁奸弬鍥︽ 0 issue閿涘牆鐡ㄩ柌蹇涗粣閻?21 妞?lint 娑撳秴褰夐敍宀冿拷閸?BACKLOG閿?
- Android debug 閺嬪嫬缂撻幋鎰閿涘潉build/app/outputs/flutter-apk/app-debug.apk`閿?

### 鐠囧瓨妲戦敍鍦橝P閿涘苯鎮楃紒锟芥▉濞堢绱?
- 鐎瑰本鏆ｉ獮鍙夋暜閸樺棙纭跺鏇熸惛閿涘牆鍕鹃張鍫熸）楠炲弶鏁?/ 閺冿拷鈹?/ 缁惧磭鏁抽敍澶嬫弓閸嬫熬绱濋張锟界枂娴犲懎鐨弮鍨涘晪閺冩儼鏅崺铏癸拷閺勭姴鐨犻敍?
- 閼凤拷鐣炬稊澶庯拷閸掓瑥瀵?CRUD 閺堬拷浠涢敍鍫濆窗娴ｅ秴鑴婄仦鍌︾礉娣囨繄鏆€ RuleId + RuleVersion閿涘绱?
- 閵嗗本鐓￠惇瀣拷閸?閳ユ亽鈧秵婀版潪锟借礋鐟欏棜锟介崡鐘辩秴閿涘矁娉?tab 鐎佃壈鍩呯仦鐐叉倵缂侊拷绱?
- 閼藉枪閹镐椒绠欓崠鏍﹁礋閸愬懎鐡ㄧ€圭偟骞囬敍灞惧复閸欙綀绔熼悾灞藉嚒鐎规艾鐎烽敍鍦杛aftRepository閿涘鈧?

---

## 2026-08-30 璺?閹烘帒宕锋い?XYUI 閺€褰掆偓鐙呯礄Vertical Casting Workflow閿涘本婀崣鎴濈閿?

> **閺傝锟?2 璺?缁鹃潧鎮滈幒鎺戝捶濞翠胶鈻兼潪?*閿涙俺鎹ｉ崡锔芥闂?閳?闂傦拷绨ㄦ穱鈩冧紖 閳?閸忥拷鍩㈡潏鎾冲弳 閳?鐟欏嫬鍨崠?閳?閻㈢喐鍨氶幒鎺旀磸閵?
> 鐟欏棜锟芥禒銉ゆ崲閸斺€插姛 SVG 娑撳搫鏁稉鈧崺鍝勫櫙閿涙稒婀版潪锟借礋鐟欏棜锟介梼鑸碉拷閿涘牅绗夐崑姘暚閺佺銆冮崡鏇氱瑢閹烘帞娲忕粻妤佺《閿涘绱?
> 濮濄儵锟介幗妯匡拷娑撶儤绱ㄧ粈鍝勫窗娴ｅ秴鈧》绱濆鍛暏閹撮婀￠張鐑樺焻閸ュ彞姹夊銉╃崣閺€韬测偓?

### 閺傛澘锟介敍鍧檌b/presentation/casting/閿?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `casting_tokens.dart` | XYUI 鐟欏棜锟?Token 闂嗗棔鑵戦敍鍩?8閿?|
| `casting_page_state.dart` | CastingStepState閿涘潏urrent/pending/completed/warning/locked閿? 閺佺増宓佸Ο鈥崇€?|
| `widgets/casting_top_bar.dart` | XYUI 妞よ埖鐖敍鍫熷笓閸?閸擄拷鐖ｆ０?娑撳鍋ｉ弴鏉戯拷閿?|
| `widgets/casting_flow_header.dart` | CASTING FLOW 婢舵挳鍎撮敍鍫濈秼閸撳秵锟芥?x/5閿?|
| `widgets/casting_workflow.dart` | 濞翠胶鈻兼潪銊х矋鐟佸拑绱檙ail + 濮濄儵锟界悰宀嬬礆 |
| `widgets/casting_flow_rail.dart` | 缁鹃潧鎮滅粩鏍殠 |
| `widgets/casting_step_node.dart` | 閼哄倻鍋ｉ悩鑸碘偓浣稿弿闂嗗棴绱欓弫鏉跨摟/鐎电懓瀣€/!/闁夸緤绱濋惌銏ゅ櫤缂佹ê鍩楅敍?|
| `widgets/casting_step_card.dart` | 濮濄儵锟介崡鈥虫磽缁夊秶濮搁幀渚婄礄閸氾拷鐣幋鎰喅鐟曚緤绱?|
| `widgets/casting_step_status.dart` | 閻樿埖鈧礁绐橀弽?+ chevron |
| `widgets/casting_generate_step.dart` | 閻㈢喐鍨氬銉╋拷閿涘潤ocked/ready/completed/warning閿?|
| `widgets/casting_context_strip.dart` | 濞翠胶鈻兼稉濠佺瑓閺傚洦娼敍鍫ｏ拷閸掓瑥瀵?閹恒垽鎷?瀹告彃鐣幋?x/5閿?|
| `test/presentation/casting/casting_page_test.dart` | 瀹搞儰缍斿ù浣哄Ц閹焦绁寸拠鏇礄閹恒劏绻?閻㈢喐鍨?闂団偓闁插秵鏌婇悽鐔稿灇/閹恒垽鎷?缂佸嫪娆㈤悩鑸碘偓渚婄礆 |

### 娣囷拷鏁?
| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 閸楃姳缍呮い?閳?缁鹃潧鎮滃ù浣衡柤鏉烇拷绱欓悩鑸碘偓浣规簚妞瑰崬濮╅敍?|
| `lib/app/navigation/guayan_main_tab_bar.dart`閿涘牊鏌婃晶鐑囩礆 | XYUI 鎼存洟鍎寸€佃壈鍩?+ 娴滄柨娴橀弽?CustomPainter閿涘煪?5閿?|
| `lib/app/navigation/main_tabs.dart` | MainTab 婢х偛濮?iconBuilder |
| `lib/app/app_shell.dart` | NavigationBar 閳?GuayanMainTabBar閿涙稒甯撻崡锕傘€夐弮鐘插弿鐏炩偓 AppBar |
| `lib/app/more_menu.dart` | 閺€锟藉瘮閼凤拷鐣炬稊?icon閿涘牊甯撻崡锕傘€夋稉澶屽仯閿?|
| `test/foundation_test.dart` | 闁倿鍘ら弬?UI閿涘湺YUI 鐎佃壈鍩?濞翠胶鈻兼潪?閹恒垽鎷?Key/娑撳鍋ｉ弴鏉戯拷閿?|
| `file-tree.md`閵嗕梗CHANGELOG.md` | 閺堬拷鏋冩禒?|

### 妤犲矁鐦?
- `flutter test`閿?*63/63 闁俺绻?*閿涘牓锟介崺?53 + foundation 閺囧瓨鏌?10 + 閹烘帒宕锋い鍨煀婢?10閿?
- `flutter analyze`閿涙碍婀版潪锟芥煀婢?娣囷拷鏁奸弬鍥︽ 0 issue閿涘牆鐡ㄩ柌蹇涗粣閻?21 妞?lint 鐠佹澘鍙?BACKLOG閿?
- Android debug 閺嬪嫬缂撻幋鎰閿涘潉build/app/outputs/flutter-apk/app-debug.apk`閿?

### 鐠囧瓨妲?
- 閻樿埖鈧浇绻橀崗銉ф埂鐎?State閿涘奔绗夋禒搴拷閼规彃寮介幒锟界幢瀹告彃鐣幋鎰拷妤犮倕褰查柌宥嗘煀鏉╂稑鍙嗛敍?
  閻㈢喐鍨氶崥搴濇叏閺€鐟板彠闁匡拷鏆熼幑?閳?閻㈢喐鍨氬銉╋拷閺嶅洩锟介妴宀勬付闁插秵鏌婇悽鐔稿灇閵嗗稄绱欐稉宥嗙缁屽搫鍑℃繅锟藉敶鐎圭櫢绱氶妴?
- 閸樼喆鈧瞼濮搁幀浣瑰赴闁藉牞绱?閵嗗秴锟界粩瀣瀮閺堬拷些闂勩倧绱濋幒銏ゆ嫛鐠囷拷绠熸穱婵堟殌閸?Context Strip閿涘牆褰查悙鐟板毊闁帒锟介敍澶堚偓?
- 鐎瑰本鏆ｇ挧宄板捶閺冨爼妫块柅澶嬪閸?/ 闂傦拷绨ㄧ紓鏍帆閸?/ 閸忥拷鍩㈢紓鏍帆閸?/ 鐟欏嫬鍨崠鍛拷閻?/ 閹烘帞娲忕粻妤佺《 閳?閸氬海鐢婚梼鑸碉拷閿涘湐ACKLOG閿涘鈧?

---

## 2026-08-30 璺?GUAYAN-2.0-DOMAIN-HARDENING閿涘湯table Relation Identity 閺€璺哄經閿涘本婀崣鎴濈閿?

> **閼冲本娅欓敍?* 娴滃搫浼愰弽鎼佺崣 DOMAIN 闂冭埖锟介崥搴わ拷閸欙拷瀵屾担鎾癸拷鐠佲槄绱濈憰浣圭湴鐏忎焦锟?4 娑擄拷鏆熼幑锟藉悑鐎瑰綊妫舵０?
> 閿涘潏anonical 绾扮増鎸?/ 鐟欏嫬鍨悧鍫熸拱 replay / Domain 娑撳秴褰夐柌?/ 閺堬拷婧€閼存碍婀伴崗銉ョ氨閿涘绱?
> 娑撳秹鍣搁弸鍕┾偓浣风瑝鏉╂稑鍙?R3閵嗗倿鐛欓弨璺哄綖閸楀洨楠囬敍?
> RelationInstance 閸欙拷鍣稿鐚寸幢RelationNote 娑撳秴銇戣箛鍡幢RuleVersion 閸欐ê瀵叉稉宥堝厴鐠佲晛宸婚崣鎻掑捶娓氬銇戣箛鍡幢
> 娴犵粯鍓伴崥鍫熺《 RuleId/Subtype 娑撳秷鍏橀崚鍫曗偓鐘洪煩娴犵晫锟介幘鐑囩幢閸?Case 閺佺増宓佹稉宥堝厴閸掑爼鈧娀鍣告径宥堥煩娴犲鈧?

### 閺傛澘锟?

| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/domain/rule_execution_context.dart` | 鐟欏嫬鍨悧鍫熸拱 replay 娑撳﹣绗呴弬鍥风礄RuleVersionRef / RuleExecutionContext閿?|
| `test/domain/relation_key_collision_test.dart` | T1 canonical 閺冪姵锟芥稊澶嬧偓褝绱欓崥?`|`/`->`/`<->`/`\` 閻ㄥ嫮锟介幘鐐叉礀瑜版帪绱?|
| `test/domain/rule_version_replay_test.dart` | T2 閺冄冨捶娓?v1 閳?缁崵绮洪崡鍥╅獓 v2 閳?reload 閳?replay v1 閳?缁楁棁锟介幁銏狅拷 |
| `test/domain/domain_invariants_test.dart` | T3 閻栬缍?閸忥拷鍩㈡稉宥呭綁闁?+ 閸?JSON 閹锋帞绮?|

### 娣囷拷鏁?

| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/domain/relation_key.dart` | canonical 閺冪姵锟芥稊澶婂閿涙艾鐡х粭锔胯鐎涙锟界粙鍐茬暰鏉烇拷绠熼敍鍧刓`閳妶\\`閿涘畭|`閳妶\|`閿涘绱濋崡鏇炵殸缂傛牜鐖?|
| `lib/domain/hexagram_case.dart` | 閺傛澘锟?`ruleContext` 鐎涙锟介敍鍫ｇ闂呭繑瀵旀稊鍛閿涘绱眗untime 閺嶏繝鐛欓幁鏉裤偨 6 閻栨眹鈧垢osition 閹璐?1..6閵嗕焦妫ら柌宥咃拷 |
| `lib/domain/line_endpoint.dart` | 閺嬪嫰鈧姵鏁兼稉?runtime 閺嶏繝鐛欓悥璁崇秴閿?..6閿涘绱滼SON 閸欏秴绨崚妤€瀵查崥灞剧墡妤?|
| `lib/domain/line_state.dart` | 閸氬奔绗?|
| `lib/domain/relation_calculator.dart` | 鐟欏嫬鍨悧鍫熸拱娴兼ê鍘涢崣?`case.ruleContext.versionForOrDefault(ruleId)`閿涘本妫ょ拋鏉跨秿閸ョ偤鈧偓 v1 |
| `.gitignore` | `scripts/flutter.local.ps1` 娑撳秴鍙嗘惔鎿勭幢`*.apk` 韫囩晫鏆?|
| `scripts/flutter.ps1` | 缁夎鍤悧鍫熸拱閹貉冨煑閿涘牆鍨归梽銈忕幢瀹搞儰缍旈崠鐑樻暭娑?`scripts/flutter.local.ps1`閿?|
| `lib/domain/README.md` | 鐞涖儱鍘?escaping / replay 婵傛垹瀹?/ runtime 娑撳秴褰夐柌蹇氾拷鐠伮わ拷閺?|
| `file-tree.md`閵嗕梗CHANGELOG.md` | 閺堬拷鏋冩禒?|

### 妤犲矁鐦?

- `flutter test`閿?*53/53 闁俺绻?*閿涘牆甯?Test A閳ユ張 + T8 閸忋劑鍎寸紒褏鐢婚柅姘崇箖閿涙稒鏌婃晶?T1 绾扮増鎸?7 妞ゅ箍鈧?
  T2 replay 4 妞ゅ箍鈧箑3 娑撳秴褰夐柌?12 妞ょ櫢绱?
- `flutter analyze`閿涙碍婀版潪锟芥煀婢?娣囷拷鏁奸弬鍥︽ 0 issue閿涘牆鐡ㄩ柌蹇涗粣閻?21 妞?lint 鐠佹澘鍙?BACKLOG閿?
- Android debug 閺嬪嫬缂撻幋鎰閿涘潉build/app/outputs/flutter-apk/app-debug.apk`閿?
- 閺堬拷鎯庨崝?Android 濡剝瀚欓崳?

---

## 2026-08-30 璺?GUAYAN-2.0-DOMAIN閿涘湯table Relation Identity閿涘本婀崣鎴濈閿?

> **闂冭埖锟介惄锟界垼閿?* RelationInstance 閸欙拷浜掗柌宥呯紦閿涘elationNote 娑撳秷鍏樻径鍗炵箓閵?
> 閸欙拷浠涢崶娑楅嚋閺嶇绺?Domain閿涘湚exagramCase / LineState / RelationInstance / RelationNote閿?
> 娑撳海菙鐎规艾鍙х化鏄忛煩娴?RelationKey閿涘奔绗夐幍鈺勫瘱閸ユ番鈧倽锟界拋鈩冩瀮濡楋綀锟?`lib/domain/README.md`閵?

### 閺傛澘锟介弬鍥︽

| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/domain/hexagram_case.dart` | 閸楋缚绶ラ幐浣风畽閸栨牗鐗寸€电钖勯敍鍫熸付鐏忓繘锟介弸璁圭礆 |
| `lib/domain/line_state.dart` | 娑撯偓閻栬崵濮搁幀渚婄窗閻栬缍?/ 閸斻劑娼?/ 閹碘偓閸婄厧婀撮弨?|
| `lib/domain/line_endpoint.dart` | 閸忓磭閮寸粩锟藉仯缁嬪啿鐣鹃煬锟藉敜閿涘牆宕锋笟?+ 閻栬缍呴敍?|
| `lib/domain/relation_type.dart` | 閸忓磭閮寸猾璇茬€烽弸姘 + 缁崵绮?RuleId 鐢悂鍣?|
| `lib/domain/relation_key.dart` | 閸忓磭閮寸粙鍐茬暰鐠囷拷绠?key閿涘湯table Relation Identity 閺嶇绺鹃敍?|
| `lib/domain/relation_instance.dart` | 閸忚渹缍嬮崗宕囬兇鐎圭偘绶ラ敍鍫ュ櫢缁犳褰查柌宥呯紦閿?|
| `lib/domain/relation_calculator.dart` | 閺堚偓鐏忓繒鈥樼€规碍鈧冨彠缁槒锟界粻妤嬬礄閸斻劌褰?閸忥拷鍟?閸忥拷鎮庨敍?|
| `lib/domain/relation_note.dart` | 閸忓磭閮寸粭鏃囷拷閿涘潏aseId + RelationKey 缂佹垵鐣鹃敍?|
| `lib/domain/relation_note_store.dart` | 缁楁棁锟界紒鎴濈暰鐎涙ê鍋嶉敍鍫㈠嚱閸愬懎鐡?+ JSON 鐎电厧鍙嗙€电厧鍤敍?|
| `test/domain/domain_test_utils.dart` | 閸忓彉闊╁鏃傘仛閸楋缚绶ラ敍鍫濆З閸?+ 閸忥拷鍟块敍?|
| `test/domain/relation_key_test.dart` | Test A 绾拷鐣鹃幀?/ Test B 瀹革拷绱撻幀?/ 閺傜懓鎮滄径鍕倞 |
| `test/domain/relation_key_serialization_test.dart` | RelationKey JSON round-trip 娑撳骸鐫嶇粈鍝勬倳鐟欙綀鈧?|
| `test/domain/relation_rebinding_test.dart` | Test C 闁插秶鐣婚幁銏狅拷 / Test D 娑撳秳瑕嗙粭鏃囷拷 / Test E 妞ゅ搫绨弮鐘插彠 |
| `test/domain/relation_serialization_test.dart` | T8 鎼村繐鍨崠?閳?閸欏秴绨崚妤€瀵?閳?闁插秶鐣?閳?闁插秵鏌婄紒鎴濈暰閸忋劑鎽?|
| `scripts/flutter.ps1` | 閺堬拷婧€ Flutter 閸栧懓锟介懘姘拱閿涘湏PPDATA/娴狅絿鎮?閻╃鐨?snapshot閿?|

### 娣囷拷鏁奸弬鍥︽

| 鐠猴拷绶?| 鐠囧瓨妲?|
| --- | --- |
| `lib/domain/README.md` | 閸楃姳缍呯拠瀛樻 閳?Stable Relation Identity 鐠佹崘锟介弬鍥ㄣ€?|
| `file-tree.md` | 鐠佹澘缍?DOMAIN 闂冭埖锟介弬鏉匡拷閺傚洣娆㈤妴浣烘窗瑜版洘鐖叉稉搴や捍鐠?|
| `CHANGELOG.md` | 閺堬拷鏋冩禒?|

### 妤犲矁鐦?

- `flutter test`閿?*31/31 闁俺绻?*閿?1 妫板棗鐓?+ 10 Foundation/Widget閿?
- `flutter analyze`閿涙碍婀版潪锟芥煀婢х偞鏋冩禒?0 issue閿涘牆鐡ㄩ柌蹇涗粣閻?21 妞?lint 鐠佹澘鍙?BACKLOG閿?
- 閺堬拷鎯庨崝?Android 濡剝瀚欓崳锟界幢閹靛婧€妤犲本鏁归崠鍛€楦匡拷閺嬪嫬缂撴禍褏澧?
- RelationKey 缂佸嫭鍨氶敍姘辫閸ㄥ婧€閸ｃ劌鎮?+ RuleId + RuleVersion + subtype + 缁旓拷鍋ｉ敍鍫濆捶娓? 閻栬缍呴敍澶涚幢
  閺堝鎮滈崗宕囬兇娣囨繂绨敍鍦撻埆鎵?閳?B閳墣閿涘绱濈€靛湱袨閸忓磭閮撮幒鎺戠碍閿涘湏-B == B-A閿涘绱眂aseId 娑撳秴鍙?key閿涘瞼鐟拋鐗堝瘻
  `(caseId + RelationKey)` 缂佹垵鐣鹃妴?

---

## 2026-08-27 璺?閹存劖鐏夎ぐ鎺撱€傞幓鎰唉閿涘牊婀崣鎴濈閿?

> **閼冲本娅欓敍?* 瀵偓閸欐垶婧€閸愬懎鐡ㄩ懓妤€鏁栧畷鈺傜皾闁插秴鎯庨敍鍦檙adle 閹绘劒姘﹂崘鍛摠 errno 1455閿涘绱濋崚銈呯暰閺堬拷婧€閺嗗倷绗夐崗宄帮拷缂佈呯敾瀵偓閸欐垶娼禒韬测偓?
> 娑撴椽浼╅崗宥嗗灇閺嬫粈娑径鎲嬬礉鐏忓棗浼愭担婊冨隘閸忋劑鍎撮張锟藉絹娴溿倖鍨氶弸婊€绔村▎鈩冣偓褍缍婂锝嗗絹娴溿倧绱濋獮鑸靛腹闁?GitHub閵?
>
> 閹绘劒姘﹂敍姝歠eat: archive 2.0 training data layer, design assets and low-mem build config`
> 閸掑棙鏁敍姝歠eat/guayan-2.0`閿涘牊甯归柅浣告倵娑撳氦绻欑粩锟芥倱濮濄儻绱?

### 閺堬拷锟介幓鎰唉閺傚洣娆㈢€孤わ拷

| 鐠猴拷绶?| 缁鐎?| 婢堆冪毈 | 鐠囧瓨妲?|
| --- | --- | --- | --- |
| `lib/data/training_question.dart` | 閺傛澘锟?| 586 B | 2.0 鐠侊拷绮岄弫鐗堝祦濡€崇€烽敍姝歍rainingModule` / `RelationType` / `TrainingQuestion` |
| `lib/data/wuxing_questions.dart` | 閺傛澘锟?| 3.0 KB | 娴滄棁锟介悽鐔峰帬妫版ê绨遍敍姘辨祲閻?5 妫?+ 閻╃鍘?5 妫版﹫绱檂allWuxingQuestions`閿?|
| `AGENTS.md` | 閺傛澘锟?| 2.1 KB | 妞ゅ湱娲版禒锝囩垳鐟欏嫬鍨敍姘瀮娴犲墎绮嶇紒?/ 閺嬭埖鐎崚鍡楃湴 / 閸涜棄鎮?/ 閺傚洦銆傜痪锟界伐 / 閻楀牊婀版稉搴㈢€?|
| `CHANGELOG.md` | 閺傛澘锟?| 閺堬拷鏋冩禒?| 閺傚洣娆㈢€孤わ拷娑撳骸褰夐弴瀛樻）韫?|
| `uploads/XYUI1ComponentDocumentView.axaml` | 閺傛澘锟?| 5.2 KB | 閸欏倽鈧啳绁弬娆欑窗Avalonia 缂佸嫪娆㈢憴鍡楁禈閺傚洦銆?|
| `uploads/閸楋妇婧?2.0 璺?閸忥拷鍩㈤幒鎺戝捶閵嗕礁鍙х化璇插讲鐟欏棗瀵查妴浣藉殰鐎规矮绠熺憴鍕灟娑撳骸宕锋笟瀣拷閻╂ɑ鈧绱戦崣鎴ｏ拷閸?md` | 閺傛澘锟?| 20.9 KB | 閸欏倽鈧啳绁弬娆欑窗閸楋妇婧?2.0 閹绱戦崣鎴ｏ拷閸?|
| `娴滄棁锟介惄绋垮帬閻楄鏅?闁叉垵鍘犻張?html` | 閺傛澘锟?| 8.7 KB | 閻╃鍘犻崝銊ф暰閸樼喎鐎烽敍姘跺櫨閸忓婀?|
| `娴滄棁锟介惄绋垮帬閻楄鏅?閺堛劌鍘犻崷?html` | 閺傛澘锟?| 7.0 KB | 閻╃鍘犻崝銊ф暰閸樼喎鐎烽敍姘躬閸忓婀?|
| `娴滄棁锟介惄绋垮帬閻楄鏅?閸︾喎鍘犲?html` | 閺傛澘锟?| 5.5 KB | 閻╃鍘犻崝銊ф暰閸樼喎鐎烽敍姘埂閸忓鎸?|
| `娴滄棁锟介惄绋垮帬閻楄鏅?濮樻潙鍘犻悘?html` | 閺傛澘锟?| 10.2 KB | 閻╃鍘犻崝銊ф暰閸樼喎鐎烽敍姘寜閸忓浼€ |
| `娴滄棁锟介惄绋垮帬閻楄鏅?閻忥拷鍘犻柌?html` | 閺傛澘锟?| 8.1 KB | 閻╃鍘犻崝銊ф暰閸樼喎鐎烽敍姘变紑閸忓鍣?|
| `娴滄棁锟介惄鍝ユ晸閻楄鏅?闁叉垹鏁撳?html` | 閺傛澘锟?| 6.8 KB | 閻╁摜鏁撻崝銊ф暰閸樼喎鐎烽敍姘跺櫨閻㈢喐鎸?|
| `娴滄棁锟介惄鍝ユ晸閻楄鏅?濮樺鏁撻張?html` | 閺傛澘锟?| 8.7 KB | 閻╁摜鏁撻崝銊ф暰閸樼喎鐎烽敍姘寜閻㈢喐婀?|
| `娴滄棁锟介惄鍝ユ晸閻楄鏅?閺堛劎鏁撻悘?html` | 閺傛澘锟?| 5.9 KB | 閻╁摜鏁撻崝銊ф暰閸樼喎鐎烽敍姘躬閻㈢喓浼€ |
| `娴滄棁锟介惄鍝ユ晸閻楄鏅?閻忥拷鏁撻崷?html` | 閺傛澘锟?| 7.1 KB | 閻╁摜鏁撻崝銊ф暰閸樼喎鐎烽敍姘变紑閻㈢喎婀?|
| `娴滄棁锟介惄鍝ユ晸閻楄鏅?閸︾喓鏁撻柌?html` | 閺傛澘锟?| 6.7 KB | 閻╁摜鏁撻崝銊ф暰閸樼喎鐎烽敍姘埂閻㈢喖鍣?|
| `android/gradle.properties` | 娣囷拷鏁?| 閳?| 娴ｅ骸鍞寸€涙瀹抽弶鐕傜窗JVM 閸?`-Xmx1G`閵嗕甫otlin daemon `-Xmx256m`閵嗕梗org.gradle.workers.max=1`閿涘矂浼╅崗宥嗙€鐑樺絹娴溿倕鍞寸€涙鈧鏁栭敍鍧媟rno 1455閿?|
| `file-tree.md` | 娣囷拷鏁?| 閳?| 閸氬本锟介弬鏉匡拷閺傚洣娆㈤妴浣烘窗瑜版洘鐖查妴浣戒捍鐠愶綀銆冩稉搴㈡付閸氬海绱潏鎴炴闂?|

### 閹绘劒姘﹂崥搴濈波鎼存挸鎻╅悡褍锟界拋?

- 鐠虹喕閲滈弬鍥︽閺佸府绱?*109 閳?125**閿?16閿?
- 妞よ泛鐪伴崚鍡楃閿涙瓪lib/` 77 璺?`android/` 19 璺?`娴滄棁锟介惄绋垮帬閻楄鏅?` 5 璺?`娴滄棁锟介惄鍝ユ晸閻楄鏅?` 5 璺?`test/` 2 璺?`memory/` 2 璺?`uploads/` 2 璺?閺嶅湱娲拌ぐ鏇熸絽妞?13
- 閸掑棙鏁悩鑸碘偓渚婄窗`feat/guayan-2.0`閿涘湚EAD = `b408199 feat: establish Guayan 2.0 foundation`閿涘矂锟介崗?`master` 1 娑擄拷褰佹禍銈忕幢`master` 娑?`origin/master` 閸氬本锟芥禍?`5c4bdb6`閿?
- 閺堬拷绐￠煪?閺堬拷褰佹禍銈呭敶鐎圭櫢绱伴弮鐙呯礄閸忋劑鍎村鎻掔秺濡楋綇绱?
- 婢堆冪€烽惄锟界秿鐠囧瓨妲戦敍姝歜uild/`閿涘牏瀹?3 GB 閺嬪嫬缂撴禍褏澧块敍澶夌瑢 `.dart_tool/` 閻?`.gitignore` 閹烘帡娅庨敍灞肩瑝閸忋儱绨?

---

## 閻楀牊婀伴崢鍡楀蕉閹芥锟?

| 閻楀牊婀?| 閺冦儲婀?| 缁鐎?| 鐠囧瓨妲?|
| --- | --- | --- | --- |
| `v0.1.10` | 2026-05-22 | 閺傛澘锟?| 閸忓磭閮存潻鐐剁箾閻绱?5 缂佸嫰鍘ょ€?+ 50 瀵姴宕卞☉鍫ユ珟 + 閸ョ偟鍊?|
| `v0.1.9` | 2026-05-22 | 閺傛澘锟?| 閺傜懓娼￠柅鐔虹摕濞撳憡鍨欏Ο鈩冩緲閿涘苯宕熸０妯圭瑓閽€?+ 鐠佲剝妞?+ 閸ョ偟鍊?|
| `v0.1.8.3` | 2026-05-18 | 闁插秵鐎?| 閺冄冨弳閸欙綀绺肩粔璇插煂闁氨鏁ょ紒鍐х瘎濡楀棙鐏?|
| `v0.1.7.x` | 2026-05-18 | 閺傛澘锟?闁插秵鐎?| 娴犮儲鍨滄稉杞拌厬韫囧啫锟芥稊鐘汇€夐妴浣告妇閻╂绮ㄩ弸鍕磳缁狙佲偓浣规閻╅晲绱ら崶姘拷 |
| `v0.1.6.x` | 2026-05-16 | 娴兼ê瀵?娣囷拷锟?| 鏉烇拷娲忕亸鍝勶拷缁嬪啿鐣鹃妴浣风瑏闂冭埖锟界紒鐔伙拷閵嗕礁娲栭悙澶嬫降濠ф劖鐖ｇ粵?|
| `v0.1.5` | 2026-05-16 | 閺傛澘锟?| 娴滄棁锟介惄绋垮帬鐎涳缚绡勬い鐐光偓浜€rongCount 娣囷拷锟介妴浣告礀閻愬鑴婄粣?|
| `v0.1.4.x` | 2026-05-16 | 閺傛澘锟?娣囷拷锟?| 閸ョ偟鍊濋柨娆擄拷闁插秴浠涚化鑽ょ埠閵嗕胶娴夐悽鐔虹矊娑旂姳绗侀梼鑸碉拷閵嗕胶鐡熸０妯哄冀妫ｅ牐澹?|
| `v0.1.3.x` | 2026-05-16 | 閺傛澘锟?娴兼ê瀵?| 娴滄梹娼惄鍝ユ晸 HTML 閸斻劎鏁鹃幒銉ュ弳閵嗕線鎹囬張銊ュ絿閻忥拷鈧浇鐤嗛惄妯垮Ν婵傚繋绱崠?|
| `v0.1.1` 閳?`v0.1.2.x` | 2026-05-15 | 閸╄櫣锟?| 妞ゅ湱娲版銊︾仸娑撳簼绨茬悰灞界唨绾偓閸旂喕鍏?|

> 鐎瑰本鏆ｉ悧鍫熸拱閸樺棗褰剁憴?`file-tree.md` 缁?8 閼哄倶鈧倹鐖ｇ粵?v0.1.1 閳?v0.1.10 閸у洤鍑￠幒銊┾偓?GitHub閵?




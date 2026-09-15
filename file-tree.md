# 椤圭洰鏂囦欢鏍?鈥?鍗︾溂璁粌鍣?

> **褰撳墠鐗堟湰锛?* v0.1.11
> **鍒涘缓鏃堕棿锛?* 2026-05-15
> **鏈€鍚庣紪杈戯細** 2026-09-15 10:00

> 鏈枃浠剁敤浜庤褰曢」鐩洰褰曠粨鏋勩€佹ā鍧楄亴璐ｄ笌鐗堟湰婕旇繘銆?
> 姣忔 AI 鎴栦汉宸ヤ慨鏀逛唬鐮佸悗锛屽娑夊強鏂板銆佸垹闄ゃ€侀噸鍛藉悕鏂囦欢锛屽繀椤诲悓姝ユ洿鏂版湰鏂囨。銆?

---

## R5-B-FIX · Rule Engine SRP refactor (2026-09-15)

> 解决 R5-B 期间产生的 5+100 行数限制报错，拆分了 rule_engine, stage_runner, action_executor, operators 等过大的文件。同时记录了 R5-B 中的治理事故：bulk replace, multiple restores/checkouts, broad adds, premature commits, amend 等等。

### 规则执行引擎 (lib/domain/rules/engine/)

| 文件/目录 | 职责 |
| --- | --- |
|
ule_engine.dart | 外观模式，规则引擎入口 |
| nalysis_stage_executor.dart | 负责遍历各个阶段执行 |
| stage_runner.dart | 负责单个阶段(Stage)内的多次迭代(Fixpoint convergence) |
| stage_iteration_runner.dart | 负责执行一次内部循环的求值和合并过程 |
| ction_executor.dart | 根据规则的结果分发具体动作 |
| ction_output_factory.dart | 分离 Action 的创建和执行 |
| operators/structural_operators.dart | barrel 导出 |
| operators/fact_operators.dart | 事实类算子(relative, spirit, nayin) |
| operators/relation_operators.dart | 关系类算子(generate, ru_mu 等) |
| operators/state_operators.dart | 状态类算子(xun_kong 等) |
| operators/tag_operator.dart | 标记类算子(has_tag) |
| ... | 其他执行器相关 |

## R5-A 路 Rule Schema + AST + Core Domain (2026-09-14)

> 鏋勫缓鍏埢瑙勫垯寮曟搸鐩稿叧鐨?Canonical Domain Contract锛圧ule Schema銆丄ST銆丗actSnapshot銆丷ulePack銆丒vidence绛夛級銆傛湰杞函鏁版嵁濂戠害锛屾棤鎵ц寮曟搸瀹炵幇銆?

### 鏂板瑙勫垯妯″瀷灞?(`lib/domain/rules/`)

| 鏂囦欢/鐩綍 | 鑱岃矗 |
| --- | --- |
| `core/rule_definition.dart` 绛?| 瀹氫箟鍗曚竴瑙勫垯缁撴瀯銆侀樁娈?(RuleStage)銆佹潵婧?(RuleOrigin) |
| `ast/rule_expr.dart` 绛?| AST 缁撴瀯鑺傜偣 (ALL/ANY/NOT/PREDICATE) 鍙婂叾缁戝畾绯荤粺 |
| `facts/fact_snapshot.dart` 绛?| 寮轰笉鍙彉鍘熷浜嬪疄璁板綍鍙婅涔夋爣璇?(SemanticRef) |
| `packs/rule_pack.dart` 绛?| 缁勫悎瑙勫垯鐨?RulePack 濂戠害鍙?COMMON/TOPIC 浣滅敤鍩熼檺鍒?|
| `evidence/evidence_node.dart` 绛墊 Evidence Identity 浠ュ強 `TagIdentity` 鐨勮韩浠藉绾?|
| `data/rules/codec/` 涓?`schema/` | RuleCodec (Canonical JSON 绛変环缂栬В鐮? 鍙?Validator 鍗犱綅瀹炵幇 |

---

## R4 路 鍩虹鍏崇郴寮曟搸锛?026-09-13锛屾湭鍙戝竷锛?
> 璇︾粏濂戠害瑙?`lib/domain/README.md` 鐨勩€孯4 路 鍩虹鍏崇郴寮曟搸銆嶄竴鑺傘€?

### 鍐荤粨濂戠害锛堢敤鎴锋壒鍑嗭級

```text
1. 浜旇鐩哥敓/鐩稿厠 = 鏈崷鍏埢涓や袱绌蜂妇 C(6,2)=15 瀵癸紱鍚屼簲琛屼笉浜у嚭銆?
   R4 鏄€屼簨瀹炶处鏈€嶏紝涓嶅垽鏂綔鐢ㄥ姏 鈥斺€?浣滅敤鍔涗氦缁欏悗缁?Effect / Rule 灞傘€?
   UI 鐢ㄧ瓫閫夊櫒鎺у埗鍙鍏崇郴锛屼笉寰椾负鍥鹃潰绠€娲佸弽鍚戣鍓?Domain 鏁版嵁銆?
2. 鏂板 RelationEndpoint 棰嗗煙绔偣鎶借薄锛坰ealed锛夛細鐖?/ 鏈堝缓 / 鏃ヨ景銆?
   RelationKey 鐨?source/target 蹇呴』琛ㄧず鐪熷疄璇箟瀵硅薄锛?
   绂佹涓洪潪鐖诲璞″埗閫犺櫄鍋?position锛堜笉鍐?month-1锛夈€?
   LineEndpoint 闄嶇骇涓虹粯绾垮畾浣嶅眰绫诲瀷锛屼笉鍐嶆槸韬唤鐪熸簮銆?
3. HexagramCase 鎸佹湁鍙€?CalendarSnapshot锛堟湀寤烘敮 + 鏃ヨ景骞叉敮锛夈€?
   瀛樸€岃捣鍗﹀綋鏃惰瀹氱殑缁撴灉銆嶏紝涓嶅瓨璁＄畻鍣?鈥斺€?鏁版嵁鍖呭崌绾т笉寰楄鍘嗗彶鍗︿緥鏈堝缓婕傜Щ銆?
   calendar 缂哄け 鈫?鏈?鏃ュ叧绯讳笉浜у嚭 + 璇婃柇鎶ュ憡缂哄け锛涚姝㈣嚜鍔ㄨˉ绠椼€?
```

### 鏂板

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `lib/domain/relation_endpoint.dart` | 鍏崇郴绔偣棰嗗煙韬唤锛坰ealed锛歒aoEndpoint / MonthEndpoint / DayEndpoint锛?|
| `lib/domain/line_scope.dart` | 鍗︿晶锛堟湰鍗?/ 鍙樺崷锛夆€斺€?棰嗗煙姒傚康锛岀嫭绔嬫垚鏂囦欢渚涚鐐逛笌缁樼嚎灞傚叡鐢?|
| `lib/domain/calendar_snapshot.dart` | 璧峰崷褰撴椂鐨勫巻娉曞揩鐓э紙鏈堝缓鏀?+ 鏃ヨ景骞叉敮锛?|
| `lib/domain/relation_diagnostics.dart` | 鍏崇郴璁＄畻璇婃柇锛坢issingInputs / warnings锛?|
| `lib/domain/relation_rules/changed_lines.dart` | 鍔ㄥ彉 路 鍥炲ご鐢?路 鍥炲ご鍏?|
| `lib/domain/relation_rules/branch_pairs.dart` | 鍏啿 路 鍏悎锛堟敼鐢?`DiZhi.chong/he`锛屽垹鎺夎嚜甯︽槧灏勮〃锛?|
| `lib/domain/relation_rules/wu_xing_pairs.dart` | 浜旇鐩哥敓 路 鐩稿厠锛堝叚鐖讳袱涓わ紝浜嬪疄璐︽湰锛?|
| `lib/domain/relation_rules/month_day.dart` | 鏈堝缓 / 鏃ヨ景鍩虹浣滅敤 |
| `lib/domain/relation_rules/rule_support.dart` | 瑙勫垯鍏辩敤锛坮eplay 鐗堟湰鍙栧€?/ 鍦版敮瑙ｆ瀽 / 绔偣鏋勯€狅級 |
| `test/domain/relation_engine_r4_test.dart` | 涔濈被鍏崇郴缁勬垚 + 绔偣涓嶅彉閲?|
| `test/domain/relation_engine_r4_facts_test.dart` | 浜旇浜嬪疄鍏崇郴 + 鏈堝缓/鏃ヨ景缁勬垚 |
| `test/domain/relation_engine_r4_inputs_test.dart` | 缂哄け杈撳叆璇婃柇 + 纭畾鎬у绾?|

### 淇敼

- `lib/domain/relation_calculator.dart`锛氭敼涓?R4 缂栨帓锛堝洓绫昏鍒欏悎骞躲€乧anonical 绋冲畾鎺掑簭銆?
  閲嶅 key 璀﹀憡銆佺己澶辫緭鍏ヨ瘖鏂級锛屽苟淇濈暀 `calculateRelations()` 鍏煎鍏ュ彛
- `lib/domain/relation_type.dart`锛氭柊澧?`sys.month_branch` / `sys.day_branch` 瑙勫垯 id
- `lib/domain/line_state.dart`锛氭柊澧炲彲閫?`changedBranch`锛堝彉鐖诲湴鏀紝鍥炲ご鐢?鍏嬪繀闇€锛?
- `lib/domain/hexagram_case.dart`锛氭柊澧炲彲閫?`calendar`锛堝巻娉曞揩鐓э級+ JSON round-trip
- `lib/domain/line_endpoint.dart`锛氶檷绾т负缁樼嚎瀹氫綅閿紝`LineScope` 绉诲叆 `line_scope.dart`
- `lib/presentation/review/review_case_adapter.dart`銆乣review_page_state.dart`锛?
  绔偣鏀逛负 `RelationEndpoint`锛堟湀/鏃ョ鐐逛笉鏄埢锛岀偣鐖讳笉鍛戒腑锛? 鏍囩鏀寔銆屾湀寤?/ 鏃ヨ景銆?

### 楠岃瘉

```text
flutter test                 278 / 278 PASS锛圧4 鏂板 19 椤癸級
flutter analyze lib/domain test/domain   No issues found
lib/domain 鏂囦欢 > 150 琛?     0
Gate A verify                PASS锛坓ate-a 6 浠芥枃妗?SHA256 6/6 IDENTICAL锛屾湭鍙楀奖鍝嶏級
```

> 鈿狅笍 鏈疆**鏁呮剰**鏀瑰彉浜嗘棦鏈夋祴璇曟湡鏈涳紙闈炲墛寮憋級锛?
> 绔偣 canonical 鐢?`original-3` 鍙樹负 `yao:original:3`锛堝绾?2锛夛紱
> 婕旂ず鍗︿緥鍏崇郴鏁扮敱 2 鍙樹负 16锛堝姩鍙?1 + 鍏啿 1 + 浜旇 14锛屽绾?1锛夈€?
> 鏃?JSON 浠嶅彲瑙ｆ瀽锛坄RelationEndpoint.fromJson` 鍏煎鏃?`kind` 鐨勬棫绔偣缁撴瀯锛夈€?

---

## POST-R3-GOV-01 鈥?娌荤悊鏀跺彛锛?026-09-12锛屾湭鍙戝竷锛?

> 涓嶅彂鐗堛€佷笉鏀逛骇鍝佷唬鐮侊細`lib/` `test/` `assets/` diff = 0銆?
> 鍙仛涓や欢浜嬶細鎶?`tool/gate_a/` 鏀跺埌 **鐩綍鐩存帴鏂囦欢 鈮?5銆丏art 鏂囦欢 鈮?100 琛?*锛?
> 浠ュ強**鍏堜慨妫€鏌ュ櫒**鈥斺€旀湰杞彂鐜颁簡 5 澶勩€屾鏌ュ櫒缁欏亣缁撹銆嶇殑闅愭偅銆?

### S0 浜嬪疄鏍搁獙锛氭鏌ュ櫒鏈韩涓嶅彲淇?

鐢ㄧ浜岀鍙鏂瑰紡锛圥owerShell 閫愮骇鏋氫妇锛夌嫭绔嬪鏍稿悗纭锛?

| # | 缂洪櫡 | 浜嬪疄 | 鍚庢灉 |
| --- | --- | --- | --- |
| 1 | `gov_selfcheck` 瑙勫垯 2 鏁伴敊 | 鐢?`listSync(recursive: true)` 鏁?*鍚庝唬鏂囦欢**锛涙牴鐩綍鍙暟鏂囦欢銆佹紡鎺夊叏閮?7 涓瓙鐩綍 | `cases/` 琚姤鎴愩€? 涓枃浠躲€嶃€乣reports/` 鏁板瓧鍐欐垚 9锛涜€岀姸鎬佹枃浠朵笌鎻愪氦 1541660 閮藉啓鐫€銆岃鍒?2 PASS銆嶁€斺€?*鍋?PASS** |
| 2 | `gate_a_runner.ps1` 8 涓ā寮忛噷 4 涓矾寰勫け鏁?| 鐩綍鎼縼锛?541660锛夊悗鏈悓姝ワ細`closeout`/`residual`/`enumerate`/`solve` 鍏ㄦ寚鍚戜笉瀛樺湪鐨勬枃浠?| `closeout` 鏍规湰璺戜笉璧锋潵锛屻€宑loseout PASS銆嶈繖绫昏瘉鎹笉鍙兘璇氬疄浜у嚭 |
| 3 | `check_imports.dart` 鐩茬偣 | 鍙鏌ヤ互 `.` 寮€澶寸殑 import锛宍import 'status/x.dart'`锛堟紡鍐?`../`锛夎**闈欓粯璺宠繃** | 妫€鏌ュ櫒鎶?OK锛岀敓鎴愬櫒闅忓悗缂栬瘧澶辫触 |
| 4 | 鐢熸垚鍣ㄥけ璐ユ椂 SHA 姣斿鏃犳剰涔?| 鐢熸垚鍣ㄦ病鎴愬姛 鈫?鏃ф枃妗ｄ粛鍦ㄧ洏涓?鈫?SHA 鏄剧ず銆孫K銆?| 绛変环鎬ц瘉鎹?*绌烘礊**鍗寸湅浼奸€氳繃 |
| 5 | 榛勯噾蹇収瀵硅灏炬晱鎰?| `core.autocrlf=true` 涓旀棤 `.gitattributes`锛歝heckout 鎶?LF 杩樺師鎴?CRLF | 鍐呭涓€瀛楁湭鏀癸紝瑙勫垯 3 鍗村繀鐒?*鍋?FAIL** |

### 淇

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `tool/gate_a/tools/gov/dir_scan.dart` | 瑙勫垯 2锛?*鐩存帴鏂囦欢**璁℃暟锛堥潪閫掑綊锛? 璇佹嵁琛?|
| `tool/gate_a/tools/gov/line_scan.dart` | 瑙勫垯 1锛欴art 鏂囦欢琛屾暟涓婇檺 |
| `tool/gate_a/tools/gov/doc_scan.dart` | 瑙勫垯 3锛氱敓鎴愭枃妗?SHA256 vs 榛勯噾蹇収锛堢己蹇収涓嶅緱褰?PASS锛?|
| `tool/gate_a/tools/gov/rules_regression.dart` | **瑙勫垯 0**锛氫复鏃跺す鍏疯嚜璇併€屾暟鐨勬槸鐩存帴鏂囦欢銆嶏紝鍏堣嚜璇佸啀鏌ヤ粨搴?|
| `tool/gate_a/tools/gov/gov_rules.dart` | 瑙勫垯缂栨帓 + 閫愮洰褰曡瘉鎹墦鍗?|
| `tool/gate_a/tools/checks/gov_selfcheck.dart` | 鏀逛负钖勫叆鍙ｏ紙瑙勫垯瀹炵幇鍏ㄩ儴绉诲叆 `tools/gov/`锛?|
| `tool/gate_a/gate_a_runner.ps1` | 妯″紡璺緞闆嗕腑鎴?`$Scripts` 琛ㄣ€佺己鏂囦欢鍗冲け璐ワ紱鏂板 `verify` 閾撅紙**鍏?preflight 妫€鏌ュ叏閮?9 涓ā寮忔槸鍚﹂兘鑳借В鏋?*锛屽啀 imports 鈫?generate 鈫?gov 鈫?selftest 鈫?cross锛涚敓鎴愬櫒澶辫触鍗崇粓姝㈠苟澹版槑 SHA 鏃犳剰涔夛級 |
| `tool/gate_a/tools/checks/check_imports.dart` | 鍙烦杩?`package:` / `dart:`锛涙敞閲婂唴绀轰緥涓嶅啀璇姤 |
| `.gitattributes`锛堟柊澧烇級 | `gate-a/*.md text eol=lf` 鈥斺€?鐢熸垚鏂囨。閿?LF锛岄粍閲戝揩鐓у湪浠讳綍鏈哄櫒涓婇兘鎴愮珛 |

### tool/gate_a/ 鐩綍鏍戯紙娌荤悊鍚庯紝63 涓?Dart 鏂囦欢锛屽叏閮?鈮?100 琛岋級

```text
gate_a_context.dart 37        gate_a_main.dart 44        gate_a_runner.ps1
astro/      cross_source 61 路 cross_source_rows 72 路 diag_oracle 83
            sun_longitude 69 路 sun_terms 89
cases/      derive 72
  data/     boundary_cases 94 路 classic_cases 60 路 normal_cases_a 79 路 normal_cases_b 70
  logic/    case_facts 81 路 case_model 100
commands/   digest 74 路 generate_reports 73
core/       audit/      hexagram_audit 54 路 najia_audit 26 路 palace_audit 47
            formatting/ format 43
            pillars/    case_pillars 36 路 pillar_tables 38 路 pillars 64
            time/       pack_loader 38 路 time_input 60
data/       hko_source 70 路 naoj_source 98 路 fixtures/hko 路 fixtures/naoj
reports/    day_report 68
  cases/    case_columns_table 49 路 case_line_table 51 路 case_report 52 路 master_table 66
  readme/   readme_checklist 78 路 readme_header 47 路 readme_instructions 17
            readme_sources 46
  solar_term/ boundary_section 64 路 term_fields 48 路 term_reference 87
              term_render 74 路 term_resolve 46
  status/   gate_criteria 86 路 gate_status 71 路 gate_truth_items 84
tools/      selftest 36锛堝叆鍙ｏ紝璺緞涓嶅彉锛?
  checks/   check_imports 63 路 enumerate_hexagrams 90 路 gov_selfcheck 31
            sha256 87 路 solve_cases 52
  diag/     oracle_residual 89 路 precision_closeout 80 路 residual_anchors 32
  gov/      dir_scan 81 路 doc_scan 33 路 gov_rules 98 路 line_scan 31
            rules_regression 100
  selftest/ checks_astro 93 路 checks_liuchong 89 路 checks_pillars 70
            checks_tables 61 路 suite 62
```

### 姣忎釜瓒呴檺鏂囦欢鐨勫幓鍚?

| 鍘熸枃浠讹紙琛屾暟锛?| 鎷嗗垎涓?|
| --- | --- |
| `cases/derive.dart` 139 | `logic/case_facts.dart`锛堟ā鍨嬶級+ `derive.dart`锛堟帹瀵?/ 妗堜緥闆嗗悎锛?|
| `core/audit/hexagram_audit.dart` 110 | `najia_audit` + `palace_audit` + `hexagram_audit`锛堝垽瀹氾級 |
| `core/pillars/pillars.dart` 120 | `pillar_tables` + `pillars`锛堢函鍑芥暟锛? `case_pillars`锛堟墿灞曪級 |
| `reports/solar_term_report.dart` 221 | `solar_term/`锛歚term_reference` + `term_resolve` + `term_fields` + `term_render` |
| `reports/boundary_report.dart` 125 | `solar_term/boundary_section.dart` + `status/gate_criteria.dart` |
| `reports/readme_header.dart` 137 | `readme/readme_header` + `readme_sources` + `readme_checklist` |
| `reports/case_report.dart` 110 | `cases/case_report`锛堢紪鎺掞級+ `case_columns_table` + `case_line_table` |
| `tools/diag/oracle_residual.dart` 113 | `diag/residual_anchors.dart` + `oracle_residual.dart` |
| `tools/selftest.dart` 344 | `tools/selftest/`锛歚suite` + `checks_astro` + `checks_pillars` + `checks_liuchong` + `checks_tables`锛堝叆鍙ｈ矾寰勪笉鍙橈級 |

### 鍒犻櫎

```text
tool/gate_a/reports/boundary_report.dart
tool/gate_a/reports/case_report.dart
tool/gate_a/reports/master_table.dart        鈫?reports/cases/master_table.dart
tool/gate_a/reports/readme_header.dart
tool/gate_a/reports/readme_instructions.dart 鈫?reports/readme/readme_instructions.dart
tool/gate_a/reports/solar_term_report.dart
```

### 楠岃瘉锛堝叏閮?PASS锛?

```text
dart files > 100 lines        = 0        锛?3 涓?Dart 鏂囦欢锛?
directories > 5 direct files  = 0        锛?5 涓洰褰曪紝MAX = 5锛?
gov_selfcheck                 PASS       锛堣鍒?0 鑷瘉 + 瑙勫垯 1/2/3锛?
independent filesystem audit  PASS       锛堢浜岀淮搴︼細PowerShell 閫愮骇鏋氫妇锛?
Gate docs SHA256              6/6 IDENTICAL锛堥粍閲戝揩鐓э級
gate_a_runner verify          PASS       锛坕mports + generate + gov + selftest + cross锛?
gate_a_runner closeout        PASS
gate_a_runner cross           24 / 24
flutter test                  259 / 259 PASS
flutter analyze lib/domain test/domain   No issues found
dart analyze tool/gate_a      No issues found锛堥『鎵嬫竻鎺?7 鏉℃敼鍔ㄥ墠鏃㈠瓨 warning锛?
lib/ test/ assets/ diff       0
```

> `dart analyze` 涓?`flutter test` 閮借 spawn 甯?stdio 鐨勫瓙杩涚▼
> 锛坅nalysis_server / frontend_server锛夈€傚湪鍙楅檺鏂囦欢娌欑涓嬭繖绫?spawn 琚洿鎺ユ嫆缁?
> 锛坄CreateFile failed 5`锛夛紝`flutter test` 鏇翠細**闆惰緭鍑哄湴闈欓粯涓嶅姩** 鈥斺€?
> 鍐嶉亣鍒版椂鍏堢‘璁ゆ矙绠辨ā寮忥紝涓嶈璇垽鎴愩€岀紪璇戞參銆嶃€?

> 娉細`tool/gate_a` 鏍圭洰褰曟槸銆? 涓枃浠?+ 7 涓瓙鐩綍銆嶃€傝鍒?2 鐨勫喕缁撳彛寰勪负
> **鐩存帴鏂囦欢 鈮?5**锛涘瓙鐩綍**涓?*璁″叆鐖剁洰褰曢绠?鈥斺€?鍚﹀垯 7 涓涔夋ā鍧楃洰褰?
> 姘歌繙鏃犳硶婊¤冻锛屼笖涓庛€岀姝负鍑戞暟纭悎骞惰亴璐ｃ€嶈嚜鐩哥煕鐩俱€?

---

## Gate A 鏀跺彛 鈥?GATE-A-FINAL-CLOSEOUT锛?026-09-12锛屾湭鍙戝竷锛?

> 鏈疆涓嶅紑鍙戝姛鑳斤紝鍙仛浜嬪疄鏀跺彛銆備骇鍝佷唬鐮?diff = 0銆佸巻娉曟暟鎹?diff = 0銆?

### Gate 瀹氫箟姝ｅ紡鎷嗗垎

```text
Gate A-Truth   CORE DIVINATION TRUTH                鈥斺€?R3 鐨?blocker
Gate A-Compat  PROFESSIONAL SOFTWARE COMPATIBILITY  鈥斺€?涓嶉樆濉?R3
```

**鐞嗙敱**锛氬師 Gate A 鎶娿€屾煇涓撲笟杞欢浜哄伐濉啓缁撴灉銆嶈涓哄敮涓€鐪熷€兼潵婧愶紝
鎶婁竴浠舵湰璐ㄤ笂鏄€屽吋瀹规€ц瀵熴€嶇殑浜嬪彉鎴愪簡 R3 blocker銆?
鏍稿績鐪熷€兼敼鐢卞彲澶嶆牳鐨勭嫭绔嬭瘉鎹壙鎷咃紙鐙珛瑙勫垯鏍搁獙 + 瀹樻柟鍘嗘硶鍙屾簮 +
绉掔骇鐪熷€?+ 杈圭晫 Golden Test + 259/259 鑷姩娴嬭瘯锛夛紱
涓撲笟杞欢涔嬮棿鐨勬祦娲惧樊寮傦紙23:00 / 00:00 鏃ョ晫銆佹櫄瀛愭椂 / 鏃╁瓙鏃躲€佸叾浠栭厤缃級
璁颁负**鍏煎鎬?/ 閰嶇疆宸紓**锛屼笉鑷姩瑙嗕负鏍稿績绠楁硶閿欒銆?

### 鏂板
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `tool/gate_a/gate_a_gate_status.dart` | 鍙?Gate 瀹氫箟 + Gate A-Truth 閫愰」琛?+ R3 鏈€缁堢姸鎬佸潡锛堝崟涓€鐪熸簮锛?|

### 淇敼
- `tool/gate_a/gate_a_main.dart`锛歊EADME 澶存敼鍙?Gate 缁撴瀯锛?
  鎬昏〃鎷嗗嚭 `Truth Result` / `Compatibility Result` 涓ゅ垪锛?
  浣跨敤璇存槑鏀逛负 Gate A-Compat 涓撶敤锛涙竻鐞嗘畫鐣欐棫鏍囬
- `tool/gate_a/gate_a_cross_source.dart`锛氭敞閲婂綊灞炴敼涓?Gate A-Truth
- `tool/gate_a/gate_a_solar_term_report.dart`锛氭敞閲婃敼涓?PARTIALLY SECOND-LEVEL VERIFIED
- `gate-a/*.md`锛氬叏閮ㄩ噸鏂扮敓鎴愶紙鏀?generator 鐪熸簮锛岄潪鎵嬫敼浜х墿锛?

### 鏈€缁堢姸鎬?
```text
R3-A                        PASS
R3-B                        PASS
R3-B-DATA-PRECISION-FIX     PASS
GATE A-TRUTH                PASS
GATE A-COMPAT               NOT EXECUTED / DEFERRED 鈥?NON-BLOCKING
R3                          FINAL ACCEPTED
```

### 鏃ョ晫
```text
DAY BOUNDARY ENGINE      PASS
PRODUCT DEFAULT POLICY   OPEN锛堜笉闃诲 R3 Domain Foundation锛?
```

### 鏈仛
R4 鏈繘鍏ワ紱涓撲笟杞欢浜哄伐瀵圭収鏈墽琛岋紙Gate A-Compat锛屼笉闃诲锛夈€?

---

## 鑺傛皵鏁版嵁绮惧害涓撻」淇 鈥?R3-B-DATA-PRECISION-FIX锛?026-09-12锛屾湭鍙戝竷锛?

> **鏍瑰洜**锛氬垎閽熺骇瀹樻柟鏄剧ず鍊艰淇濆瓨涓?`:00` 绉?Instant锛岃€岃鍒嗛挓鍐呭瓨鍦?
> 鍙獙璇佺殑鐪熷疄绉掔骇浜よ妭鏃跺埢 鈥斺€?**鍒嗛挓绾ф暟鎹笉瓒充互琛ㄨ揪璇ョ绾ц竟鐣?*銆?
> 涓嶆槸銆孒KO 閿欎簡銆嶏細瀹樻柟鍙屾簮 HKO / NAOJ 24 / 24 鍒嗛挓绾т竴鑷淬€?

### 濂戠害鍙樻洿锛氭暟鎹寘鏀寔**娣峰悎绮惧害**锛坰chemaVersion 2锛屽悜鍚庡吋瀹?v1锛?
- `TermPrecision`锛歚minute`锛堢己鐪侊級/ `second`锛?
- 鍐荤粨璇箟锛歚minute` 鏃?`instantUtc` 绉掍綅鎭掍负 `:00`锛?
  鍙〃绀恒€?*璇ュ垎閽熷唴**浜よ妭銆嶏紝**涓?*琛ㄧず銆屾伆鍦ㄧ 0 绉掍氦鑺傘€嶏紱
- 閫愯妭姘斿彲閫?`sourceOverride`锛坄name` + `reference`锛夛紝涓嶈鐩栨椂娌跨敤骞村害 `source`锛?
- 鏈煡 `precision`銆佹畫缂?`sourceOverride` 涓€寰嬫嫆缁濆鍏ャ€?
- 鍘熷垯锛?*鏁版嵁鍖呭彲浠ユ贩鍚堢簿搴︼紝浣嗘瘡鏉℃暟鎹繀椤昏娓呯簿搴︿笌鏉ユ簮**銆?
  浠ュ悗閫愬勾琛ユ洿楂樼簿搴﹁妭姘斿彧闇€鏇挎崲瀵瑰簲 term锛屼笉蹇呮帹缈诲勾搴﹀寘銆?

### 鏁版嵁鍙樻洿锛堜弗鏍兼渶灏忥級
- `assets/calendar/2026.calendar.json`锛歚schemaVersion 1鈫?`銆乣revision 1鈫?`锛?
  绔嬫槬 `2026-02-03T20:02:00Z` 鈫?`2026-02-03T20:02:08Z`锛?
  闄?`precision: second` 涓庢潵婧愯鐩栵紙涓浗绉戝闄㈢传閲戝北澶╂枃鍙扮鏅儴锛夈€?
- 鍏朵綑 23 鏉¤妭姘斻€佸叾浣?9 涓勾浠藉寘锛?*鏈敼鍔?*銆?
  鏈彇寰楀彲淇＄绾х湡鍊肩殑鑺傛皵涓嶈ˉ绉掋€佷笉鎻掑€笺€佷笉浼扮畻銆?

### 鏂板
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `lib/domain/calendar/import/calendar_data_pack_term_source.dart` | 閫愯妭姘旀潵婧愯鐩栨牎楠?|
| `test/domain/calendar/solar_term_second_boundary_test.dart` | 绔嬫槬绉掔骇杈圭晫 Golden Test |
| `test/domain/calendar/calendar_terms_precision_test.dart` | 绮惧害 / 鏉ユ簮鍏冩暟鎹牎楠?|
| `test/domain/calendar/solar_term_precision_revision_test.dart` | 绮惧害淇瀵煎叆鍥炲綊 |
| `tool/gate_a/gate_a_precision_closeout.dart` | 楠屾敹鏂█锛堣蛋鐪熷疄浜у搧閾捐矾锛?|
| `tool/gate_a/gate_a_hko_source.dart` | HKO 瀹樻柟 XML 瑙ｆ瀽锛堜氦鍙夋牳楠岀敤鍘熷鍙戝竷浠讹級 |
| `tool/gate_a/hko/24SolarTerms_2026.xml` | HKO 瀹樻柟 XML 澶瑰叿锛堢绾垮彲閲嶅锛?|

### 淇敼
- `solar_term/solar_term.dart`锛氬鍔?`precision` / `sourceName` / `sourceReference`
- `import/calendar_data_pack.dart`锛氬鍔?`TermPrecision` 涓庨€愯妭姘斿彲閫夊瓧娈?
- `import/calendar_data_pack_parser.dart`锛氳В鏋?`precision` / `sourceOverride`
- `import/calendar_data_pack_terms.dart`锛氱簿搴︽牎楠?
- `import/calendar_data_pack_validator.dart`锛氭敮鎸?`schemaVersion 1..2`
- `test/domain/calendar/calendar_engine_test.dart`锛氬師鏂█銆?4:02:00 鍗冲瘏鏈堛€?
  宸查殢鏁版嵁淇鏇存柊锛堣鏂█鍘熸湰鎶婄己闄烽攣鎴愪簡銆屾纭涓恒€嶏級

### NOT changed锛堝喕缁撹寖鍥?diff = 0锛?
`MonthBranchResolver` / `CalendarEngine` / `GanzhiDay` / `XunKong` /
`CastingEngine` / 鍏 / 绾崇敳 / 鍏翰 / 涓栧簲 / 鍏 / UI锛?
鑷缓 Meeus 灏哄瓙淇濇寔 `DIAGNOSTIC ONLY / REJECTED AS GATE ORACLE`銆?

### 楠屾敹鏂█
```text
04:01:00 鈫?涓?  04:02:00 鈫?涓戯紙淇鐐癸級   04:02:07 鈫?涓?
04:02:08 鈫?瀵咃紙浜よ妭鐬棿锛屽惈锛?  04:02:09 鈫?瀵?  04:03:00 鈫?瀵?
```

### 楠岃瘉
`flutter test` 259 / 259锛泂coped analyze 0 issue锛?
鍏ㄤ粨 analyze 27 = 鍩虹嚎锛坣ew 0 / removed 0锛夈€?

---

## Gate A 涓撲笟鎺掔洏浜哄伐瀵圭収楠屾敹 鈥?GUAYAN-2.0-GATE-A锛?026-09-11锛屾湭鍙戝竷锛?

> 鏈疆**涓嶅啓浜у搧鍔熻兘**锛屽彧鍋?R3-A + R3-B 鐨勪笟鍔＄湡鍊奸獙鏀讹細
> 鎶娿€岃捣鍗︽椂闂?+ 鍗﹁薄杈撳叆銆嶄氦缁欎笓涓氭帓鐩樿蒋浠堕€愰」瀵圭収锛?
> 纭鏈堝缓 / 鏃ヨ景 / 鏃┖ / 鍏 / 鏈崷 / 鍙樺崷 / 绾崇敳 / 浜旇 / 鍏翰 / 涓栧簲
> 涓庝笓涓氳蒋浠朵竴鑷淬€?*浜哄伐瀵圭収鏄敮涓€鐪熷€兼潵婧愶紝Agent 涓嶅仛鑷姩鍒ゅ畾銆?*

### 鏂板锛坱ool/gate_a/ 鈥?楠屾敹妗堜緥鐢熸垚鍣紝涓嶅弬涓?App 杩愯鏃讹級
- `gate_a_main.dart` 鈥?鍏ュ彛锛氳杞界湡瀹炴暟鎹寘 鈫?缁撴瀯鑷 鈫?鐢熸垚 6 浠介獙鏀惰〃鍗?
- `gate_a_context.dart` 鈥?涓庝骇鍝佸畬鍏ㄥ悓璺緞鐨勫紩鎿庤閰嶏紙JSON鈫掓牎楠屸啋瀵煎叆鈫掍粨鍌ㄢ啋Provider鈫扙ngine锛?
- `gate_a_cases.dart` 鈥?妗堜緥鐭╅樀锛氭櫘閫?13 渚?/ 缁忓吀 6 渚?/ 鑺傛皵 12 鑺傚叏閲?/ 鏃ョ晫 3 鏃?
- `gate_a_hexagram_facts.dart` 鈥?鍗︿緥浜嬪疄璁＄畻 + **妗堜緥閿佸畾**锛堟湰鍗?鍙樺崷涓庡０鏄庝笉绗﹀嵆鎶ラ敊锛?
- `gate_a_case_report.dart` 鈥?鍗︿緥瀵圭収琛ㄦ覆鏌擄紙閫愮埢瀵圭収 + 涓撲笟杞欢濉啓浣嶏級
- `gate_a_solar_term_report.dart` 鈥?鑺傛皵**宸紓绐楀彛**娴嬮噺涓庢帰娴嬬煩闃碉紙绐楀彛璧风偣 卤1s锛?
- `gate_a_day_report.dart` 鈥?鏃ョ晫璺ㄥ瓙鏃惰繛缁椂闂磋酱 脳 涓ょ瑙勫垯
- `gate_a_hexagram_audit.dart` 鈥?鍏琛ㄥ畬鏁存€?/ 绾崇敳缁勮椤哄簭 鐙珛澶嶆牳
- `gate_a_pillars.dart` 鈥?鍥涙煴鏃佽瘉锛堝勾鏌变互绔嬫槬鎹㈠勾 / 浜旇檸閬?/ 浜旈紶閬侊級
- `gate_a_sun_longitude.dart` 鈥?鑷缓澶╂枃灏哄瓙锛圡eeus 澶槼瑙嗛粍缁忥級鈫?**宸茶瘉浼紝闄嶄负 diagnostic**
- `gate_a_naoj_source.dart` 鈥?NAOJ銆屾殾瑕侀爡銆峉hift_JIS 瀛楄妭绾цВ鏋愶紙**瀹樻柟绗簩鐪熷€兼簮**锛?
- `gate_a_cross_source.dart` 鈥?HKO vs NAOJ 鍙屾簮浜ゅ弶鏍搁獙锛?4 椤归€愭潯锛?
- `gate_a_oracle_residual.dart` 鈥?鑷缓灏哄瓙鐨?*鏃堕棿娈嬪樊**璇勪及锛堝瀹樻柟鍙戝竷鏃跺埢锛?
- `gate_a_diag_rate.dart` / `gate_a_diag_sun.dart` 鈥?灏哄瓙鏍瑰洜瀹氫綅锛堝彉鐜?+ 涓棿閲忥級
- `gate_a_solve.dart` 鈥?鍗﹀悕 鈫?浣嶄覆 鈫?鍔ㄧ埢浣嶏紙闃叉墜鍐欎綅涓插嚭閿欙級
- `gate_a_format.dart` / `gate_a_selftest.dart` / `gate_a_enumerate.dart`
- `naoj/rekiyou262.2026.html` 鈥?NAOJ 2026 椤甸潰瀛楄妭澶瑰叿锛堢绾垮彲閲嶅锛?
- `gate_a_runner.ps1` 鈥?鏈満 PATH 鍖呰锛?*绾?ASCII**锛歅owerShell 5.1 瀵规棤 BOM 鐨?.ps1 鎸?ANSI 瑙ｆ瀽锛?
  涓枃娉ㄩ噴浼氬彉鎴愯娉曢敊璇紱涓枃鏂囨。涓€寰嬫斁鍦?Dart 婧愰噷锛?

### GATE-A-PREP-FIX1锛堝悓鏃ヨˉ姝ｏ紝浠呮敼楠屾敹鐭╅樀锛屾湭鍔ㄤ骇鍝佷唬鐮侊級
- 鍘?GA-3 鐢?`-1min / -30s` 浣溿€屽垎閽熺簿搴︽槸鍚﹁冻澶熴€嶇殑鍒ゆ嵁 鈥斺€?**璇ュ垽鎹棤鏁?*锛?
  瀹冮殣鍚亣璁俱€屾暟鎹寘鍒嗛挓鍊?= 鐪熷疄浜よ妭鍥涜垗浜斿叆鍒板垎閽燂紙璇樊 鈮?30 绉掞級銆嶏紝
  鑰屽綋鏃剁敤鑷缓澶╂枃灏烘祴寰楀崄浜屻€岃妭銆嶅樊寮傜獥鍙?16s 锝?729s銆?
- 鏀逛负鍦ㄣ€屽樊寮傜獥鍙ｈ捣鐐广€嶆斁娴嬭瘯鐐广€?
- 鈿狅笍 **璇ヨ疆缁撹宸茶 FIX2 鎺ㄧ炕**锛堣涓嬶級锛氬樊寮傜獥鍙ｆ湰韬槸鏈獙璇佸昂瀛愮殑浜х墿銆?

### GATE-A-PREP-FIX2锛堝悓鏃ヤ簩娆¤ˉ姝ｏ紝浠呮敼楠屾敹宸ュ叿涓庢枃妗ｏ紝鏈姩浜у搧浠ｇ爜锛?
- **鎾ゅ洖 FIX1 鐨勭粨璁?*锛氳嚜寤哄昂瀛?`gate_a_sun_longitude.dart` 琚瘉浼紝涓嶅緱浣?Gate 鐪熷€笺€?
  - 璇佹嵁锛氬瀹樻柟鍙戝竷鏃跺埢鐨勬椂闂存畫宸渶澶х害 **729 绉?*锛堢珛澶忥級锛?
    瀵?2026 绔嬫槬绉掔骇鍏紑鍊兼畫宸害 **鈭?43 绉?*銆?
  - 鏍瑰洜锛堝凡瀹氫綅锛夛細瑙嗛粍缁?*鏃ュ彉鐜囨纭?*锛?.0187 vs 瀹樻柟 1.0187 掳/鏃ワ級锛?
    浣嗗湪瀹樻柟浜よ妭鐬棿鏈昂瀛愬凡瓒婅繃鐩爣瑙?9锝?0 瑙掔锛屼笖鍋忓樊闅忓鑺傚彉鍖栵紙涓庝腑蹇冨樊 C 鍚岀浉锛?
    鈥斺€?灞?*缁濆椤瑰亸宸?*锛涖€屾眰鏍瑰弽浠?= 0.000000掳銆嶇殑鑷唇鎬т笉鑳借瘉鏄庣粷瀵规纭€?
  - 澶勭疆锛歚REJECTED AS GATE ORACLE`锛岄檷涓?diagnostic tool锛屼笉鐢ㄤ簬寤虹獥銆佷笉浣滅湡鍊笺€?
  - 鏃ц嚜妫€ `<0.01掳` 闄嶇骇涓?coarse sanity check锛?.01掳 鈮?14.6 鍒嗛挓鏃堕棿锛?
    閫氳繃瀹冧笉瓒充互璇佹槑鍒嗛挓绾?绉掔骇绮惧害锛夈€?
- **鏂板瀹樻柟鍙屾簮鐪熷€?*锛欻KO锛圚KT锛塿s NAOJ銆屾殾瑕侀爡銆嶏紙JST鈫扝KT 鍑?1 灏忔椂锛夛紝
  2026 骞?**24 / 24 鏃ユ湡涓€鑷淬€佸垎閽熶竴鑷?* 鈫?瀹樻柟鍒嗛挓绾х湡鍊兼垚绔嬨€?
- **GA-3 閲嶅缓**锛氭祴璇曠偣鍙互瀹樻柟鍙戝竷鍊间负鍑?鈥斺€?
  鍏ㄩ儴鍗佷簩銆岃妭銆嶇粰 `杈圭晫 鈭?min / 杈圭晫 / 杈圭晫 +1min`锛?
  鏈夊彲杩芥函绉掔骇鍏紑鍊艰€咃紙褰撳墠浠呯珛鏄?2026锛氱传閲戝北澶╂枃鍙扮鏅儴 04:02:08 +08:00锛?
  杩藉姞 `exact 鈭?s / exact / exact +1s`銆?
  **宸插垹闄?*鎵€鏈夌敱鏈獙璇佸昂瀛愭帹瀵肩殑宸紓绐楀彛娴嬭瘯鐐广€?
  鏉ユ簮鏃犳硶纭鐨?`04:01:51` 涓嶄簣鏀跺綍銆?
- **Gate A2 鐘舵€?*锛氬綋鏃朵负 `UNRESOLVED 鈥?ASTRONOMICAL ORACLE NOT YET VALIDATED`锛?
  鏃笉 PASS 涔熶笉 FAIL 鏁版嵁婧愩€佷笉寰楁嵁姝ゅ崌绾?CalendarDataPack銆?
  > 鈿狅笍 **璇ョ姸鎬佸凡琚悓鏃ュ悗缁殑 R3-B-DATA-PRECISION-FIX 鍙栦唬**锛?
  > 绔嬫槬鍙栧緱鍙俊绉掔骇鐪熷€煎苟鍐欏叆鏁版嵁鍖咃紝Gate A2 鐜颁负 `PARTIALLY VERIFIED`銆?
  > 鏈妭淇濈暀涓哄巻鍙叉暀璁紙涓嶅緱鍒犻櫎锛夈€?

### 鏂板锛坓ate-a/ 鈥?鐢熸垚鐨勯獙鏀惰〃鍗曪紝寰呯敤鎴峰洖濉級
- `README.md` / `01-normal-cases.md` / `02-classic-cases.md` /
  `03-solar-term-boundaries.md` / `04-day-boundary.md` / `05-master-table.md`

### 缁撴瀯涓庣湡鍊艰嚜妫€缁撹
- 鍏琛細64 缁勫悎涓€涓€瀵瑰簲銆佹瘡瀹?8 鍗︺€佷笘搴旂浉闅斾笁浣?鈫?PASS锛?
- 妗堜緥閿佸畾锛?9 渚嬫湰鍗?鍙樺崷涓庡０鏄庝竴鑷淬€佺撼鐢茬粍瑁呴『搴忔纭?鈫?PASS锛?
- 瀹樻柟鍙屾簮锛欻KO vs NAOJ 2026 骞?24 / 24 鏃ユ湡涓€鑷淬€佸垎閽熶竴鑷?鈫?PASS锛?
- 鏃ユ煴閿氱偣 1949-10-01 = 鐢插瓙锛堝閮ㄩ粍鍘嗘簮鏍革級锛?026-02-04 = 宸遍厜锛堣法 76 骞寸嫭绔嬫簮鏍革級锛?
- 鑷宸叉崟鑾峰苟淇鐨勯敊璇細鍔ㄧ埢涓嬫爣 0/1 鍩烘贩鐢ㄣ€佽妭姘旇鍙栫浉閭诲勾浠姐€?
  鍏啿/鍏悎 鎵嬫劅鍒嗙被锛堟按鍦版瘮涓庡湴椋庡崌鍧囬潪鍏啿锛夈€佸叚鐖讳綅涓插啓閿?6 澶勩€佹墜绠楁棩鏌?3 澶勩€?
  鑷缓灏哄瓙 JD鈫擴nix 绾厓澶氬姞 0.5 澶╋紙鍏ㄤ綋鍋忕Щ 12 灏忔椂锛変笌绔犲姩缂洪」銆?

### 鏈仛
浜у搧浠ｇ爜鏈敼鍔紙`lib/`銆乣test/` diff = 0锛夛紱Gate A 鏈?PASS锛?
鏃ョ晫榛樿鍊兼湭鍐荤粨锛?*鑺傛皵鏁版嵁婧愪笉鍗囩骇**锛圙ate A2 鏈畾璁猴級銆?

---

## 绂荤嚎鍘嗘硶鍩虹灞?鈥?GUAYAN-2.0-R3-B-CALENDAR锛?026-09-11锛屾湭鍙戝竷锛?

> **璺嚎鍙樻洿**锛氫笉鍐嶆妸 1900鈥?100 鐨?4824 鏉¤妭姘旂‖缂栫爜杩涙簮鐮侊紝
> 鏀逛负 **骞村害鏁版嵁鍖?+ 鏈湴浠撳偍 + 瀹屽叏绂荤嚎璁＄畻**銆?
> 宸插鍏ュ勾浠界绾挎帓鐩橈紱鏈鍏ュ勾浠?*鏄庣‘鎷掔粷**锛岀粷涓嶈繎浼艰ˉ绠椼€?
> 绾?Dart锛岄浂 Flutter / 闆惰繍琛屾椂缃戠粶 / 闆跺ぉ鏂囧簱 / 闆惰繎浼?fallback銆?

### 鏂板锛坙ib/domain/calendar/锛?
- 鏍癸細`calendar_engine.dart`锛堣仛鍚堬級/ `calendar_request.dart` / `calendar_context.dart` /
  `calendar_error.dart`锛堢被鍨嬪寲澶辫触锛? `day_boundary_rule.dart`锛堜袱绉嶈鍒欙紝鏃犻粯璁ゅ€硷級
- `day/`锛歚ganzhi_day.dart`锛圝DN 鈫?鍏崄鐢插瓙锛? `xun_kong.dart`锛堟棳绌虹敱鏃鎺ㄥ锛?
- `solar_term/`锛歚solar_term_id.dart` / `solar_term.dart` / `solar_term_provider.dart` /
  `calendar_year_data.dart` / `month_branch_resolver.dart`锛堝崄浜屻€岃妭銆嶅垏鏈堝缓锛?
- `import/`锛歚calendar_data_pack.dart` / `calendar_data_pack_parser.dart` /
  `calendar_data_pack_terms.dart` / `calendar_data_pack_validator.dart` /
  `calendar_data_pack_importer.dart`锛堣В鏋愨啋鏍￠獙鈫掍慨璁⑩啋**鍘熷瓙鎻愪氦**锛?
- `store/`锛歚calendar_data_store.dart`锛堜粨鍌ㄨ竟鐣?+ 鍐呭瓨瀹炵幇锛?
  `stored_solar_term_provider.dart`锛堜粨鍌ㄢ啋Provider锛岃杞藉揩鐓у悗寮曟搸淇濇寔鍚屾锛?

### 鏂板锛堟暟鎹笌宸ュ叿锛?
- `assets/calendar/2019..2028.calendar.json` 鈥?绉嶅瓙鏁版嵁鍖?10 骞达紝
  涓庣敤鎴峰鍏?*鍚屼竴绉嶆牸寮?*锛堜笉瀛樺湪銆屽唴缃蛋 Dart 甯搁噺銆嶇殑绗簩濂椾綋绯伙級
- `tool/calendar_pack_gen/generate_calendar_packs.dart` 鈥?寮€鍙戦樁娈电敓鎴愬櫒锛?
  **涓嶅弬涓?App 杩愯鏃?*锛涙潈濞佹簮缂撳瓨 `.cache/` 宸?gitignore

### 鏁版嵁鏉ユ簮锛堝彲澶嶆牳锛?
- 棣欐腐澶╂枃鍙?HKO銆屼簩鍗佸洓绡€姘ｇ殑鏃ユ湡鍙婃檪闁撹硣鏂欍€嶏紱HKO 娉ㄦ槑鍏跺ぉ鏂囨暟鎹潵鑷?
  鑻卞浗 HM Nautical Almanac Office 涓庣編鍥?United States Naval Observatory锛?
- 鍘熷鍩哄噯 HKT锛圲TC+8锛夆啋 缁熶竴鎶樼畻 UTC锛?
- **鏉ユ簮涓哄垎閽熺骇锛岀浣嶆亽涓?`:00`**锛堝瀹炶褰曪紝涓嶈櫄鏋勭绾х簿搴︼級锛?
- 瑕嗙洊 2019鈥?028锛圚KO 鍏紑鑼冨洿锛夛紱涓?NAOJ 鍦ㄩ噸鍙犲勾浠介€愰」涓€鑷淬€?

### 鍏抽敭濂戠害
- 鏈堝缓杈圭晫锛歚instant < 浜よ妭 鈫?鏃ф湀寤篳锛宍instant >= 浜よ妭 鈫?鏂版湀寤篳锛堜笁鎬佹柇瑷€锛夛紱
- 缂哄勾浠芥姏 `CalendarDataMissing`锛涘鍏ュ師瀛愭€э紙鏍￠獙閫氳繃鍓嶄笉鍐欎粨鍌級锛?
- 淇鍥涙€?NEW / UPDATE / SAME / DOWNGRADE锛岄檷绾ф嫆缁濅笖鏃ф暟鎹笉鍙橈紱
- 鏃ョ晫锛氫粨搴撴棦鏈変唬鐮佹湭鍐荤粨瑙勫垯 鈫?鏍稿績灞傚疄鐜颁袱绉嶅苟瑕佹眰鏄惧紡浼犲叆銆?

### 娴嬭瘯锛?103锛屽叡 232/232 閫氳繃锛沘nalyze 0 issue锛?
`test/domain/calendar/`锛歡anzhi_day / xun_kong / day_boundary /
month_branch_resolver / calendar_data_pack_parser / calendar_data_pack_validator /
calendar_pack_import / calendar_engine / offline_gate锛? 澶瑰叿 fixtures锛?

### 鏈仛
鍘嗘硶绠＄悊 UI銆佸鍏ユ寜閽€佹枃浠堕€夋嫨鍣ㄣ€佽鐩栫‘璁ゅ脊绐楋紱瀹屾暣澶╂枃绠楁硶锛?
鏃鸿“ / 鏈堢牬 / 鏃ュ啿 / 绁炵厼 / 鍥涙煴瀹屾暣绯荤粺銆?

---

## 鎺掔洏寮曟搸 R3 鍗︿綋灞?鈥?GUAYAN-2.0-R3-ENGINE-A锛?026-09-11锛屾湭鍙戝竷锛?

> **鎺掔洏浠庢紨绀烘。妗堝彉鎴愮湡瀹炶绠椼€?* 绾?Dart 棰嗗煙灞傦紝闆?Flutter 渚濊禆锛?
> Widget 涓€寰嬩笉寰楄嚜琛屾帓鍗︼紙鎬昏鍒?搂10锛夈€傛湰杞鐩?R3 娓呭崟 12 椤逛腑鐨?9 椤广€?

### 鏂板锛坙ib/domain/ 鈥?鍩虹鍧愭爣锛?
- `wu_xing.dart` 鈥?浜旇 + 鐢熷厠锛沗relationTo(self)` 鏄叚浜插垽瀹氬敮涓€鍏ュ彛
- `di_zhi.dart` 鈥?鍗佷簩鍦版敮锛氫簲琛?/ 闃撮槼 / 鍏啿 / 鍏悎
- `tian_gan.dart` 鈥?鍗佸ぉ骞诧細浜旇 / 闃撮槼 / 鍏崄鐢插瓙鍙栧共

### 鏂板锛坙ib/domain/casting/ 鈥?鎺掔洏寮曟搸锛?
- `bagua.dart` 鈥?鍏崷锛堜笁鐖昏嚜涓嬭€屼笂锛? 鍗︾ + 浜旇 + 鍏堝ぉ搴?
- `najia.dart` 鈥?绾崇敳琛紙骞叉敮锛夛細涔剧撼鐢插，銆佸潳绾充箼鐧革紱鍐呭鍗﹀垎鍒鍗?
- `palace.dart` 鈥?浜埧鍏鍗﹀簭 + 涓栧簲锛堢畻娉曠敓鎴愶紝闈炵‖缂栫爜 64 鏉★級
- `hexagram_names.dart` 鈥?鍏崄鍥涘崷鍚嶈〃锛堜笂鍗?脳 涓嬪崷锛?
- `hexagram64.dart` 鈥?鍏埢闃撮槼 鈫?鍗﹀悕 / 瀹綅 / 涓栧簲
- `six_relative.dart` 鈥?鍏翰锛堜互瀹綅浜旇涓恒€屾垜銆嶏級
- `six_spirit.dart` 鈥?鍏锛堟寜鏃ュ共璧蜂緥锛岃嚜鍒濈埢鍚戜笂椤烘帓锛?
- `cast_chart.dart` 鈥?鎺掔洏缁撴灉妯″瀷锛圕astLine / CastChart锛?
- `casting_engine.dart` 鈥?寮曟搸缁勮锛氭湰鍗?/ 鍙樺崷 / 鍔ㄥ彉 / 绾崇敳 / 涓栧簲 / 鍏翰 / 鍏

### 鍏抽敭濂戠害
- 涓栧簲鐢便€屾湰瀹崷閫愮埢缈昏浆 鈫?娓搁瓊鍥炵炕鍥涚埢 鈫?褰掗瓊杩樺師鍐呭崷銆嶆帹瀵硷紝
  涓栫埢搴忓垪鎭掍负 6/1/2/3/4/5/4/3锛屼笉缁存姢 64 鏉＄‖缂栫爜琛紱
- **鍙樺崷鍏翰浠嶅彇鏈崷涔嬪**涓恒€屾垜銆嶏紙浼犵粺鍥哄畾瑙勫垯锛夛紱
- 闈欏崷涓嶇敓鎴愬彉鍗︼紱鏃犳棩骞叉椂鍏涓?null锛涢潪娉曡緭鍏ユ姏寮傚父銆?

### 娴嬭瘯锛?23锛屽叡 129/129 閫氳繃锛沘nalyze 0 issue锛?
- `test/domain/casting/hexagram_tables_test.dart` 鈥?琛ㄥ畬鏁存€т笌瑙勫垯娴嬭瘯
- `test/domain/casting/casting_engine_test.dart` 鈥?缁忓吀鎺掔洏瀵圭収
  锛堜咕涓哄ぉ / 鍧や负鍦?/ 娉藉北鍜?鍏ㄧ埢绾崇敳路鍏翰路涓栧簲锛?

### 鏈仛锛圧3-B锛?
- 鍥涙煴 / 鏈堝缓 / 鏃ヨ景 / 鏃┖锛堥渶骞叉敮鍘嗘硶 + 鑺傛皵鎺ㄧ畻锛夛紱
- 寮曟搸鎺ュ叆瀹″崷椤碉紝鏇挎崲 `ReviewTraditionalProfile` 鍗犱綅瀛楁銆?

---

## 鍩虹嚎鏀跺彛 鈥?GUAYAN-2.0-R5-BASELINE-CLOSEOUT锛?026-09-10锛屾湭鍙戝竷锛?

> 鏀跺彛 `3c00187` 閬楃暀鍩虹嚎锛氭帓鍗?lines 椤哄簭 Bug 鐙珛钀藉簱锛坄7266332`锛夛紱
> 瀹″崷 4 涓孩娴嬮€愰」濂戠害瀹¤锛? 椤?TEST STALE銆? 椤规贩鍚堬級锛屾仮澶嶅叏閲忔祴璇曠豢鑹层€?

- `lib/services/draft/casting_draft.dart` 鈥?demo().lines 鏀瑰崌搴忥紝閿佹
  `index = position - 1` 濂戠害锛沗casting_page_test.dart` 琛ラ€愮埢浣嶅洖褰?
- `lib/presentation/review/widgets/review_hexagram_line_row.dart` 鈥?
  涓?鍙樺崷鏂囨湰鍒楀灏侀《锛?4/88 璁捐 px锛屽垪缂樿鍓笉鍘嬬埢妲斤級锛?
  绫绘枃妗ｅ榻愬疄闄呭熀绾?18/24/34 涓?FittedBox(contain)
- `lib/presentation/review/widgets/review_shensha_card.dart` 鈥?绫绘枃妗ｆ敼涓?
  銆屾暟鎹┍鍔ㄥ浐瀹?4 鍒楋紙鎸夊疄闄呮暟鎹覆鏌擄紝鏃犲己鍒剁┖鍗犱綅锛夈€嶏紱绉婚櫎鏈娇鐢?import
- `test/presentation/review/review_page_test.dart` 鈥?F1 鍩虹嚎锛堝叚琛屽叡浜熀绾?+
  鎭?3 鏉″熀绾垮甫锛屼笉缁戠粷瀵瑰潗鏍囷級/ F2 绁炵厼锛堟寜鏁版嵁娓叉煋鏃犲崰浣嶏級/ F3 鍩烘湰淇℃伅
  锛堝悎骞惰淇℃伅鍦ㄥ満锛? F4 瓒呴暱绾抽煶锛堢缉鏀炬棤鍏冲垪濂戠害 + 涓诲彉鍗﹀弻渚т笉鍘嬬埢妲斤級
  鍥涙祴閲嶅啓
- 楠岃瘉锛歠lutter test 106/106 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛涙棤渚濊禆娴姩銆?

---

## 瀹″崷棣栧睆 R4 路 Baseline Alignment 瀹氱 鈥?GUAYAN-2.0-REVIEW-BASELINE-R4锛?026-08-31锛屾湭鍙戝竷锛?

> 鍙姩涓や釜缁勪欢锛堝叚鐖诲崷鐩?+ 绁炵厼锛夛紝鍏朵綑宸插畾绋?UI 涓€寰嬩笉鍔ㄣ€?
> 鐩爣锛氱湡姝ｅ缓绔?琛屽熀绾?涓?鍒椾腑蹇冪嚎"锛屾秷鐏瑙夊弬宸€?

### 鍏埢鍗︾洏锛坮eview_hexagram_line_row.dart 閲嶅啓锛?
- **Primary Baseline = RowTop + 19**锛氬叚绁?/ 浼忕1 / 浼忕2 / 涓诲崷姝ｆ枃 /
  涓诲崷涓栧簲 / 鍙樺崷姝ｆ枃 / 鍙樺崷涓栧簲 鍏ㄩ儴鐢?Flutter `Baseline` 鏁板閿佸畾鍚屼竴鏉″熀绾匡紱
- **NaYin Baseline = RowTop + 35**锛氫富鍗?鍙樺崷绾抽煶鍚勮嚜灞呬腑浜庢鏂囧垪锛?
- 琛岄珮 48锛涘垪涓績鍐荤粨锛堝叚绁?2 浼忕1路62 浼忕2路100 涓诲崷姝ｆ枃174 涓诲崷鐖?22
  涓栧簲250 鍔ㄧ埢268 绠ご280 鍙樺崷姝ｆ枃318 鍙樺崷鐖?58 鍙樺崷涓栧簲388锛夛紱
- 瀛楀彿灞傜骇鎸夊畾绋匡細鍏 9.4 甯歌 / 浼忕 9 甯歌 / 涓栧簲 8.8 甯歌 /
  姝ｆ枃 10.5 鍔犵矖锛坙inePrimary #314D59锛? 绾抽煶 9 甯歌锛?
- 鏁磋 400 璁捐鍧愭爣绌洪棿 + FittedBox(scaleDown) 鑷€傚簲锛堣鍐呮棤杈规锛?
  鍒嗗壊绾跨敱琛ㄦ牸灞傜嫭绔嬬粯鍒讹紝淇濊瘉 FittedBox 鐖堕珮鎭?48銆佷笉鍋氱旱鍚戠缉鏀撅級锛?
- 鐖绘Ы 24脳6 / 鍔ㄧ埢 12脳12 / 绠ご 6 鍥哄畾锛屾枃鏈笉渚靛崰銆?

### 绁炵厼锛坮eview_shensha_card.dart锛?
- **FIXED 4脳4 Grid**锛氭牸瀹?89銆佹牸楂?18銆佸垪璺?6銆佽璺?4锛堟暟鎹┍鍔紝
  <16 椤圭暀绌哄崰浣嶄繚鎸?4脳4锛?16 鎵嶅姞绗?5 琛岋級锛涚姝㈣嚜鐢?Wrap锛?
- 瀛楀彿 9.4 / w600 / #5C7078锛涚 4 琛屾案杩滃湪 Card 鍐呫€?

### 琛ㄥご
- guaTitle 13 / guaName 10.8锛坮eview_hexagram_result_table.dart锛?

### Token
- 鏂板 `linePrimary #314D59`銆乣shenShaItem #5C7078`

### 娴嬭瘯锛?3锛?
- R4 鍩虹嚎鏁板閿佸畾锛氳鍐呭叏閮?Baseline 鈭?{19, 35}锛屼富鍩虹嚎 6 鏉?/ 绾抽煶 2 鏉★紱
- R4 绁炵厼鍥哄畾 4脳4锛?6 鏍兼棤婧㈠嚭銆佸悓鍒楀榻愩€佺 4 琛屽湪鍗″唴锛?
- R4 绁炵厼 <16 椤癸細12 绌轰綅鍗犱綅浠嶄繚鎸?4脳4銆?
- 楠岃瘉锛歠lutter test 106/106 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 瀹″崷棣栧睆 R3 鑸掗€傜揣鍑戠増 鈥?GUAYAN-2.0-REVIEW-ONSCREEN-R3锛?026-08-31锛屾湭鍙戝竷锛?

> 鐩爣锛?*鍏埢鍏蹇呴』鍦ㄥ鍗﹂灞忓畬鏁撮湶鍑?*锛堢‖闂ㄧ锛屼笉鎺ュ彈涓嬫粦鎵嶈兘鐪嬪埌鏈遍泙/鍒濈埢锛夈€?

### 鏈疆甯冨眬瑙勫垯锛圧3 鎬?SVG锛?
- **鍗﹀悕 Header 66 鈫?54 DIP**锛氫富鍗?鍙樺崷鏍囬 + 鍗﹀悕鍚勪竴琛岋紙h2 12 / gua 10锛?
- **浼忕鏀?3 瀛楃煭鏍煎紡**锛氬叚浜茬畝绉?+ 鍦版敮 + 浜旇锛坄璐㈠瘏鏈?/ 鐖舵湭鍦焋锛夛紝
  鏇挎崲琚搴﹁鍒囩殑 `璐笝鈥?/ 鐖朵竵鈥锛涙紨绀烘暟鎹?12 椤瑰叏閮ㄨ浆鎹?
- **鍏埢琛岄珮 56 鈫?48 DIP**锛氫富/鍙樺崷姝ｆ枃浠嶄袱琛屽畬鏁存樉绀猴紙鍏翰鍦版敮 10px +
  绾抽煶 8.8px锛夛紝**鏃犵渷鐣ュ彿**锛涘垪瀹介噸绠楋紙鍏 24 / 浼忕 28 / 涓栧簲 12 / 鍔ㄧ埢 12 /
  绠ご 6 / 鐖绘Ы 24锛夛紝360 DIP 涓嶆í鍚戞孩鍑?
- 绱у噾鍖栵細鍥涙煴 44鈫?0銆佺鐓?chip 24鈫?9锛坮x9.5銆佸瓧鍙?8.8锛夈€丅asicInfo 84锛坔2 12锛夈€?
  椤甸潰闂磋窛 8鈫?
- 琛ㄥ熬鏂囨锛歚鐐瑰嚮浠讳竴鐖绘煡鐪嬪叧绯汇€佽鍒欎緷鎹笌鍏崇郴澶囨敞`

### 鏂囦欢
- `review_demo_data.dart` 鈥?浼忕 3 瀛楃煭鏍煎紡锛堣储瀵呮湪/鐖舵湭鍦?瀛欏瓙姘?鍏勯厜閲戔€︼級
- `review_hexagram_line_row.dart` 鈥?琛岄珮 48銆佸垪瀹介噸绠椼€佸瓧鍙锋寜 R3 SVG
- `review_hexagram_result_table.dart` 鈥?Header 54銆佽〃灏炬枃妗?
- `review_basic_info_card.dart` / `review_four_pillars_strip.dart` /
  `review_shensha_card.dart` / `review_page.dart` 鈥?绱у噾鍖?
- `test/presentation/review/review_page_test.dart` 鈥?鏂板纭棬绂佹祴璇曪細
  430脳932 涓嬪叚鐖诲叚琛?+ 琛ㄥ熬鍦ㄥ鑸尯涔嬩笂瀹屾暣鍙锛涗紡绁炴柇瑷€鏇存柊
- 楠岃瘉锛歠lutter test 103/103 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 瀹″崷涓€灞忕増鏀跺彛 鈥?GUAYAN-2.0-REVIEW-ONSCREEN锛?026-08-31锛屾湭鍙戝竷锛?

> 鏁翠綋鏀跺彛锛氫竴灞忓厛鐪嬪畬鏁村熀鏈俊鎭?+ 绁炵厼 + 鍥涙煴 + 瀹屾暣鍗︾洏锛?
> 鐐规煇涓€鐖诲悗鍐嶅脊鍏崇郴鐒︾偣锛圔ottom Sheet锛夈€傚交搴曡В鍐?涓哄鍏崇郴鐒︾偣鎶婂崷鐩樻尋灏?銆?

### 瀹″崷椤?
- `review_page.dart` 鈥?涓€灞忓竷灞€锛欰ppBar 鈫?BasicInfo 鈫?鍥涙煴 鈫?绁炵厼 4脳4 鈫?瀹屾暣鍗︾洏锛?
  銆屽叧绯荤劍鐐广€嶄笉鍐嶅父椹伙紙鍒犻櫎 RelationFocusCard锛夛紱鐐圭埢楂樹寒 + 寮瑰眰锛?
  鏂板 `onOpenRelations` 鍥炶皟锛圓pp Shell 鍒囧埌鍏崇郴 Tab锛?
- `widgets/review_basic_info_card.dart` 鈥?绱у噾鍗曞崱锛氶棶浜?+ 鏂瑰紡 chip + 鍏巻/鍐滃巻涓ゆ爮 +
  meta锛堣鍒欏寘 v1 路 鎵嬪姩璧峰崷 路 鎺掔洏宸茬敓鎴愶級
- `widgets/review_four_pillars_strip.dart` 鈥?soft 搴?44 楂橈紝teal/warm 鍙岃壊锛屾棳绌哄彸瀵归綈
- `widgets/review_shensha_card.dart` 鈥?chip 20 楂樸€侀棿璺?4 鐨勭揣鍑?4脳4 缃戞牸
- `widgets/review_hexagram_result_table.dart` 鈥?琛ㄥご 66 楂橈紙銆愪富鍗︺€?銆愬彉鍗︺€戯級+ 琛岀偣鍑婚€忎紶 +
  琛ㄥ熬銆屽畬鏁存帓鐩?路 鐐瑰嚮浠讳竴鐖绘煡鐪嬪叧绯讳笌瑙勫垯渚濇嵁銆?
- `widgets/review_hexagram_line_row.dart` 鈥?**褰诲簳鍙栨秷鐪佺暐鍙?*锛氬叚浜插湴鏀笌绾抽煶鎷嗕笂涓嬩袱琛岋紱
  11 鍒楀浐瀹氭Ы浣嶏紝鏂囨湰涓嶄镜鍗犵埢妲?涓栧簲妲斤紱琛屽彲鐐癸紙楂樹寒锛?
- `widgets/review_line_detail_sheet.dart`锛堟柊澧烇級鈥?鐐圭埢 Bottom Sheet锛氬綋鍓嶇埢淇℃伅 +
  鍏崇郴鍒楄〃锛堟潵鑷?RelationInstance锛? 鏌ョ湅瑙勫垯渚濇嵁 + 鍏崇郴澶囨敞锛圙AP锛? 杩涘叆鍏崇郴椤?
- 鍒犻櫎 `review_relation_focus_card.dart`
- `review_page_state.dart` / `review_case_adapter.dart` 鈥?鏂板 `allRelations` +
  `relationsInvolving(position)` + `relationLabel`锛堢偣鐖诲脊灞傛寜鐖昏繃婊わ紝浠嶆潵鑷?Domain锛?
- `review_demo_data.dart` 鈥?婕旂ず鏁版嵁瀵归綈涓€灞忕増 SVG锛堥棶浜?鍏巻 09:30/鍐滃巻 涓冩湀鍗佸叓 路 宸虫椂/
  鏃┖ 鐢抽厜绌猴級

### 鎺掑崷椤?
- `line_editor_sheet.dart` 鈥?鐖昏薄閫夐」鍗″浐瀹?`mainAxisExtent: 58`锛堚墺58 DIP 纭棬绂侊級锛?
  鍐呭鍨傜洿灞呬腑锛屼换浣曞睆骞?RenderFlex 婧㈠嚭 = 0锛堜慨澶?BOTTOM OVERFLOWED 1.2px锛?

### 鍏变韩 / Token
- `casting_tokens.dart` 鈥?gua #927848銆乸illarTeal #4F8685銆佹柊澧?pillarWarm #A8605C
- `shared/yao_glyph.dart` / `shared/moving_marker.dart` 鈥?鎻忚竟瀹藉害鎸変竴灞忕増 SVG 寰皟
  锛堢┖浜?1.4 / 鈼嬅?1.6锛?

### 娴嬭瘯
- `review_page_test.dart` 鈥?涓€灞忕増閫傞厤 + 鐐圭埢寮瑰眰锛堝叧绯诲垪琛?杩涘叆鍏崇郴椤靛洖璋冿級+
  绐勫睆 360 鏃犳孩鍑猴紱UI-04~08 淇濈暀
- `casting_page_test.dart` 鈥?鏂板銆岀埢璞″脊灞傜獎灞?360脳640 鏃?RenderFlex 婧㈠嚭銆嶆祴璇?
- `foundation_test.dart` 鈥?瀹″崷鍒嗘敮鏂█鏀逛负 绁炵厼
- 楠岃瘉锛歠lutter test 102/102 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 鎺掑崷椤?+ 瀹″崷椤靛閲忎慨姝?鈥?GUAYAN-2.0-UI-CORRECTION-R2锛?026-08-30锛屾湭鍙戝竷锛?

> 鍦?R1 宸插畾绋垮熀纭€涓婂仛澧為噺淇锛岀姝㈤噸鏂拌璁°€傛湰杞喕缁擄細缁熶竴鐖绘Ы 24脳6
> 锛堥槼/闃?绌轰骸浠呭唴閮ㄥ～鍏呬笉鍚岋級銆佸姩鐖绘爣璁?12脳12銆佹枃鏈笉寰楀帇鐖汇€?

### 鏂板锛坙ib/presentation/shared/ 鈥?鎺掑崷/瀹″崷寮哄埗澶嶇敤锛?
- `yao_glyph.dart` 鈥?缁熶竴鐖绘Ы缁勪欢锛歒aoGlyph锛?4脳6锛寉ang/yin/voidYao锛? YaoKind锛?
  `YaoGlyph.fromMovement` 渚挎嵎宸ュ巶锛涚┖浜＄埢绌哄績鎻忚竟 rx1 #7E9098 w1.5
- `moving_marker.dart` 鈥?鍔ㄧ埢鏍囪缁勪欢锛歁ovingMarker锛?2脳12锛岃€侀槾 鈼?#A17F45 /
  鑰侀槼 脳 #567866锛? `MovingMarker.of` 渚挎嵎宸ュ巶

### 鎺掑崷椤典慨姝?
- `casting_page.dart` 鈥?鍒犻櫎椤堕儴 CastingDraftContext锛埪?.1锛夛紱姝ｆ枃椤哄簭锛?
  AppBar 鈫?璧峰崷鏃堕棿 鈫?闂簨淇℃伅 鈫?鍏埢褰曞叆 鈫?瑙勫垯鍖?鈫?鐢熸垚鎺掔洏
- `casting_time_row.dart` 鈥?閲嶅啓涓?88 楂樺崱鐗囷細鏍囬 + 鍙充笂銆屽凡瀹屾垚/寰呭畬鍠勩€峜hip +
  鍏巻 + 鍐滃巻锛埪? SVG锛涘啘鍘嗕负 lunarPlaceholder presentation mock锛孏AP 鏍囨敞锛?
- `casting_page_state.dart` 鈥?鏂板 `lunarPlaceholder(DateTime)`锛圙AP锛氱湡瀹炲啘鍘嗘崲绠楀緟鎺ュ叆锛?
- `six_yao_input_row.dart` 鈥?鏅€氳 = 缂栬緫琛?= 52 DIP锛埪?锛氱紪杈戞€佸彧鍙樿儗鏅?杈规/瀛楅噸/寰芥爣锛夛紱
  鐖昏薄杩佺Щ鍏变韩 YaoGlyph
- `line_editor_sheet.dart` 鈥?杩佺Щ鍏变韩 YaoGlyph + 鍔ㄧ埢琛?MovingMarker
- 鍒犻櫎 `casting_draft_context.dart`銆佹棫 `casting/widgets/yao_glyph.dart`

### 瀹″崷椤典慨姝?
- `review_page_state.dart` 鈥?ReviewLineView锛歨iddenSpirit 鎷嗕负 hiddenSpirit1/2锛堜紡绁炰袱鍒楋級锛?
  鏂板 isVoid锛堜富鍗?鍙樺崷锛孶I 琛ㄧ幇涓撶敤锛學idget 涓嶈绠楁棳绌猴級锛涚撼闊虫嫭鍙锋敼鍗婅 `(绾抽煶)`
- `review_case_adapter.dart` / `review_demo_data.dart` 鈥?浼忕涓ゅ垪 + isVoid 閫忎紶锛?
  婕旂ず鏁版嵁鎸?R2 SVG #12锛氫簲鐖讳竵閰夈€佷笁鐖讳笝鐢崇┖浜★紙鏃┖鐢抽厜锛?
- `review_shensha_card.dart` 鈥?绁炵厼鍥哄畾 4 鍒?脳 N 琛屾暟鎹┍鍔ㄧ綉鏍硷紙搂5 SVG 402脳178锛?
  >16 椤圭户缁姞琛岋級
- `review_hexagram_result_table.dart` 鈥?鏈€缁堝崷鐩樼粍浠讹紙搂6/搂12 SVG 402脳404锛夛細
  鍐呭祵銆愪富鍗︺€?銆愬彉鍗︺€戞爣棰橈紙娴呭簳 #F8FBF9锛? 鍏鎺掔洏 + 琛ㄥ熬璇存槑
- `review_hexagram_line_row.dart` 鈥?11 鍒楀喕缁擄細鍏 | 浼忕1 | 浼忕2 | 涓诲崷鏂囧瓧 |
  涓诲崷鐖绘Ы(24脳6) | 涓诲崷涓?搴?| 鍔ㄧ埢(12脳12) | 绠ご | 鍙樺崷鏂囧瓧 | 鍙樺崷鐖绘Ы | 鍙樺崷涓?搴旓紱
  鏂囧瓧鍒?Ellipsis 瑁佸壀锛岀埢妲?涓栧簲妲藉浐瀹氫笉琚镜鍗狅紙搂11 纭棬绂侊級
- `review_page.dart` 鈥?绉婚櫎 HexagramResultHeader锛堣〃鍐呭凡鍚爣棰橈紝閬垮厤閲嶅锛?
- 鍒犻櫎 `review_hexagram_result_header.dart`

### 娴嬭瘯
- `test/presentation/casting/casting_page_test.dart` 鈥?UI-01锛堟棤 DraftContext锛?
  UI-02锛堝叕鍘?鍐滃巻锛? UI-03锛堟櫘閫氳楂?=缂栬緫琛岄珮==52锛?
- `test/presentation/review/review_page_test.dart` 鈥?UI-04锛堢鐓為灞?4 鍒楋級/
  UI-05锛堢埢妲界粺涓€ 24脳6锛? UI-06锛堝姩鐖?12脳12锛? UI-07锛堣秴闀挎枃鏈笉鍘嬬埢锛?
  UI-08锛堝彉鍗︾埢妲?鍙樺崷涓栧簲鍚屾樉锛? R1 娴嬭瘯閫傞厤锛圷aoGlyph.kind銆丮ovingMarker锛?
- `test/presentation/shared/yao_glyph_test.dart`锛堟柊澧烇級鈥?鍏变韩缁勪欢灏哄鍐荤粨娴嬭瘯
- `test/foundation_test.dart` 鈥?瀹″崷鍒嗘敮鏂█鏀逛负銆愪富鍗︺€?

### 璇存槑
- 婕旂ず pos2锛堣€侀槼锛変富鍗︽寜璇箟娓叉煋闃虫Ы + X锛汼VG #12 鐢讳綔闃?X锛屽睘鏈夋剰淇
  锛堜繚鎸侀槾闃宠涔変竴鑷达紝宸叉敞閲婅褰曪級銆?
- 楠岃瘉锛歠lutter test 100/100 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 瀹″崷椤?XYUI 宸ヤ綔鍙?鈥?GUAYAN-2.0-REVIEW-UI-R1锛?026-08-30锛屾湭鍙戝竷锛?

> 鐩爣锛氭妸銆屽鍗︺€嶅崰浣嶉〉瀹炵幇涓轰汉宸ュ畾绋跨殑 XYUI 闀块〉鎺掔洏宸ヤ綔鍙般€?
> 瑙嗚浠ヤ换鍔′功鎬?SVG 涓烘渶楂樹紭鍏堢骇锛涗紶缁熸帓鐩樺瓧娈碉紙鍏/浼忕/鍏翰/绁炵厼/鍥涙煴/鍗﹀悕锛?
> 鐢辨紨绀烘。妗堟彁渚涳紝鐪熷疄璁＄畻灞炲悗缁帓鐩樺紩鎿庯紙R3锛夆€斺€?鏈疆涓嶅仛鍋囧叚鐖荤畻娉曘€?

### 鏂板锛坙ib/presentation/review/锛?
- `review_page.dart`锛堥噸鍐欏崰浣嶉〉锛夆€?瀹″崷宸ヤ綔鍙帮細SafeArea 鈫?ReviewAppBar 鈫?Expanded
  SingleChildScrollView锛圔asicInfo 鈫?ShenSha 鈫?FourPillars 鈫?HexagramHeader 鈫?
  HexagramTable 鈫?RelationFocus锛夛紱MainTabBar 鍥哄畾鍦?App Shell
- `review_page_state.dart` 鈥?绾?Dart 鐘舵€佹ā鍨嬶細ReviewPageState锛埪? 鍏ㄩ儴瀛楁锛?
  ReviewLineView / ReviewChangedLine / ReviewShenShaItem + formatSolar
- `review_case_adapter.dart` 鈥?HexagramCase + ReviewTraditionalProfile 鈫?ReviewPageState锛?
  鐒︾偣鍏崇郴涓€寰嬫潵鑷?calculateRelations锛圫table Relation Identity锛夛紝绂佹 UI 閲嶇畻
- `review_demo_data.dart` 鈥?瑙嗚瀹氱婕旂ず鏁版嵁锛圫VG 閫愰」杞綍锛氭辰灞卞捀鈫掓辰姘村洶銆?6 绁炵厼銆?
  涓欏崍骞翠笝鐢虫湀涓欏瓙鏃ヤ竵閰夋椂銆佸叚绁?浼忕/鍏翰/绾抽煶/涓栧簲銆佷袱鍔ㄧ埢锛?
- `widgets/review_app_bar.dart` 鈥?椤舵爮锛堣繑鍥?chevron + 瀹″崷 + 鎺掔洏缁撴灉锛屄?锛?
- `widgets/review_basic_info_card.dart` 鈥?鏂瑰紡/浜嬮」/闃冲巻/闃村巻 + 宸茬敓鎴?chip锛埪?锛?
- `widgets/review_shensha_card.dart` 鈥?绁炵厼鐙珛鍗＄墖 + 鑷€傚簲 Wrap 鏍囩缃戞牸锛埪?/搂8锛?
- `widgets/review_four_pillars_strip.dart` 鈥?骞?鏈?鏃?鏃?鏃┖ 妯悜绱у噾 Strip锛埪?锛?
- `widgets/review_hexagram_result_header.dart` 鈥?鎺掔洏缁撴灉 + 涓?鍙樺崷鏍囬锛埪?锛?
- `widgets/review_hexagram_result_table.dart` 鈥?鍏埢鎺掔洏涓讳綋琛紙搂6锛屼笂鐖诲湪涓婂垵鐖诲湪涓嬶級
- `widgets/review_hexagram_line_row.dart` 鈥?鍗曡锛氬叚绁?| 涓诲崷锛堝惈浼忕锛墊 鍙樺崷锛?
  鐖昏薄澶嶇敤 YaoGlyph 鐭㈤噺缁樺埗锛屼笘搴?鍔ㄧ埢绠ご鐭㈤噺
- `widgets/review_relation_focus_card.dart` 鈥?鍏崇郴鐒︾偣鍗★紙搂7锛氫笘搴?鐢熷厠/鍥炲ご鐢熷洖澶村厠
  鍏ュ彛 + 鏌ョ湅瑙勫垯渚濇嵁 鈥?璺宠浆瑙勫垯搴擄級

### 淇敼
- `lib/presentation/casting/casting_tokens.dart` 鈥?琛ュ厖 搂4 Token锛歳elationRed 绯?/
  relationBlue 绯?/ traditionalGold / pillarTeal锛坢ovingCircle 鍒悕鍒?traditionalGold锛?
- `lib/presentation/casting/casting_page.dart` 鈥?鏂板鍙€?`onGenerated` 鍥炶皟锛堢敓鎴愬悗閫氱煡 Shell锛?
- `lib/app/app_shell.dart` 鈥?瀹″崷椤靛悓鏍烽殣钘忓叏灞€ AppBar锛堣嚜甯?XYUI TopBar锛夛紱
  `_latestCase` 妗ユ帴鎺掑崷鐢熸垚缁撴灉 鈫?瀹″崷椤碉紙T12 鏁版嵁鎺ュ叆锛?
- `test/foundation_test.dart` 鈥?瀹″崷鍒嗘敮鏂█鏀逛负鏃犲叏灞€ AppBar + 瀹屾暣鎺掔洏/鍏崇郴鐒︾偣
- `test/presentation/review/review_page_test.dart`锛堟柊澧烇級鈥?搂22 Test A鈥揌 + 閫傞厤鍣ㄥ崟娴?

### 鏁版嵁鎺ュ叆锛圱12/T13锛?
- 鎺掑崷椤电敓鎴愬悗缁?`onGenerated` 鎶?HexagramCase 浜ょ粰 App Shell锛屽鍗﹂〉娓叉煋鐪熷疄鍗︿緥锛?
  鍏埢/鍦版敮/鏃堕棿/瑙勫垯鐗堟湰鏉ヨ嚜 Domain锛屽叧绯荤劍鐐圭敱 calculateRelations 璁＄畻锛?
  鍏/浼忕/鍏翰/绁炵厼/鍥涙煴/鍗﹀悕绛変紶缁熷瓧娈电湡瀹炲崷渚嬩笅鏄惧紡缃┖锛圙AP锛氭帓鐩樺紩鎿?R3锛夈€?
- 鏈敓鎴愯繃鍗︿緥鏃跺鍗﹂〉娓叉煋瑙嗚瀹氱婕旂ず鎺掔洏锛堝惈瀹屾暣浼犵粺妗ｆ锛夛紝渚涗汉宸ヨ瑙夐獙鏀躲€?

### 璇存槑
- 婕旂ず鐖诲簭涓?Domain 濂戠害涓€鑷达紙1 鍒濈埢 .. 6 涓婄埢鍗囧簭锛夛紱鍔ㄧ埢鏍囪閬靛惊 搂22 D/E 璇箟
  锛堣€侀槼=闃崇埢瀹炵嚎 + X锛夛紝涓?SVG 涓埆鐖荤嚎鐢绘硶瀛樺湪涓€澶勬湁鎰忎慨姝ｏ紙Row5锛夛紝宸茶褰曘€?
- 楠岃瘉锛歠lutter test 84/84 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛?1 鏉℃棫浠ｇ爜鍛婅鏈姩锛夛紱
  debug APK 鏋勫缓閫氳繃銆?

---

## 鍗︾溂 2.0 Foundation 鈥?feat/guayan-2.0

> 鍒嗘敮锛歚feat/guayan-2.0`锛堢户鎵?GitHub 鍘嗗彶锛?.0 App 鏋舵瀯閲嶆柊寮€鍙戯紝鏃у姛鑳芥湭鏉ユ敹缂栬繘銆岃缁冦€嶅叆鍙ｏ級

### 鏂板 2.0 楠ㄦ灦
- **鍏ュ彛鏋佺畝鍖?*锛歚lib/main.dart` 鍙仛 `runApp(const GuayanApp())`锛屼笉鍐嶈烦鏃?HomePage銆佷笉鍐嶅垵濮嬪寲鏃?MistakeStore銆?
- **`lib/app/`**锛?.0 搴旂敤澹?
  - `app.dart` 鈥?`GuayanApp`锛歁aterialApp 缁勮 + 鍏ㄥ眬涓婚锛堟祬鑹层€佺揣鍑戯級
  - `app_shell.dart` 鈥?`AppShell`锛欼ndexedStack 鐘舵€佷繚鎸?+ GuayanMainTabBar 浜斾富瀵艰埅锛圶YUI锛夛紝`selectedIndex` 鍗曚竴鏉冨▉鏉ユ簮锛岄粯璁?Index 0锛堟帓鍗︼級锛涙帓鍗﹂〉鑷甫 XYUI TopBar锛堟棤鍏ㄥ眬 AppBar锛?
  - `navigation/main_tabs.dart` 鈥?姝ｅ紡浜у搧 IA锛氭帓鍗?瀹″崷/鍏崇郴/鍗︿緥/璁粌锛堥『搴忓浐瀹氾級锛汳ainTab 鍚?title / iconBuilder / builder
  - `navigation/guayan_main_tab_bar.dart` 鈥?XYUI 鍖栧簳閮ㄥ鑸紙浠诲姟涔?搂15锛夛細娲诲姩搴曡壊 + 鐭㈤噺鍥炬爣锛圙uayanTabIcons锛? 鏍囩
  - `more_menu.dart` 鈥?銆屾洿澶氥€嶈彍鍗曪細瑙勫垯搴?/ 璁剧疆 / 鍏充簬锛堟敮鎸佽嚜瀹氫箟 icon锛屾帓鍗﹂〉鐢ㄤ笁鐐规牱寮忥級
- **`lib/core/constants/app_info.dart`**锛氬簲鐢ㄥ悕銆屽崷鐪笺€嶃€佸唴閮ㄧ増鏈€佷富棰樼瀛愯壊甯搁噺
- **`lib/domain/`锛堥鐣欙級**锛欸UAYAN-2.0-DOMAIN 闃舵鍦ㄦ寤虹珛 HexagramCase / LineState / RelationInstance / RelationNote 绛?
- **`lib/application/`锛堥鐣欙級**锛氬悗缁敤渚嬪眰锛汧oundation 闃舵浠?AppShell 鐢?StatefulWidget锛屼笉寮曞叆鐘舵€佺鐞嗘鏋?
- **`lib/presentation/`**锛氫簲涓富椤甸潰 + 瑙勫垯搴?璁剧疆/鍏充簬
  - `casting/casting_page.dart` 鈥?鎺掑崷椤碉細XYUI 鎺掑崷宸ヤ綔鍙帮紙R1 瀹氱甯冨眬锛氳捣鍗︽椂闂?鈫?闂簨淇℃伅 鈫?鍏埢褰曞叆 鈫?瑙勫垯鍖?鈫?鐢熸垚鎺掔洏锛?
  - `casting/casting_tokens.dart` 鈥?XYUI 瑙嗚 Token锛堜换鍔′功 搂3 瀹氱鍊硷紝鎺掑崷椤?+ 搴曢儴瀵艰埅鍏辩敤锛?
  - `casting/casting_page_state.dart` 鈥?GenerationState / DraftState / CastingPageState锛埪? 鍏ㄩ儴瀛楁锛?
  - `casting/widgets/` 鈥?casting_app_bar / draft_context / time_row / question_row / six_yao_input_panel / six_yao_input_row / yao_glyph / rule_pack_row / generate_row / chip / 鍥涗釜缂栬緫寮瑰眰锛坙ine/time/question/rule_pack sheet锛?
  - `review/review_page.dart` 鈥?瀹″崷宸ヤ綔鍙?
  - `relations/relations_page.dart` 鈥?鍏崇郴宸ヤ綔鍙?
  - `cases/cases_page.dart` 鈥?鍗︿緥宸ヤ綔鍙?
  - `training/training_page.dart` 鈥?璁粌锛堟棫鍔熻兘鏈潵缁熶竴鏀剁紪锛屾湰闃舵浠?Skeleton锛?
  - `rules/rule_library_page.dart` 鈥?瑙勫垯搴?Skeleton锛堣嚜瀹氫箟瑙勫垯/瑙勫垯鍖?绯荤粺瑙勫垯锛屾棤 CRUD锛?
  - `settings/settings_page.dart`銆乣about/about_page.dart` 鈥?鍗犱綅椤?
  - `shared/module_placeholder.dart` 鈥?妯″潡鍗犱綅鍏辩敤缁勪欢
- **`lib/services/draft/`**锛氳崏绋胯嚜鍔ㄤ繚瀛樿竟鐣岋紙搂15锛?
  - `casting_draft.dart` 鈥?鑽夌妯″瀷锛堝惈瑙嗚瀹氱婕旂ず鑽夌 CastingDraft.demo锛?
  - `draft_repository.dart` 鈥?DraftRepository 鎺ュ彛 + 鍐呭瓨瀹炵幇锛堝悗缁彲鎹㈡湰鍦板瓨鍌級
- **`test/foundation_test.dart`**锛欰pp Shell 浜斿鑸?/ 鑹崷鍥炬爣 / 鐘舵€佷繚鎸?/ 鏇村鑿滃崟楠屾敹
- **`test/presentation/casting/casting_page_test.dart`**锛氭帓鍗﹀伐浣滃彴娴嬭瘯锛圱est A鈥揇 / 琛岄『搴?/ 鑽夌浠撳簱 / 绾€昏緫锛?

### 淇敼
- `android/app/src/main/AndroidManifest.xml` 鈥?Activity 澧炲姞 `android:screenOrientation="portrait"` 閿佸畾绔栧睆锛沴abel 纭銆屽崷鐪笺€?
- `lib/main.dart` 鈥?鏇挎崲涓?2.0 鏋佺畝鍏ュ彛
- `file-tree.md` 鈥?璁板綍 2.0 楠ㄦ灦

### 璇存槑
- 鏃ц缁冭祫浜э紙`lib/pages/`銆乣lib/data/`銆乣lib/services/`銆乣lib/models/`銆乣lib/widgets/effects/`銆乣浜旇鐩稿厠鐗规晥/`銆乣浜旇鐩哥敓鐗规晥/` 绛夛級涓€寰嬩繚鐣欐湭杩佺Щ锛屽悗缁繘鍏ャ€岃缁冦€嶉樁娈电粺涓€澶勭悊銆?
- 鏃?`lib/app.dart`锛坄GuayanTrainerApp`锛変繚鐣欎緵鏃ф祴璇曞紩鐢紝涓?`lib/app/` 鐩綍鍏卞瓨銆?
- 鍒嗘敮鍒涘缓鍓嶅凡灏嗘湭鍙戝竷 hotfix 鎻愪氦鑷?master锛坄610e81f`锛夊苟鍚堝苟杩滅瀛︿範妯″潡鎻愪氦锛坄5c4bdb6`锛夈€?

---

## 鎴愭灉褰掓。鎻愪氦 鈥?2026-08-27锛堟湭鍙戝竷锛?

> 鑳屾櫙锛氬紑鍙戞満鍐呭瓨鑰楀敖宕╂簝閲嶅惎锛圙radle 鎻愪氦鍐呭瓨 errno 1455锛夛紝鍒ゅ畾鏈満鏆備笉鍏峰缁х画寮€鍙戞潯浠讹紝鍏ㄩ儴宸ヤ綔鎴愭灉涓€娆℃€у綊妗ｆ彁浜ゅ苟鎺ㄩ€?GitHub锛坄feat/guayan-2.0`锛夛紝闃叉鎴愭灉涓㈠け銆傝瑙?`CHANGELOG.md`銆?

### 鏂板
- `AGENTS.md` 鈥?椤圭洰浠ｇ爜瑙勫垯锛堟枃浠剁粍缁?/ 鏋舵瀯鍒嗗眰 / 鍛藉悕瑙勮寖 / 鏂囨。绾緥 / 鐗堟湰涓庢瀯寤猴級锛孉I 鑷姩閬靛畧
- `lib/data/training_question.dart` 鈥?2.0 璁粌鏁版嵁妯″瀷锛歚TrainingModule` / `RelationType` / `TrainingQuestion`
- `lib/data/wuxing_questions.dart` 鈥?浜旇鐢熷厠棰樺簱锛氱浉鐢?5 棰?+ 鐩稿厠 5 棰橈紙10 棰橈級
- `uploads/` 鈥?鍙傝€冭祫鏂欙細`XYUI1ComponentDocumentView.axaml`銆乣鍗︾溂 2.0 鎬诲紑鍙戣鍒?md`
- `浜旇鐩稿厠鐗规晥/` 鈥?5 涓浉鍏?HTML 鍔ㄧ敾鍘熷瀷锛堥噾鍏嬫湪/鏈ㄥ厠鍦?鍦熷厠姘?姘村厠鐏?鐏厠閲戯級
- `浜旇鐩哥敓鐗规晥/` 鈥?5 涓浉鐢?HTML 鍔ㄧ敾鍘熷瀷锛堥噾鐢熸按/姘寸敓鏈?鏈ㄧ敓鐏?鐏敓鍦?鍦熺敓閲戯級
- `CHANGELOG.md` 鈥?鏂囦欢瀹¤涓庡彉鏇存棩蹇?

### 淇敼
- `android/gradle.properties` 鈥?浣庡唴瀛樺紑鍙戞満绾︽潫锛欽VM 鍫?1G銆並otlin daemon 256m銆乣org.gradle.workers.max=1`锛岄伩鍏嶆瀯寤烘彁浜ゅ唴瀛樿€楀敖
- `file-tree.md` 鈥?璁板綍褰掓。鎻愪氦銆佹柊澧炴枃浠朵笌鏈€鍚庣紪杈戞椂闂?

---

## GUAYAN-2.0-DOMAIN 鈥?Stable Relation Identity锛?026-08-30锛屾湭鍙戝竷锛?

> 闃舵鐩爣锛?*RelationInstance 鍙互閲嶅缓锛孯elationNote 涓嶈兘澶卞繂銆?*
> 鍙仛鍥涗釜鏍稿績 Domain + 绋冲畾鍏崇郴韬唤锛屼笉鎵╄寖鍥达紱瀹屾暣璁捐瑙?`lib/domain/README.md`銆?

### 鏂板锛坙ib/domain/ 鈥?绾?Dart 棰嗗煙灞傦紝闆?Flutter/澶栭儴渚濊禆锛?
- `hexagram_case.dart` 鈥?鍗︿緥鎸佷箙鍖栨牴瀵硅薄锛堟渶灏忛鏋讹級
- `line_state.dart` 鈥?涓€鐖荤姸鎬侊細绋冲畾鐖讳綅 + 鍔ㄩ潤 + 鎵€鍊煎湴鏀?
- `line_endpoint.dart` 鈥?鍏崇郴绔偣绋冲畾韬唤锛堝崷渚?+ 鐖讳綅锛?
- `relation_type.dart` 鈥?鍏崇郴绫诲瀷鏋氫妇 + 绯荤粺瑙勫垯 RuleId 甯搁噺
- `relation_key.dart` 鈥?**Stable Relation Identity 鏍稿績**锛堝崟涓€鏋勯€犲叆鍙ｏ級
- `relation_instance.dart` 鈥?涓€鏉″叿浣撳叧绯伙紙閲嶇畻鍙噸寤猴級
- `relation_calculator.dart` 鈥?鏈€灏忕‘瀹氭€у叧绯昏绠楋紙鍔ㄥ彉/鍏啿/鍏悎锛?
- `relation_note.dart` 鈥?鍏崇郴绗旇锛坈aseId + RelationKey 閲嶆柊缁戝畾锛?
- `relation_note_store.dart` 鈥?绗旇缁戝畾瀛樺偍锛堢函鍐呭瓨 + JSON 瀵煎叆瀵煎嚭锛?

### 鏂板锛坱est/domain/锛?
- `domain_test_utils.dart` 鈥?鍏变韩婕旂ず鍗︿緥锛堝姩鍙?+ 鍏啿锛?
- `relation_key_test.dart` 鈥?Test A 纭畾鎬?/ Test B 宸紓鎬?/ 鏂瑰悜澶勭悊
- `relation_key_serialization_test.dart` 鈥?RelationKey JSON round-trip 涓庡睍绀哄悕瑙ｈ€?
- `relation_rebinding_test.dart` 鈥?Test C 閲嶇畻鎭㈠绗旇 / Test D 涓嶄覆绗旇 / Test E 椤哄簭鏃犲叧
- `relation_serialization_test.dart` 鈥?T8 搴忓垪鍖?鈫?鍙嶅簭鍒楀寲 鈫?閲嶇畻 鈫?閲嶆柊缁戝畾鍏ㄩ摼

### 鏂板锛坰cripts/锛?
- `flutter.ps1` 鈫?宸插垹闄わ細鏈満 Flutter 鍖呰鑴氭湰绉诲嚭鐗堟湰鎺у埗锛圚ARDENING T4锛夈€?
  鏈満宸ヤ綔鍖轰繚鐣?`scripts/flutter.local.ps1`锛堝惈鏈哄櫒璺緞涓庝唬鐞嗙鍙ｏ紝宸?.gitignore锛屼笉鍏ュ簱锛?

### 淇敼
- `lib/domain/README.md` 鈥?鍗犱綅璇存槑鏇挎崲涓?Stable Relation Identity 璁捐鏂囨。
- `test/domain/`锛堟柊寤虹洰褰曪級銆乣scripts/`锛堟柊寤虹洰褰曪級
- `file-tree.md` 鈥?璁板綍 DOMAIN 闃舵鏂板涓庤亴璐?

### 璇存槑
- RelationKey = 璇箟鍧愭爣锛堢被鍨嬫満鍣ㄥ悕 + RuleId + RuleVersion + subtype + 绔偣锛夛紝
  涓庤繍琛屾椂瀵硅薄 / UI 椤哄簭 / 鏁版嵁搴?row id 瑙ｈ€︼紱鏂瑰悜鏄惧紡澶勭悊锛堟湁鍚戜繚搴忋€佸绉版帓搴忥級銆?

---

## GUAYAN-2.0-DOMAIN-HARDENING 鈥?韬唤鏀跺彛锛?026-08-30锛屾湭鍙戝竷锛?

> 浜哄伐鏍搁獙鍚庡皝姝?4 涓暟鎹吋瀹归棶棰橈紱涓嶉噸鏋勩€佷笉杩涘叆 R3銆?
> 楠屾敹鍙ワ細RelationInstance 鍙噸寤猴紱RelationNote 涓嶅け蹇嗭紱
> RuleVersion 鍙樺寲涓嶈兘璁╁巻鍙插崷渚嬪け蹇嗭紱浠绘剰鍚堟硶 RuleId/Subtype 涓嶈兘鍒堕€犺韩浠界鎾烇紱
> 鍧?Case 鏁版嵁涓嶈兘鍒堕€犻噸澶嶈韩浠姐€?

### 鏂板
- `lib/domain/rule_execution_context.dart` 鈥?瑙勫垯鐗堟湰 replay 涓婁笅鏂囷紙RuleVersionRef / RuleExecutionContext锛?
- `test/domain/relation_key_collision_test.dart` 鈥?T1 canonical 鏃犳涔夋€э紙鍚?`|`/`->`/`<->`/`\` 纰版挒鍥炲綊锛?
- `test/domain/rule_version_replay_test.dart` 鈥?T2 鏃у崷渚?v1 鈫?鍗囩骇 v2 鈫?reload 鈫?replay v1 鈫?绗旇鎭㈠
- `test/domain/domain_invariants_test.dart` 鈥?T3 鐖讳綅/鍏埢涓嶅彉閲?+ 鍧?JSON 鎷掔粷

### 淇敼
- `lib/domain/relation_key.dart` 鈥?canonical 鏃犳涔夊寲锛氬瓧绗︿覆瀛楁绋冲畾杞箟锛坄\`鈫抈\\`锛宍|`鈫抈\|`锛夛紝鍗曞皠缂栫爜
- `lib/domain/hexagram_case.dart` 鈥?鏂板 `ruleContext` 瀛楁锛況untime 鏍￠獙鎭板ソ 6 鐖汇€乸osition 鎭颁负 1..6銆佹棤閲嶅
- `lib/domain/line_endpoint.dart` / `line_state.dart` 鈥?鏋勯€犱笌 JSON 鍙嶅簭鍒楀寲 runtime 鏍￠獙鐖讳綅锛?..6锛?
- `lib/domain/relation_calculator.dart` 鈥?瑙勫垯鐗堟湰浼樺厛鍙?`case.ruleContext.versionForOrDefault(ruleId)`锛屾棤璁板綍鍥為€€ v1
- `.gitignore` 鈥?`scripts/flutter.local.ps1` 涓嶅叆搴擄紱`*.apk` 蹇界暐
- `lib/domain/README.md` 鈥?琛ュ厖 escaping / replay 濂戠害 / runtime 涓嶅彉閲忚璁?
- `scripts/flutter.ps1` 鈥?鍒犻櫎锛堢Щ鍑虹増鏈帶鍒讹級

### 楠岃瘉
- `flutter test` 53/53 閫氳繃锛堝師 Test A鈥揈 + T8 鏃犲洖褰掞紱鏂板 23 椤癸級
- `flutter analyze` 鏈疆鏂囦欢 0 issue锛汚ndroid debug 鏋勫缓鎴愬姛锛涙湭鍚姩妯℃嫙鍣?

---

## 鎺掑崷椤?XYUI 鏀归€?鈥?Vertical Casting Workflow锛?026-08-30锛屾湭鍙戝竷锛?

> 鏂规 2 路 绾靛悜鎺掑崷娴佺▼杞細璧峰崷鏃堕棿 鈫?闂簨淇℃伅 鈫?鍏埢杈撳叆 鈫?瑙勫垯鍖?鈫?鐢熸垚鎺掔洏銆?
> 瑙嗚浠ヤ换鍔′功 SVG 涓哄敮涓€鍩哄噯锛涙湰杞负瑙嗚闃舵锛屾楠ゆ憳瑕佷负婕旂ず鍗犱綅鍊硷紝
> 瀹屾暣琛ㄥ崟涓庢帓鐩樼畻娉曞睘鍚庣画闃舵銆?

### 鏂板锛坙ib/presentation/casting/锛?
- `casting_tokens.dart` 鈥?XYUI 瑙嗚 Token 闆嗕腑锛堥〉闈?闈㈡澘/杈规/鏂囧瓧/璀︾ず/寰芥爣/鐢熸垚姝ラ锛?
- `casting_page_state.dart` 鈥?`CastingStepState`锛坈urrent/pending/completed/warning/locked锛? `CastingStepData` + `CastingFlowState`
- `widgets/casting_top_bar.dart` 鈥?XYUI 椤舵爮锛堟爣棰?鍓爣棰?涓夌偣鏇村锛?
- `widgets/casting_flow_header.dart` 鈥?CASTING FLOW 澶撮儴锛堝綋鍓嶆楠?x/5锛?
- `widgets/casting_workflow.dart` 鈥?娴佺▼杞ㄧ粍瑁咃紙rail + 姝ラ琛岋級
- `widgets/casting_flow_rail.dart` 鈥?绾靛悜绔栫嚎
- `widgets/casting_step_node.dart` 鈥?鑺傜偣鐘舵€佸叏闆嗭紙鏁板瓧/瀵瑰嬀/!/閿侊紝鐭㈤噺缁樺埗锛?
- `widgets/casting_step_card.dart` 鈥?姝ラ鍗★紙current/pending/completed/warning锛?
- `widgets/casting_step_status.dart` 鈥?鐘舵€佸窘鏍?+ chevron
- `widgets/casting_generate_step.dart` 鈥?鐢熸垚姝ラ锛坙ocked/ready/completed/warning锛?
- `widgets/casting_context_strip.dart` 鈥?娴佺▼涓婁笅鏂囨潯锛堣鍒欏寘/鎺㈤拡/宸插畬鎴?x/5锛?

### 鏂板 / 淇敼
- `lib/app/navigation/guayan_main_tab_bar.dart`锛堟柊澧烇級鈥?XYUI 搴曢儴瀵艰埅 + 浜斿浘鏍?CustomPainter
- `lib/app/navigation/main_tabs.dart` 鈥?MainTab 澧炲姞 iconBuilder锛圶YUI 鍥炬爣锛?
- `lib/app/app_shell.dart` 鈥?NavigationBar 鈫?GuayanMainTabBar锛涙帓鍗﹂〉鏃犲叏灞€ AppBar
- `lib/app/more_menu.dart` 鈥?鏀寔鑷畾涔?icon
- `lib/presentation/casting/casting_page.dart` 鈥?閲嶅啓涓烘祦绋嬭建椤甸潰锛堢姸鎬佹満锛氭帹杩?鐢熸垚/闇€閲嶆柊鐢熸垚/鎺㈤拡锛?
- `test/foundation_test.dart` 鈥?閫傞厤鏂?UI锛圶YUI 瀵艰埅/鎺掑崷娴佺▼杞?鎺㈤拡 Key/涓夌偣鏇村锛?
- `test/presentation/casting/casting_page_test.dart`锛堟柊澧烇級鈥?宸ヤ綔娴佺姸鎬佹祴璇?

### 璇存槑
- 鐘舵€佽繘鍏ョ湡瀹?State锛圕astingStepState锛夛紝涓嶄粠棰滆壊鍙嶆帹锛涘凡瀹屾垚姝ラ鍙噸鏂拌繘鍏ワ紝
  鐢熸垚鍚庝慨鏀瑰叧閿暟鎹?鈫?鐢熸垚姝ラ鏍囪銆岄渶閲嶆柊鐢熸垚銆嶏紙涓嶆竻绌哄凡濉唴瀹癸級銆?
- 鍘熴€岀姸鎬佹帰閽堬細0銆嶅绔嬫枃鏈Щ闄わ紝鎺㈤拡璇箟淇濈暀鍦?Context Strip锛堝彲鐐瑰嚮閫掑锛夈€?
- 楠岃瘉锛歠lutter test 63/63 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug 鏋勫缓閫氳繃銆?

---

## 鏈彂甯冨彉鏇?鈥?2026-05-26

### 淇
- **閿欓鍥炵倝鍒濆鍖?*锛歚MistakeStore` 鏂板鏄惧紡 `init()`锛屽簲鐢ㄥ惎鍔ㄦ椂鐪熸绛夊緟 SharedPreferences 鏁版嵁鍔犺浇锛岄伩鍏嶉椤?缁冧範/鍥炵倝棣栨璇诲彇閿欓鏁伴噺涓虹┖銆?
- **杩炶繛鐪嬫瀯寤洪敊璇?*锛氫慨澶?`LinkMatchGamePage` HUD 涓姩鎬侀敊璇暟浣跨敤 `const TextStyle` 瀵艰嚧鐨勭紪璇戝け璐ャ€?

### 淇敼鏂囦欢
- `lib/main.dart` 鈥?鍚姩鏃惰皟鐢?`MistakeStore.instance.init()`銆?
- `lib/services/mistake_store.dart` 鈥?鏆撮湶鍒濆鍖栧叆鍙ｏ紝淇濈暀鍚屾 `all` 璇诲彇缂撳瓨銆?
- `lib/pages/practice/games/link_match_game_page.dart` 鈥?淇鍔ㄦ€?HUD 鏍峰紡鐨?const 浣跨敤銆?
- `file-tree.md` 鈥?鏇存柊鏈€鍚庣紪杈戞椂闂淬€佹湭鍙戝竷鍙樻洿鍜岀浉鍏宠亴璐ｈ鏄庛€?

---

## 鏈彂甯冩洿鏂版棩蹇楋紙杩滅鍚堝苟锛?

### 鏂板
- **浜旇鎰忚薄瀛︿範椤?*锛歚WuxingImageryPage` 鈥?浜旇鐭ヨ瘑鎬诲崱 + 棰滆壊銆佷簲鍛炽€佽剰鑵戙€佹柟浣嶃€佸搧璐ㄣ€佹暟瀛椼€佸洓瀛ｃ€佸湴鏀簲琛屽垎鏉垮潡鎰忚薄
- **鍏崷瀛︿範椤?*锛歚BaguaStudyPage` 鈥?鍏崷浜х敓銆佹瓕璇€銆佺煡璇嗘€诲崱銆佸叓鍗﹀垎鍗°€佺梾璞℃姌鍙犱笌鏂囩帇鍗︿娇鐢ㄦ彁绀?

### 淇敼
- **瀛︿範鍏ュ彛鍛藉悕**锛歚浜旇鐢熷厠` 鏀逛负 `浜旇妯″潡`
- **瀛︿範鍏ュ彛鎵╁睍**锛氭柊澧?`鍏崷妯″潡`锛屼綅浜庝簲琛屾ā鍧椾箣鍚庛€佸崄浜屽湴鏀箣鍓?
- **浜旇妯″潡鐩綍**锛氭媶鍒?`浜旇棰滆壊` 涓?`浜旇鎰忚薄`锛屽悗缁浉鐢熴€佺浉鍏嬨€佷互鎴戜负涓績椤哄欢
- **浜旇棰滆壊椤?*锛氫笅涓€姝ヨ烦杞敼涓鸿繘鍏?`浜旇鎰忚薄`

---

## 褰撳墠鐗堟湰鏇存柊鏃ュ織 鈥?v0.1.10

> 鍙戝竷鏃ユ湡锛?026-05-22 路 [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.10)

### 鏂板
- **鍏崇郴杩炶繛鐪嬫父鎴?*锛歚LinkMatchGamePage` 鈥?25 缁勯厤瀵?/ 50 寮犲崱鐗屾秷闄ゆā鏉?
- **`PracticeMode.linkMatch`**锛氱涓夌缁冧範妯″紡
- **`HitEffectKind` / `FallingRuleKind`** 鏋氫妇锛氫负鍚庣画鍦版敮鍚?鍐查鐣?

### 娓告垙瑙勫垯
- 涓婃柟婧愮墝 25 寮?+ 涓嬫柟鐩爣鐗?25 寮狅紝鍚勮嚜鎵撲贡
- 鐐瑰嚮婧愮墝 鈫?楂樹寒 鈫?鐐瑰嚮鐩爣鐗屽畬鎴愰厤瀵?
- 姝ｇ‘锛氣潳锔?鈿?鍙嶉 + 涓ゅ紶鐗屾秷闄ゆ秷澶?+ 鍔犲垎杩炲嚮
- 閿欒锛氭墸鍛?+ 鏄剧ず姝ｇ‘绛旀 + 鍐欏叆鍥炵倝
- 榛樿 5 鏉″懡锛屽叏閮ㄩ厤瀹屾垨鍛界敤瀹?鈫?缁撴灉椤?

### 鏂板鏂囦欢
- `lib/pages/practice/games/link_match_game_page.dart` 鈥?杩炶繛鐪嬫父鎴忎富椤甸潰

### 淇敼鏂囦欢
- `lib/models/practice/practice_enums.dart` 鈥?PracticeMode.linkMatch + HitEffectKind + FallingRuleKind
- `lib/pages/practice/practice_setup_page.dart` 鈥?鏂板杩炶繛鐪嬫ā寮忛€夋嫨涓庤烦杞?
- `lib/pages/practice/practice_result_page.dart` 鈥?鏂板 matchedCount/totalPairs 鍙傛暟
- `lib/pages/practice/practice_page.dart` 鈥?瓒ｅ懗娓告垙鍖哄鍔犺繛杩炵湅鍏ュ彛
- `lib/utils/practice_labels.dart` 鈥?PracticeStage 澧炲姞 linkMatch
- `lib/theme/wuxing_colors.dart` 鈥?閲戦鑹蹭紭鍖?

---

## 鍓嶇増鏇存柊鏃ュ織 鈥?v0.1.9

> 鍙戝竷鏃ユ湡锛?026-05-22 路 [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.9)

### 鏂板
- **鏂瑰潡閫熺瓟娓告垙**锛氶€氱敤鍗曟柟鍧椾笅钀芥ā鏉?`FallingBlockGamePage`
- **`PracticeMode.fallingBlock`**锛氭寮忓惎鐢ㄦ柟鍧楅€熺瓟妯″紡
- **`PracticeSetupPage` 妯″紡閫夋嫨**锛氭櫘閫氱粌涔?/ 鏂瑰潡閫熺瓟 浜岄€変竴鍒囨崲
- **`PracticeResultPage` 娓告垙缁熻**锛氭柊澧?`score` / `maxCombo` / `remainingLives` 鍙€夋樉绀?
- **閿欓鍐欏叆**锛氱瓟閿?婕忔帀缁熶竴璧?`MistakeStore.addOrUpdateMistake`锛屾紡鎺夋樉绀?鏈綔绛?

### 娓告垙瑙勫垯
- 棰樼洰鏂瑰潡浠庝笂寰€涓嬫帀锛岀偣鍑诲簳閮ㄦ纭瓟妗?
- 绛斿锛氬緱鍒?+10+杩炲嚮锛岃繛鍑婚€掑
- 绛旈敊锛氱敓鍛?-1锛岃繛鍑绘竻闆讹紝鍐欏叆鍥炵倝
- 婕忔帀锛氱敓鍛?-1锛屾爣璁拌秴鏃讹紝鍐欏叆鍥炵倝
- 鍩虹涓嬭惤 4500ms锛屾瘡 5 杩炲嚮鍔犻€?250ms锛屾渶浣?2200ms
- 棰樼洰鐢ㄥ畬鎴栫敓鍛藉綊闆?鈫?缁撴灉椤?

### 鏂板鏂囦欢
- `lib/pages/practice/games/falling_block_game_page.dart` 鈥?鎵撴柟鍧楁父鎴忎富椤甸潰

### 淇敼鏂囦欢
- `lib/models/practice/practice_enums.dart` 鈥?PracticeMode 澧炲姞 fallingBlock
- `lib/pages/practice/practice_setup_page.dart` 鈥?澧炲姞妯″紡閫夋嫨涓庤烦杞?
- `lib/pages/practice/practice_result_page.dart` 鈥?澧炲姞娓告垙缁熻瀛楁

---

**鍗︾溂璁粌鍣?* 鏄柇鍗﹀熀鏈姛璁粌 App锛岀敤浜庤缁冧簲琛岀敓鍏嬨€佸湴鏀€佸叚鍐插叚鍚堢瓑鍩虹鐭ヨ瘑銆?

褰撳墠鎶€鏈爤锛?

| 绫诲瀷 | 鎶€鏈?|
| --- | --- |
| 鍓嶇妗嗘灦 | Flutter 3.x |
| 璇█ | Dart 3.x |
| 鐩爣骞冲彴 | Android |

鏍稿績璁粌闂幆锛氬涔?鈫?缁冧範 鈫?鍑洪敊/杩熺枒 鈫?鍥炵倝 鈫?鍐嶇粌涔犮€?

---

## 2. 椤跺眰鐩綍缁撴瀯

```text
guayan_trainer/
鈹溾攢鈹€ .claude/                # AI 鍗忎綔瑙勫垯
鈹溾攢鈹€ android/                # Android 鍘熺敓澹?
鈹溾攢鈹€ assets/                 # 闅忓寘璧勬簮锛坅ssets/calendar/ = 骞村害鍘嗘硶鏁版嵁鍖咃級
鈹溾攢鈹€ lib/                    # 涓荤▼搴忔簮鐮?
鈹溾攢鈹€ memory/                 # 璁板繂涓庡弽棣堣褰?
鈹溾攢鈹€ scripts/                # 寮€鍙戣緟鍔╄剼鏈紙鏈満 flutter 鍖呰锛?
鈹溾攢鈹€ test/                   # 娴嬭瘯
鈹溾攢鈹€ tool/                   # 寮€鍙戦樁娈靛伐鍏凤紙涓嶅弬涓?App 杩愯鏃讹級
鈹溾攢鈹€ uploads/                # 鍙傝€冭祫鏂欙紙寮€鍙戣鍒掋€佺粍浠舵枃妗ｏ級
鈹溾攢鈹€ 浜旇鐩稿厠鐗规晥/            # 鐩稿厠 HTML 鍔ㄧ敾鍘熷瀷锛? 涓級
鈹溾攢鈹€ 浜旇鐩哥敓鐗规晥/            # 鐩哥敓 HTML 鍔ㄧ敾鍘熷瀷锛? 涓級
鈹溾攢鈹€ AGENTS.md               # 椤圭洰浠ｇ爜瑙勫垯锛圓I 鑷姩閬靛畧锛?
鈹溾攢鈹€ CHANGELOG.md            # 鏂囦欢瀹¤涓庡彉鏇存棩蹇?
鈹溾攢鈹€ file-tree.md            # 椤圭洰缁撴瀯璇存槑鏂囨。
鈹斺攢鈹€ pubspec.yaml            # Flutter 渚濊禆閰嶇疆
```

---

## 3. lib 鐩綍缁撴瀯

```text
lib/
鈹溾攢鈹€ main.dart               # 搴旂敤鍏ュ彛
鈹溾攢鈹€ app.dart                # MaterialApp 涓婚閰嶇疆
鈹溾攢鈹€ app/                    # 2.0 搴旂敤澹筹紙GuayanApp / AppShell / 瀵艰埅锛?
鈹溾攢鈹€ core/                   # 2.0 甯搁噺
鈹溾攢鈹€ domain/                 # 2.0 棰嗗煙灞傦紙DOMAIN + R3 鎺掔洏寮曟搸 + R3-B 鍘嗘硶灞傦級
鈹溾攢鈹€ application/            # 2.0 鐢ㄤ緥灞傦紙棰勭暀锛?
鈹溾攢鈹€ presentation/           # 2.0 浜斾釜涓婚〉闈?+ 瑙勫垯搴?璁剧疆/鍏充簬
鈹溾攢鈹€ shell/                  # 鏃у鑸３锛?.0 閬楃暀锛?
鈹溾攢鈹€ theme/                  # 棰滆壊绯荤粺
鈹溾攢鈹€ data/                   # 鏁版嵁灞傦細绾暟鎹槧灏勪笌甯搁噺
鈹溾攢鈹€ models/                 # 妯″瀷灞傦細绫诲瀷瀹氫箟
鈹溾攢鈹€ services/               # 鏈嶅姟灞傦細涓氬姟閫昏緫
鈹溾攢鈹€ pages/                  # 椤甸潰灞傦細鎸夊姛鑳藉垎瀛愮洰褰曪紙1.0 閬楃暀锛?
鈹斺攢鈹€ widgets/                # 缁勪欢灞傦細鍙鐢ㄧ粍浠讹紙1.0 閬楃暀锛?
```

---

## 4. 妯″潡鑱岃矗璇存槑

| 妯″潡 | 鑱岃矗 | 鏄惁渚濊禆 Flutter/Widget |
| --- | --- | --- |
| `theme/` | 浜旇棰滆壊绯荤粺銆佷富棰樿壊甯搁噺 | 鏄紙Color锛?|
| `shell/` | 搴曢儴瀵艰埅澹炽€侀〉闈㈠垏鎹?| 鏄?|
| `data/` | 鏁版嵁琛ㄣ€佸父閲忋€佺函鏄犲皠锛堜簲琛?鍦版敮/鍐插悎锛?| 鍚?|
| `models/` | 绫诲瀷瀹氫箟銆佹暟鎹粨鏋?| 鍚?|
| `services/` | 鍑洪寮曟搸銆侀敊棰樺瓨鍌?| 鍚?|
| `pages/` | 椤甸潰缁勪欢涓庣敤鎴蜂氦浜?| 鏄?|
| `widgets/` | 鍙鐢?UI 缁勪欢 | 鏄?|

---

## 5. 鍏抽敭鏂囦欢鑱岃矗

### 5.1 鏍圭洰褰?

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `pubspec.yaml` | 椤圭洰鍏冧俊鎭€佷緷璧栧０鏄庝笌 flutter 閰嶇疆 |
| `file-tree.md` | 椤圭洰鏂囦欢鏍戜笌妯″潡璇存槑鏂囨。 |

### 5.2 .claude/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `CLAUDE.md` | AI 鍗忎綔瑙勫垯锛氭枃浠剁粍缁囥€佹灦鏋勫垎灞傘€佸懡鍚嶈鑼冦€佹枃妗ｇ邯寰?|

### 5.3 lib/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `main.dart` | 搴旂敤鍏ュ彛锛屽垵濮嬪寲閿欓缂撳瓨鍚庤皟鐢?`runApp` 鍚姩 `GuayanTrainerApp` |
| `app.dart` | MaterialApp 缁勮锛岄厤缃彜椋庝富棰樿壊绯伙紝home 鎸囧悜 `MainShell` |

### 5.3.1 lib/domain/锛?.0 棰嗗煙灞傦級

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `hexagram_case.dart` | 鍗︿緥鎸佷箙鍖栨牴瀵硅薄锛歩d / question / createdAt / lines[6] |
| `line_state.dart` | 涓€鐖荤姸鎬侊細鐖讳綅 / 鍔ㄩ潤锛堣€侀槾鑰侀槼鍙戝姩锛? 鎵€鍊煎湴鏀?|
| `line_endpoint.dart` | 鍏崇郴绔偣绋冲畾韬唤锛氬崷渚э紙original/changed锛? 鐖讳綅锛?..6锛?|
| `relation_type.dart` | 鍏崇郴绫诲瀷鏋氫妇 + 鏂瑰悜绫诲埆 + 灞曠ず鍚?+ 绯荤粺 RuleId 甯搁噺 |
| `relation_key.dart` | 鍏崇郴绋冲畾璇箟 key锛圫table Relation Identity 鏍稿績锛?|
| `relation_instance.dart` | 涓€鏉″叿浣撳叧绯诲疄渚嬶紙韬唤浠?key 涓哄噯锛屽彲閲嶇畻閲嶅缓锛?|
| `relation_calculator.dart` | 鏈€灏忕‘瀹氭€у叧绯昏绠楋細鍔ㄥ彉 / 鍏啿 / 鍏悎 |
| `relation_note.dart` | 鍏崇郴绗旇瀹炰綋锛坈aseId + RelationKey 缁戝畾锛?|
| `relation_note_store.dart` | 绗旇缁戝畾瀛樺偍锛氱函鍐呭瓨 + JSON 瀵煎叆瀵煎嚭 |
| `README.md` | 棰嗗煙璁捐涓?Stable Relation Identity 璇存槑 |
| `wu_xing.dart` | 浜旇 + 鐢熷厠锛沗relationTo(self)` 涓哄叚浜插垽瀹氬敮涓€鍏ュ彛锛圧3锛?|
| `di_zhi.dart` | 鍗佷簩鍦版敮锛氫簲琛?/ 闃撮槼 / 鍏啿 / 鍏悎锛圧3锛?|
| `tian_gan.dart` | 鍗佸ぉ骞诧細浜旇 / 闃撮槼 / 鍏崄鐢插瓙鍙栧共锛圧3锛?|

### 5.3.2 lib/domain/casting/锛圧3 鎺掔洏寮曟搸锛?

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `bagua.dart` | 鍏崷锛堜笁鐖昏嚜涓嬭€屼笂锛? 鍗︾ + 浜旇 + 鍏堝ぉ搴?|
| `najia.dart` | 绾崇敳琛紙骞叉敮锛夛細涔剧撼鐢插，銆佸潳绾充箼鐧革紱鍐呭鍗﹀垎鍒鍗?|
| `palace.dart` | 浜埧鍏鍗﹀簭 + 涓栧簲锛堢畻娉曠敓鎴愶紝闈炵‖缂栫爜 64 鏉★級 |
| `hexagram_names.dart` | 鍏崄鍥涘崷鍚嶈〃锛堜笂鍗?脳 涓嬪崷锛?|
| `hexagram64.dart` | 鍏埢闃撮槼 鈫?鍗﹀悕 / 瀹綅 / 涓栧簲 |
| `six_relative.dart` | 鍏翰锛堜互瀹綅浜旇涓恒€屾垜銆嶏級 |
| `six_spirit.dart` | 鍏锛堟寜鏃ュ共璧蜂緥锛岃嚜鍒濈埢鍚戜笂椤烘帓锛?|
| `cast_chart.dart` | 鎺掔洏缁撴灉妯″瀷锛圕astLine / CastChart锛?|
| `casting_engine.dart` | 寮曟搸缁勮锛氭湰鍗?/ 鍙樺崷 / 鍔ㄥ彉 / 绾崇敳 / 涓栧簲 / 鍏翰 / 鍏 |

### 5.3.3 lib/domain/calendar/锛圧3-B 绂荤嚎鍘嗘硶灞傦級

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `calendar_engine.dart` | 鍘嗘硶寮曟搸锛氳仛鍚堟湀寤?/ 鏃ヨ景 / 鏃┖ |
| `calendar_request.dart` | 杈撳叆濂戠害锛歭ocalDateTime + utcOffset + dayBoundaryRule |
| `calendar_context.dart` | 杈撳嚭濂戠害锛氬畬鏁村巻娉曚笂涓嬫枃锛堜笉鍏佽鍗婃垚鍝侊級 |
| `calendar_error.dart` | 绫诲瀷鍖栧け璐ワ細InvalidCalendarDate / CalendarDataMissing / PackInvalid / RevisionRejected |
| `day_boundary_rule.dart` | 鏃ョ晫瑙勫垯锛歮idnight / ziHourStart锛屾棤闅愬紡榛樿鍊?|
| `day/ganzhi_day.dart` | 鏃ユ煴锛氬剴鐣ユ棩搴?鈫?鍏崄鐢插瓙锛堥敋鐐?1949-10-01 鐢插瓙鏃ワ級 |
| `day/xun_kong.dart` | 鏃┖锛氱敱鏃鎺ㄥ锛屼笉缁存姢鎵嬫妱琛?|
| `solar_term/solar_term_id.dart` | 浜屽崄鍥涜妭姘?+ 澶槼榛勭粡 + 鑺?姘斿尯鍒?|
| `solar_term/solar_term.dart` | 鑺傛皵璁板綍锛堢湡婧愪负銆岀灛闂淬€嶈€岄潪鏃ユ湡锛?|
| `solar_term/solar_term_provider.dart` | 鑺傛皵鏉ユ簮鎶借薄锛堝彲鏇挎崲杈圭晫锛?|
| `solar_term/calendar_year_data.dart` | 宸叉牎楠岀殑鍗曞勾鍘嗘硶鏁版嵁 |
| `solar_term/month_branch_resolver.dart` | 鏈堝缓锛氬崄浜屻€岃妭銆嶅尯闂村垽鏂紙涓庡叕鍘嗘湀鏃犲叧锛?|
| `import/calendar_data_pack.dart` | 鏁版嵁鍖呭師濮嬪舰鎬侊紙瀛楁鍙┖锛屼氦鐢辨牎楠屽櫒姹囨€伙級 |
| `import/calendar_data_pack_parser.dart` | JSON 鈫?鏁版嵁鍖咃紙鍙礋璐ｈ娉曚笌缁撴瀯锛?|
| `import/calendar_data_pack_terms.dart` | 鑺傛皵鍒楄〃瑙勫垯锛氭暟閲?/ 鍞竴 / 閫掑 / 骞翠唤鍚堢悊鎬?|
| `import/calendar_data_pack_validator.dart` | 鍏冩暟鎹牎楠?+ 涓€娆℃€ф眹鎬诲叏閮ㄥけ璐ュ師鍥?|
| `import/calendar_data_pack_importer.dart` | 瑙ｆ瀽鈫掓牎楠屸啋淇鍒ゅ畾鈫?*鍘熷瓙鎻愪氦** |
| `store/calendar_data_store.dart` | 鏈湴浠撳偍杈圭晫 + 鍐呭瓨瀹炵幇 |
| `store/stored_solar_term_provider.dart` | 浠撳偍 鈫?Provider锛堝紓姝ヨ杞藉揩鐓э紝寮曟搸淇濇寔鍚屾锛?|

### 5.3.4 lib/presentation/review/锛?.0 瀹″崷宸ヤ綔鍙帮級

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `review_page.dart` | 瀹″崷宸ヤ綔鍙扮粍瑁咃紙搂3 甯冨眬锛欱asicInfo 鈫?ShenSha 鈫?FourPillars 鈫?Header 鈫?Table 鈫?Focus锛?|
| `review_page_state.dart` | 绾?Dart 鐘舵€佹ā鍨嬶紙搂7 鍏ㄩ儴瀛楁锛屾湭鎺ュ叆瀛楁鏄惧紡 nullable锛?|
| `review_case_adapter.dart` | HexagramCase + 浼犵粺妗ｆ 鈫?ReviewPageState锛涚劍鐐瑰叧绯绘潵鑷?Domain 璁＄畻 |
| `review_demo_data.dart` | 瑙嗚瀹氱婕旂ず鏁版嵁锛圫VG 閫愰」杞綍锛?|
| `widgets/review_app_bar.dart` | 椤舵爮锛堣繑鍥?chevron + 瀹″崷 + 鎺掔洏缁撴灉锛?|
| `widgets/review_basic_info_card.dart` | 鍩烘湰淇℃伅鍗★紙鏂瑰紡/浜嬮」/闃冲巻/闃村巻 + 宸茬敓鎴愶級 |
| `widgets/review_shensha_card.dart` | 绁炵厼鍗★紙Wrap 鏍囩缃戞牸锛屾暟鎹┍鍔級 |
| `widgets/review_four_pillars_strip.dart` | 鍥涙煴鏉★紙骞?鏈?鏃?鏃?鏃┖锛宻oft 搴?44 楂橈級 |
| `widgets/review_hexagram_result_table.dart` | 瀹屾暣鍗︾洏缁勪欢锛堝唴宓屼富/鍙樺崷鏍囬 + 鍏鎺掔洏 + 琛ㄥ熬锛?|
| `widgets/review_hexagram_line_row.dart` | 鍏埢鍗曡锛?1 鍒楀喕缁擄紝鍏翰鍦版敮/绾抽煶鎷嗕袱琛屾棤鐪佺暐鍙凤紝鍙偣楂樹寒锛?|
| `widgets/review_line_detail_sheet.dart` | 鐐圭埢 Bottom Sheet锛堝叧绯诲垪琛?瑙勫垯渚濇嵁/澶囨敞/杩涘叆鍏崇郴椤碉級 |

### 5.3.5 lib/presentation/shared/锛?.0 鍏变韩鐖荤粍浠讹紝鎺掑崷/瀹″崷寮哄埗澶嶇敤锛?

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `yao_glyph.dart` | 缁熶竴鐖绘Ы 24脳6锛坹ang/yin/voidYao锛屼粎鍐呴儴濉厖涓嶅悓锛?|
| `moving_marker.dart` | 鍔ㄧ埢鏍囪 12脳12锛堣€侀槾 鈼?/ 鑰侀槼 脳锛孊ounding Box 涓€鑷达級 |

### 5.4 lib/shell/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `main_shell.dart` | 搴曢儴鍥涙爮瀵艰埅锛堥椤?瀛︿範/缁冧範/鍥炵倝锛夛紝`IndexedStack` 椤甸潰淇濇寔 |

### 5.5 lib/theme/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `wuxing_colors.dart` | 浜旇涓昏壊 + 娴呭簳鑹叉槧灏勶紝鍦版敮鈫掍簲琛屸啋棰滆壊鏌ヨ锛屾枃瀛楀姣旇壊璁＄畻 |

### 5.6 lib/data/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `wuxing_data.dart` | 浜旇鍒楄〃 + 鐩哥敓鐩稿厠鏄犲皠琛?+ 鍙嶅悜鏌ヨ |
| `wuxing_self_center_data.dart` | 浠ユ垜涓轰腑蹇冨叧绯绘槧灏?+ 鏃虹浉浼戝洑姝?|
| `dizhi_data.dart` | 鍗佷簩鍦版敮缁撴瀯鍖栨暟鎹細浜旇銆侀槾闃炽€佹柟浣嶃€佹湀浠?|
| `relation_data.dart` | 鍏啿鍏悎鏄犲皠 + 鍙岀鏌ヨ + 鍏崇郴鍒ゅ畾 |
| `training_question.dart` | 2.0 璁粌鏁版嵁妯″瀷锛歍rainingModule / RelationType / TrainingQuestion |
| `wuxing_questions.dart` | 浜旇鐢熷厠棰樺簱锛氱浉鐢?5 棰?+ 鐩稿厠 5 棰?|
| `practice/wuxing_practice_question_generator.dart` | 閫氱敤棰樺簱鐢熸垚鍣細鍥涚被浜旇棰樺簱娣峰悎鍑洪 |

### 5.7 lib/models/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `mistake_item.dart` | 閿欓璁板綍妯″瀷锛屾寔涔呭寲 JSON 搴忓垪鍖?|
| `training_question.dart` | 棰樼洰绫诲瀷鏋氫妇锛? 绉嶏級+ 棰樼洰鏁版嵁绫?|
| `training_result.dart` | 鍗曢浣滅瓟璁板綍 + 璁粌浼氳瘽缁熻锛堟纭巼/鍥炵倝/杩熺枒锛?|
| `practice/practice_enums.dart` | 閫氱敤缁冧範鏋氫妇锛孌omain / Topic / AnswerKind / Stage |
| `practice/practice_question.dart` | 閫氱敤棰樼洰妯″瀷 |
| `practice/practice_answer_record.dart` | 绛旈璁板綍 + 浼氳瘽缁熻 + 鍒嗛」缁熻 |

### 5.8 lib/services/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `question_generator.dart` | 鍑洪寮曟搸锛? 绉嶈缁冩ā寮?脳 8 绉嶉鍨嬮殢鏈虹敓鎴?|
| `mistake_store.dart` | 閿欓鍥炵倝瀛樺偍鍣細鍚姩鍒濆鍖栥€佹敹褰曠瓟閿?杩熺枒锛屾爣璁板凡浼氬悗绉婚櫎 |

### 5.9 lib/utils/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `practice_labels.dart` | 閫氱敤缁冧範涓枃鏍囩銆侀搴撳閲忋€佹椂闂存牸寮忓寲鍑芥暟 |

### 5.10 lib/pages/home/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `home_page.dart` | 瀛︿範浠〃鐩橈細鏍囬璇存槑 + 瀛︿範鐘舵€佸崱 + 鍥炵倝鎻愰啋 + 蹇嵎鍏ュ彛 |

### 5.11 lib/pages/study/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `study_page.dart` | 瀛︿範椤靛叆鍙ｏ細浜旇妯″潡/鍏崷妯″潡/鍗佷簩鍦版敮/鍏啿鍏悎鍥涘紶瀛︿範鍗＄墖 |
| `bagua_study_page.dart` | 鍏崷妯″潡璇︽儏椤碉細鍏崷浜х敓銆佹瓕璇€銆佺煡璇嗘€诲崱銆佸垎鍗°€佺梾璞′笌鏂囩帇鍗︽彁绀?|
| `wuxing_study_menu_page.dart` | 浜旇妯″潡鐩綍椤碉細棰滆壊銆佹剰璞°€佺敓鍏嬨€佷互鎴戜负涓績瀵艰埅鍗＄墖 + 缁煎悎缁冧範 + 瀛︿範寤鸿 |
| `wuxing_color_page.dart` | 浜旇棰滆壊璇︽儏椤碉細棰滆壊鍗＄墖銆佸鐓ц〃銆佽蹇嗘彁绀猴紝涓嬩竴姝ヨ繘鍏ヤ簲琛屾剰璞?|
| `wuxing_imagery_page.dart` | 浜旇鎰忚薄璇︽儏椤碉細浜旇鐭ヨ瘑鎬诲崱 + 棰滆壊/浜斿懗/鑴忚厬/鏂逛綅/鍝佽川/鏁板瓧/鍥涘/鍦版敮浜旇鍒嗘澘鍧?|
| `wuxing_generate_page.dart` | 浜旇鐩哥敓锛堝崰浣嶏細鍗冲皢寮€鏀撅級 |
| `wuxing_control_page.dart` | 浜旇鐩稿厠瀛︿範椤碉細浜旇鏄熷浘銆佸叧绯昏В閲娿€佹柇鍗︽彁绀?|
| `wuxing_center_page.dart` | 浠ユ垜涓轰腑蹇冨涔犻〉锛氫簲琛岄€夋嫨 + 鍏崇郴鍥?+ 鏃虹浉浼戝洑姝?|
| `dizhi_study_page.dart` | 鍦版敮瀛︿範璇︽儏锛氬湴鏀僵鑹茬綉鏍笺€佷簲琛屽綊绫汇€佸湴鏀垎绫?|
| `relation_study_page.dart` | 鍏啿鍏悎瀛︿範璇︽儏锛氬啿鍚堝灞曠ず銆佽烦杞粌涔?|

### 5.12 lib/pages/practice/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `practice_page.dart` | 缁冧範椤靛叆鍙ｏ細鎸夊熀纭€/鍏崇郴/缁煎悎鍒嗙粍灞曠ず璁粌鍗＄墖 |
| `training_page.dart` | 璁粌椤碉細棰樼洰灞曠ず + 褰╄壊閫夐」 + 鍗虫椂鍙嶉 + 杩涘害鏉?|
| `result_page.dart` | 缁撴灉椤碉細姝ｇ‘鐜?+ 鍥炵倝/杩熺枒姹囨€?+ 閿欓鍒楄〃 + 缁х画鎿嶄綔 |
| `practice_setup_page.dart` | 缁煎悎缁冧範璁剧疆椤碉細閫夋嫨鏉垮潡 + 棰樻暟 + 缁冧範鏂瑰紡 |
| `practice_session_page.dart` | 閫氱敤缁冧範椤碉細璁℃椂 + 鍙嶉 + 鍥炵倝鍐欏叆 |
| `practice_result_page.dart` | 閫氱敤缁撴灉椤碉細鍒嗛」琛ㄧ幇 + 骞冲潎鍙嶅簲 + 杩熺枒缁熻 |
| `games/falling_block_game_page.dart` | 鏂瑰潡閫熺瓟娓告垙锛氬崟棰樹笅钀?+ 鐢熷懡/鍒嗘暟/杩炲嚮 + 鍥炵倝 |
| `games/link_match_game_page.dart` | 鍏崇郴杩炶繛鐪嬶細25缁勯厤瀵?+ 50寮犲崱鐗屾秷闄?+ 鍥炵倝 |

### 5.13 lib/pages/review/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `review_page.dart` | 鍥炵倝椤碉細閿欓鍒楄〃 + 鍗曢閲嶅仛 + 閲嶅仛鍏ㄩ儴閿欓 |
| `review_training_page.dart` | 鍥炵倝缁冧範椤碉細鏃犺壊鍗曢€夐噸鍋氾紝绛斿绉婚櫎绛旈敊淇濈暀 |

### 5.14 lib/widgets/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `wuxing_wheel.dart` | 浜旇杞洏缁勪欢锛氱疮璁＄澶村姩鐢汇€佽嚜鍔ㄥ惊鐜€佽妭鐐归珮浜€佷腑澶壒鏁?|
| `wuxing_arrow_painter.dart` | 鍦嗗姬绠ご CustomPainter锛氭部杞洏鍦嗗懆缁樺埗鐩哥敓寮х嚎 |
| `wuxing_control_wheel.dart` | 浜旇鐩稿厠杞洏锛氫簲瑙掓槦绱绠ご + 浜旀Ы浣嶇壒鏁堣嚜鎾?|
| `wuxing_control_arrow_painter.dart` | 浜旇鏄熺洿绾跨澶?CustomPainter锛氳法鑺傜偣绾㈣壊鍏嬪埗绾?|
| `wuxing_control_painter.dart` | 闈欐€佺浉鍏嬩簲瑙掓槦 CustomPainter |
| `wuxing_self_center_wheel.dart` | 浠ユ垜涓轰腑蹇冨渾鐩橈細涓績+鍥涘悜澶栧湀鑺傜偣 |
| `wuxing_self_center_painter.dart` | 鍥涘悜绠ご + 涓績鍙岀幆 CustomPainter |
| `effects/control/earth_water_control_html.dart` | 鍦熷厠姘?HTML/SVG 鍔ㄧ敾锛屽湡鍫ゆ潫姘?|
| `effects/control/fire_metal_control_html.dart` | 鐏厠閲?HTML/SVG 鍔ㄧ敾锛岀儓鐏啍閲?|
| `effects/control/metal_wood_control_html.dart` | 閲戝厠鏈?HTML/SVG 鍔ㄧ敾锛岄噾鍒冩柇鏈?|
| `effects/control/water_fire_control_html.dart` | 姘村厠鐏?HTML/SVG 鍔ㄧ敾锛屾按骞曞帇鐏?|
| `effects/control/wood_earth_control_html.dart` | 鏈ㄥ厠鍦?HTML/SVG 鍔ㄧ敾锛屾湪鏍圭牬鍦?|
| `effects/control/control_relation_effect.dart` | 鐩稿厠 HTML WebView 灏佽 |
| `effects/control/control_relation_effects_layer.dart` | 浜旂浉鍏嬫Ы浣嶅叧绯诲姩鐢诲眰 |
| `effects/earth_metal_html.dart` | 鍦熺敓閲?HTML/SVG 鍔ㄧ敾锛岄噾鐭崇牬鍦熻€屽嚭 |
| `effects/fire_earth_html.dart` | 鐏敓鍦?HTML/SVG 鍔ㄧ敾锛岀伆鐑帺鍩嬬伀鑻楀惊鐜?|
| `effects/generate_relation_effects_layer.dart` | 浜旀Ы浣嶅叧绯诲姩鐢诲眰锛氬浐瀹氬潗鏍囨覆鏌撳鏉″叧绯诲姩鐢?|
| `effects/html_relation_effect.dart` | WebView 灏佽缁勪欢锛孖gnorePointer 闃叉嫤鎴紝鏀寔鍏ㄩ儴浜旀潯鐩哥敓 |
| `effects/metal_water_html.dart` | 閲戠敓姘?HTML/SVG 鍔ㄧ敾锛屽瘨椋庡嚌姘寸彔婊磋惤 |
| `effects/water_wood_html.dart` | 姘寸敓鏈?HTML/SVG 鍔ㄧ敾锛屾槬闆ㄦ鼎鏈ㄥ彂鑺界箒鑼?|
| `effects/wood_fire_html.dart` | 鏈ㄧ敓鐏捇鏈ㄥ彇鐏?HTML/SVG 鍔ㄧ敾 |

### 5.15 test/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `widget_test.dart` | Widget 鍐掔儫娴嬭瘯锛氶椤垫纭覆鏌?|
| `foundation_test.dart` | App Shell 浜斿鑸?/ 鑹崷鍥炬爣 / 鐘舵€佷繚鎸?/ 鏇村鑿滃崟楠屾敹 |
| `presentation/casting/casting_page_test.dart` | 鎺掑崷宸ヤ綔鍙版祴璇曪紙Test A鈥揇 / 琛岄『搴?/ 鑽夌浠撳簱 / 绾€昏緫 / UI-01~03锛?|
| `presentation/review/review_page_test.dart` | 瀹″崷宸ヤ綔鍙版祴璇曪紙搂22 A鈥揌 / UI-04~08 / 閫傞厤鍣?/ 鍙屾暟鎹矾寰勶級 |
| `presentation/shared/yao_glyph_test.dart` | 鍏变韩鐖荤粍浠跺昂瀵稿喕缁撴祴璇曪紙24脳6 / 12脳12锛?|
| `domain/casting/hexagram_tables_test.dart` | R3 琛ㄤ笌瑙勫垯锛氬叓鍗?64 鍗﹀敮涓€鎬?鍏涓栧簲/绾崇敳/鍏翰/鍏 |
| `domain/casting/casting_engine_test.dart` | R3 寮曟搸锛氱粡鍏告帓鐩樺鐓э紙涔句负澶?鍧や负鍦?娉藉北鍜革級+ 鍔ㄥ彉 |
| `domain/calendar/ganzhi_day_test.dart` | R3-B 鏃ユ煴锛?3 涓法骞翠唬鍩哄噯锛堝弻鐙珛婧愭牎楠岋級 |
| `domain/calendar/xun_kong_test.dart` | R3-B 鏃┖锛氬叚鏃?+ 60 鏃ュ惊鐜?+ 鐙珛鎬ц川楠岃瘉 |
| `domain/calendar/day_boundary_test.dart` | R3-B 鏃ョ晫锛氫袱绉嶈鍒?脳 鍥涗釜鍏抽敭鏃跺埢 |
| `domain/calendar/month_branch_resolver_test.dart` | R3-B 鏈堝缓锛氬崄浜屻€岃妭銆嵜?涓夋椂鐐硅竟鐣?|
| `domain/calendar/calendar_data_pack_parser_test.dart` | R3-B 鏁版嵁鍖呰В鏋?|
| `domain/calendar/calendar_data_pack_validator_test.dart` | R3-B 鏁版嵁鍖呮牎楠岋紙鏁伴噺/鍞竴/鏃堕棿/鏉ユ簮/骞翠唤锛?|
| `domain/calendar/calendar_pack_import_test.dart` | R3-B 瀵煎叆鍘熷瓙鎬?Golden + 淇鍥涙€?|
| `domain/calendar/calendar_engine_test.dart` | R3-B 寮曟搸缁煎悎 Golden + 缂哄勾浠芥嫆缁?|
| `domain/calendar/offline_gate_test.dart` | R3-B 绂荤嚎闂ㄧ锛堟棤缃戠粶 / 鏃?Flutter / 鏃?DateTime.now锛?|
| `domain/calendar/calendar_pack_fixtures.dart` | R3-B 娴嬭瘯澶瑰叿锛堟瀯閫犳暟鎹寘 + 璇诲彇绉嶅瓙鍖咃級 |
| `domain/gate_b/gate_b_runner.dart` | R4-GATE-B 楠岃瘉娴嬭瘯 / Markdown 鎶ヨ〃鐢熸垚鍏ュ彛 |

### 5.16 gate-b/

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `README.md` | Gate B 楠岃瘉璇存槑 |
| `01-gb-01.md` | Gate B 鍗曞姩鐖绘祴璇曟姤鍛?|
| `02-gb-02.md` | Gate B 澶氬姩鐖绘祴璇曟姤鍛?|
| `03-gb-03.md` | Gate B 闈欑埢浜嬪疄娴嬭瘯鎶ュ憡 |
| `04-master-table.md` | 涔濈被鍏崇郴鏍稿鎬昏〃 |

---

## 6. 妯″潡渚濊禆鏂瑰悜

```text
theme/  data/  鈫? models/  鈫? services/  鈫? pages/  +  widgets/
                                                    鈫? shell/
```

渚濊禆绾︽潫锛?

1. `data/`銆乣theme/` 涓嶄緷璧栦换浣曚笂灞傛ā鍧椼€?
2. `models/` 涓嶄緷璧栦换浣曚笂灞傛ā鍧椼€?
3. `services/` 鍙互渚濊禆 `data/` 涓?`models/`锛屼絾涓嶈兘渚濊禆 Flutter Widget銆?
4. `pages/` 鍙互渚濊禆 `services/`銆乣models/`銆乣data/`銆乣theme/`銆?
5. `shell/` 鍙互渚濊禆鎵€鏈夐〉闈㈡ā鍧椼€?
6. `widgets/` 鍙緷璧?`models/`銆?
7. 绂佹寰幆渚濊禆銆?
8. 绂佹鍦ㄩ〉闈㈢粍浠朵腑鍐欏鏉備笟鍔￠€昏緫锛堝嚭棰樸€佽鍒嗐€侀敊棰樼鐞嗭級銆?

---

## 7. 褰撳墠鏋舵瀯鍘熷垯

### 7.1 鍒嗗眰鍘熷垯

```text
鏁版嵁瀹氫箟 鈫?涓婚绯荤粺 鈫?涓氬姟閫昏緫 鈫?鐘舵€佺鐞?鈫?UI 椤甸潰
```

| 灞傜骇 | 璇存槑 |
| --- | --- |
| 鏁版嵁瀹氫箟 | 浜旇鐢熷厠鏄犲皠銆佸湴鏀俊鎭€佸啿鍚堝叧绯?|
| 涓婚绯荤粺 | `WuxingColors` 棰滆壊浣撶郴 |
| 涓氬姟閫昏緫 | 鍑洪绠楁硶銆佽鏃跺垽瀹氥€侀敊棰樻敹褰?|
| 鐘舵€佺鐞?| `MistakeStore` 鍗曚緥绠＄悊閿欓鐘舵€?|
| UI 椤甸潰 | 鍥涙爮瀵艰埅 + 5 涓瓙椤甸潰鍖?|

### 7.2 褰撳墠涓嶅仛鐨勫唴瀹?

褰撳墠鐗堟湰鏆備笉寮€鍙戯細

- 鍦版敮鍦嗙洏鍙鍖栫粍浠讹紱
- 涓夊悎涓変細鏁版嵁涓庤缁冿紱
- 澶╁共鏁版嵁涓庤缁冿紱
- 绾抽煶浜旇锛?
- 鍏崄鍥涘崷锛?
- 缁熻鍥捐〃涓庡涔犳洸绾匡紱
- 澶氱敤鎴?澶氳澶囧悓姝ャ€?

---

## 8. 鐗堟湰鍘嗗彶

| 鐗堟湰 | 鏃ユ湡 | 绫诲瀷 | 璇存槑 |
| --- | --- | --- | --- |
| `v0.1.11` | 2026-09-14 | ?? | R5-B Rule Engine ?????????? 5+100 ?? |
| `v0.1.10` | 2026-05-22 | 鏂板 | 鍏崇郴杩炶繛鐪嬶細25缁勯厤瀵?50寮犲崱娑堥櫎+鍥炵倝 |
| `v0.1.9` | 2026-05-22 | 鏂板 | 鏂瑰潡閫熺瓟娓告垙妯℃澘锛屽崟棰樹笅钀?+ 璁℃椂 + 鍥炵倝 |
| `v0.1.8.3` | 2026-05-18 | 閲嶆瀯 | 鏃у叆鍙ｈ縼绉诲埌閫氱敤缁冧範妗嗘灦锛岀粡鍏告寜閽浠?|
| `v0.1.7.2` | 2026-05-18 | 浼樺寲 | 鍦嗙洏鎺掔増绮句慨锛岀澶撮伩璁╋紝鑳跺泭鑺傜偣 |
| `v0.1.7.1` | 2026-05-18 | 閲嶆瀯 | 浠ユ垜涓轰腑蹇冨崌绾у渾鐩樼粨鏋勶紝鍥涜壊绠ご |
| `v0.1.7` | 2026-05-18 | 鏂板 | 浠ユ垜涓轰腑蹇冨涔犻〉锛屾椇鐩镐紤鍥氭 |
| `v0.1.6.2` | 2026-05-18 | 浼樺寲 | 杞洏灏哄绋冲畾锛岀粨鏋滈〉涓夐樁娈电粺璁★紝鍥炵倝鏉ユ簮鏍囩 |
| `v0.1.6.1` | 2026-05-16 | 淇 | 绛旈鍓嶉殣钘忔彁绀猴紝绛旈鍚庢樉绀虹壒鏁?|
| `v0.1.5` | 2026-05-16 | 鏂板 | 浜旇鐩稿厠瀛︿範椤碉紝wrongCount 淇锛屽洖鐐夊脊绐楋紝闃舵鏍囩 |
| `v0.1.4.2` | 2026-05-16 | 淇 | 閲戝厓绱犵伆鑹叉枃瀛楋紝绛旈鍙嶉鑹查€氱敤鍖?|
| `v0.1.4.1` | 2026-05-16 | 鏂板 | 鍥炵倝閿欓閲嶅仛绯荤粺锛屾寔涔呭寲瀛樺偍 |
| `v0.1.4` | 2026-05-16 | 鏂板 | 鐩哥敓缁冧範涓夐樁娈碉細杞洏鈫掑僵鑹插崟閫夆啋鏃犺壊鍗曢€?|
| `v0.1.3.13` | 2026-05-16 | 浼樺寲 | 绠ご 3500ms 瀵归綈 5s 鐗规晥锛屼竴杞?25 绉?|
| `v0.1.3.12` | 2026-05-16 | 浼樺寲 | 绠ご 1800ms銆佺伀鐢熷湡绾?CSS 鐗堜慨澶?viewBox |
| `v0.1.3.11` | 2026-05-16 | 鏂板 | 鍏ㄩ儴浜旀潯鐩哥敓 HTML 鍔ㄧ敾鎺ュ叆锛岃疆鐩樿繕鍘熸參閫?|
| `v0.1.3.10` | 2026-05-16 | 浼樺寲 | 杞洏鍔犻€熻嚦 5 绉掍竴杞?|
| `v0.1.3.9` | 2026-05-16 | 鍙樻洿 | 鏈ㄧ敓鐏浛鎹负閽绘湪鍙栫伀鍔ㄧ敾 |
| `v0.1.3.8` | 2026-05-16 | 鏂板 | 鐏敓鍦?HTML 鍔ㄧ敾锛孒tmlRelationEffect 娉涘寲 |

### 5.3.4 lib/domain/dsl/ (R5-C FAST-TRACK DSL 解析)

| 文件 | 职责 |
| --- | --- |
| dsl_models.dart | DSL 核心数据结构 (ParsedGuayan, DslLine) |
| dsl_diagnostics.dart | 异常及行列位置提示模型 |
| dsl_nayin_map.dart | 纳音中文字符到 Stable ID 映射表 |
| dsl_parser.dart | 卦言语法主解析器入口 |
| dsl_formatter.dart | 卦言语法反向格式化器 |
| parser/dsl_action_parser.dart | 动作解析器 (支持得、取象、成局、记) |
| parser/dsl_expr_parser.dart | 条件表达式解析器 (支持13种算子与逻辑嵌套) |

### 5.17 test/domain/dsl/ (R5-C FAST-TRACK)

| 文件 | 职责 |
| --- | --- |
| dsl_smoke_test.dart | C1 阶段 3 项语法树构造验证 |
| dsl_round_trip_test.dart | C2 阶段 Parser/Formatter 幂等性与信息守恒验证 |
| dsl_engine_integration_test.dart | C2 阶段 DSL 到 R5-B RuleEngine 执行能力验证 |

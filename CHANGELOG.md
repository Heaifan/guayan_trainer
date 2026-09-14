# 鍗︾溂璁粌鍣?鈥?鏂囦欢瀹¤涓庡彉鏇存棩蹇?

> **浠撳簱锛?* https://github.com/Heaifan/guayan_trainer.git
> **褰掓。鍒嗘敮锛?* `feat/guayan-2.0`
> **鏈€杩戞寮忓彂甯冿細** v0.1.10锛?026-05-22锛?
> **鏈枃浠跺垱寤猴細** 2026-08-27
> **瀹屾暣鏂囦欢鏍戜笌鍘嗗彶锛?* 瑙?[file-tree.md](file-tree.md)

---

## 2026-09-14 路 R5-A-GATE-FIX1 (Rule Schema + AST + Core Domain)

> **寤虹珛鍗︾溂鍙紪绋嬪叚鐖昏鍒欏紩鎿庝互鍚庢墍鏈夋ā鍧楀叡鍚屼緷璧栫殑 Canonical Domain Contract銆?*

* **AST 涓庤鍒欏绾?*锛氫弗鏍艰鑼冨寲 `RuleDefinition` 涓庡熀浜庢爲褰㈢粨鐨勬娊璞¤娉曟爲锛坄ALL`/`ANY`/`NOT`/`PREDICATE`锛夛紝娑堥櫎鍙墽琛岃剼鏈緷璧栥€?
* **寮轰笉鍙彉浜嬪疄鐜**锛氬埄鐢?`FactSnapshot` 瀵硅鍒欒緭鍏ヤ簨瀹炲己鍒堕攣瀹氾紝闃茶寖浠绘剰瑙勫垯瀵瑰簳灞傜姸鎬佸拰鎺掔洏瀵硅薄鐨勭鏀广€?
* **RulePack 濂戠害涓庡垎绫?*锛氬皢绯荤粺/鑷畾涔夛紙`RuleOrigin`锛変笌閫氱敤/涓婚浣滅敤鍩燂紙`RulePackScope`锛夎繘琛屼弗鏍间簩缁村害鍓ョ闄愬埗銆?
* **Canonical JSON涓庨獙璇佷綋绯?*锛氱‘淇濅簡瀵瑰鍏ヨ鍒欏己纭畾鎬х殑缂栬В鐮侀€昏緫鍜?Fail Closed 鐨勫畨鍏ㄩ獙璇佷綋绯伙紱骞跺缓绔嬪苟瀹炴柦浜嗗熀浜庡弬鏁板瓧鍏搁噸鎺掑簭鐨?`EvidenceIdentity`銆?

---

## 2026-09-12 路 GATE-A-FINAL-CLOSEOUT锛圙ate A 瀹氫箟鎷嗗垎涓?R3 鏀跺彛锛屾湭鍙戝竷锛?

### 涓轰粈涔堣鎷?Gate A

Gate A 鍘熸枃鎶娿€屾煇涓撲笟杞欢鐨勪汉宸ュ～鍐欑粨鏋溿€嶈涓?*鍞竴鐪熷€兼潵婧?*锛?
浜庢槸 R3 琚竴浠舵湰璐ㄤ笂鏄€屽吋瀹规€ц瀵熴€嶇殑浜嬪崱浣忋€備絾缁忚繃 R3-A / R3-B /
鍙屾簮鏍搁獙 / 绉掔骇绮惧害淇涔嬪悗锛屾牳蹇冪湡鍊煎凡鐢?*鍙鏍哥殑鐙珛璇佹嵁**鎵挎媴锛?

```text
鐙珛瑙勫垯鏍搁獙锛堝叓瀹?/ 涓栧簲 / 绾崇敳 / 鍏翰 / 鍏锛?
+ 瀹樻柟鍘嗘硶鍙屾簮锛圚KO vs NAOJ 24/24锛?
+ 绉掔骇鍏紑鐪熷€硷紙2026 绔嬫槬 04:02:08锛?
+ 杈圭晫 Golden Test
+ 259 / 259 鑷姩娴嬭瘯
```

鑰岀洰鏍囦笓涓氳蒋浠朵箣闂村瓨鍦ㄦ祦娲惧樊寮傦紙23:00 / 00:00 鏃ョ晫銆佹櫄瀛愭椂 / 鏃╁瓙鏃躲€?
鍏朵粬閰嶇疆锛夛紝杩欑被宸紓灞炰簬**鍏煎鎬?/ 閰嶇疆宸紓**锛屼笉鑳借嚜鍔ㄨ涓烘牳蹇冪畻娉曢敊璇€?

### 姝ｅ紡鎷嗗垎

```text
Gate A-Truth   CORE DIVINATION TRUTH                鈥斺€?R3 鐨?blocker
Gate A-Compat  PROFESSIONAL SOFTWARE COMPATIBILITY  鈥斺€?涓嶉樆濉?R3
```

| 鏂?Gate | 鐘舵€?| 渚濇嵁 |
| --- | --- | --- |
| Gate A-Truth | **PASS** | 鐙珛瑙勫垯鏍搁獙 + 瀹樻柟鍙屾簮 + 绉掔骇鐪熷€?+ 杈圭晫娴嬭瘯 + 259/259 |
| Gate A-Compat | **NOT EXECUTED / DEFERRED锛孨ON-BLOCKING** | 灏氭湭瀵圭洰鏍囦笓涓氳蒋浠堕€愰」浜哄伐姣斿 |

### Gate A-Truth 閫愰」

```text
鍏                  PASS
涓栧簲                  PASS
绾崇敳                  PASS
浜旇                  PASS
鍏翰                  PASS
鍙樺崷鍏翰鍙栨湰鍗﹀      PASS
鍏                  PASS
鏃ヨ景                  PASS
鏃┖                  PASS
鏈堝缓                  PASS
鑺傛皵鏁版嵁锛堝弻婧愶級      PASS
鑺傛皵绉掔骇绮惧害          PARTIALLY VERIFIED
鏃跺尯鎹㈢畻              PASS
鏃ョ晫鍙岃鍒?           PASS
绂荤嚎璁＄畻              PASS
```

### 绮惧害鐘舵€侊紙姝ｅ紡鎺緸锛?

```text
SOLAR TERM DATA PRECISION

2026 LiChun:          SECOND-LEVEL VERIFIED   04:02:08 +08:00
KNOWN PRECISION GAP:  FIXED
Other solar terms:    MINUTE-LEVEL VERIFIED (via HKO + NAOJ)
No fabricated second-level values

鈫?PARTIALLY SECOND-LEVEL VERIFIED
```

涓嶅啀鍐?`UNRESOLVED`锛涗篃绂佹鍐?`ALL SOLAR TERMS SECOND-LEVEL VERIFIED`銆?

### 鏃ョ晫鐘舵€?

```text
DAY BOUNDARY ENGINE      PASS锛坢idnight 涓?ziHourStart 鍧囧凡瀹炵幇骞堕€氳繃娴嬭瘯锛?
PRODUCT DEFAULT POLICY   OPEN锛堝睘鍚庣画浜у搧閰嶇疆鍐冲畾锛屼笉闃诲 R3 Domain Foundation锛?
```

### 鏂囨。鏀瑰姩锛堟敼 generator 鐪熸簮锛岄潪鎵嬫敼浜х墿锛?

| 鏂囦欢 | 鏀瑰姩 |
| --- | --- |
| `tool/gate_a/gate_a_gate_status.dart` | 鏂板锛氬弻 Gate 瀹氫箟銆丟ate A-Truth 閫愰」琛ㄣ€丷3 鏈€缁堢姸鎬佸潡 |
| `tool/gate_a/gate_a_main.dart` | README 澶存敼涓哄弻 Gate 缁撴瀯锛涙€昏〃鎷嗗嚭 `Truth Result` / `Compatibility Result`锛涗娇鐢ㄨ鏄庢敼涓?Gate A-Compat 涓撶敤 |
| `tool/gate_a/gate_a_cross_source.dart` | 娉ㄩ噴褰掑睘鏀逛负 Gate A-Truth |
| `tool/gate_a/gate_a_solar_term_report.dart` | 娉ㄩ噴鏀逛负 `PARTIALLY SECOND-LEVEL VERIFIED`锛堝師鍐?UNRESOLVED锛?|
| `gate-a/*.md` | 鍏ㄩ儴閲嶆柊鐢熸垚 |

淇濈暀锛氫笓涓氳蒋浠跺垪 / 杞欢鐗堟湰 / 涓€鑷?绛夊瓧娈碉紙渚?Gate A-Compat 浣跨敤锛夛紱
鏈～鍐欐椂 Result 璁?`NOT EXECUTED`锛?*涓嶅緱鏄剧ず FAIL**銆?

### R3 鏈€缁堢姸鎬?

```text
R3-A                        PASS
R3-B                        PASS
R3-B-DATA-PRECISION-FIX     PASS
GATE A-TRUTH                PASS
GATE A-COMPAT               NOT EXECUTED / DEFERRED 鈥?NON-BLOCKING
R3                          FINAL ACCEPTED
```

### 楠岃瘉

```text
gate_a_runner.ps1 test       鍏ㄩ儴鑷 PASS
gate_a_runner.ps1 closeout   楠屾敹鏂█鍏ㄩ儴 PASS
flutter test                 259 / 259 PASS
flutter analyze lib/domain test/domain   No issues found
flutter analyze锛堝叏浠擄級       27 = 鍩虹嚎锛孨EW = 0
git diff --check             clean
lib/ test/ assets/ diff      = 0
```

---

## 2026-09-12 路 R3-B-DATA-PRECISION-FIX锛堣妭姘旀暟鎹簿搴︿笓椤逛慨澶嶏紝鏈彂甯冿級

> **鏍瑰洜锛堜竴鍙ヨ瘽锛?*锛氬垎閽熺骇瀹樻柟鏄剧ず鍊艰淇濆瓨涓?`:00` 绉?Instant锛?
> 鑰岃鍒嗛挓鍐呭瓨鍦ㄥ彲楠岃瘉鐨勭湡瀹炵绾т氦鑺傛椂鍒?鈥斺€?
> **鍒嗛挓绾ф暟鎹笉瓒充互琛ㄨ揪璇ョ绾ц竟鐣?*銆?
> 杩欎笉鏄€孒KO 閿欎簡銆嶏紝瀹樻柟鍙屾簮锛圚KO / NAOJ锛?4/24 鍒嗛挓绾т竴鑷淬€?

### 淇
| 椤?| 淇鍓?| 淇鍚?|
| --- | --- | --- |
| 2026 绔嬫槬 UTC 鐬棿 | `2026-02-03T20:02:00Z` | `2026-02-03T20:02:08Z` |
| 鏈堝缓鍒囨崲鏃跺埢锛?08:00锛?| 04:02:00锛堟彁鍓?8 绉掞級 | 04:02:08 |
| 04:02:00鈥?4:02:07 鍖洪棿鏈堝缓 | 瀵咃紙閿欙級 | 涓戯紙瀵癸級 |
| 璁板綍绮惧害 | 鏃犺姒傚康 | `precision = second` |
| 鏉ユ簮褰掑睘 | 浠呭勾搴?HKO | + 閫愯妭姘?`sourceOverride`锛堢传閲戝北澶╂枃鍙扮鏅儴锛?|

### 鏂板锛氭暟鎹寘娣峰悎绮惧害濂戠害锛坰chemaVersion 2锛屽悜鍚庡吋瀹?v1锛?
```text
骞村害 source          = 榛樿鏉ユ簮
term sourceOverride  = 鍙€夎鐩栵紙椤诲惈 name + reference锛?
term precision       = minute锛堢己鐪侊級 / second
```
- 鍐荤粨璇箟锛歚precision = minute` 鏃?`instantUtc` 绉掍綅鎭掍负 `:00`锛?
  鍙〃绀恒€?*璇ュ垎閽熷唴**浜よ妭銆嶏紝**涓?*琛ㄧず銆屾伆鍦ㄧ 0 绉掍氦鑺傘€嶏紱
- v2 涓害鍙贩鍚堢簿搴︼細**宸茬煡澶氬皯绮惧害灏辫瘹瀹炰繚瀛樺灏戠簿搴?*锛?
- 鏈煡 `precision`銆佹畫缂?`sourceOverride` 涓€寰嬫嫆缁濆鍏ワ紙涓嶇寽榛樿鍊硷級銆?

### 鏁版嵁鍖呭彉鏇磋寖鍥达紙涓ユ牸鏈€灏忥級
- 浠?`assets/calendar/2026.calendar.json`锛歚schemaVersion 1鈫?`銆乣revision 1鈫?`銆?
  绔嬫槬鍗曟潯鏀逛负绉掔骇骞堕檮鏉ユ簮瑕嗙洊锛?
- **鍏朵綑 23 鏉¤妭姘斾笌鍏朵綑 9 涓勾浠芥暟鎹寘涓€寰嬩笉鍔?* 鈥斺€?
  鏈彇寰楀彲淇＄绾х湡鍊肩殑鑺傛皵**涓嶈ˉ绉掋€佷笉鎻掑€笺€佷笉浼扮畻**銆?

### 鏂板鏂囦欢
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `lib/domain/calendar/import/calendar_data_pack_term_source.dart` | 閫愯妭姘旀潵婧愯鐩栨牎楠?|
| `test/domain/calendar/solar_term_second_boundary_test.dart` | 绔嬫槬绉掔骇杈圭晫 Golden Test锛?1 渚嬶級 |
| `test/domain/calendar/calendar_terms_precision_test.dart` | 绮惧害 / 鏉ユ簮鍏冩暟鎹牎楠岋紙11 渚嬶級 |
| `test/domain/calendar/solar_term_precision_revision_test.dart` | 绮惧害淇瀵煎叆鍥炲綊锛? 渚嬶級 |
| `tool/gate_a/gate_a_precision_closeout.dart` | 楠屾敹鏂█锛堣蛋鐪熷疄浜у搧閾捐矾锛?|
| `tool/gate_a/gate_a_hko_source.dart` | HKO 瀹樻柟 XML 瑙ｆ瀽锛堜氦鍙夋牳楠岀敤鍘熷鍙戝竷浠讹級 |

### 淇敼鏂囦欢
| 鏂囦欢 | 鏀瑰姩 |
| --- | --- |
| `solar_term/solar_term.dart` | 澧炲姞 `precision` / `sourceName` / `sourceReference` |
| `import/calendar_data_pack.dart` | 澧炲姞 `TermPrecision` 鏋氫妇涓庨€愯妭姘斿彲閫夊瓧娈?|
| `import/calendar_data_pack_parser.dart` | 瑙ｆ瀽 `precision` / `sourceOverride` |
| `import/calendar_data_pack_terms.dart` | 绮惧害鏍￠獙锛堢己鐪?minute銆佹湭鐭?绫诲瀷閿欒鎷掔粷锛?|
| `import/calendar_data_pack_validator.dart` | 鏀寔 `schemaVersion 1..2` |
| `test/domain/calendar/calendar_engine_test.dart` | 鍘熸柇瑷€銆?4:02:00 鍗冲瘏鏈堛€嶅凡闅忔暟鎹慨姝ｆ洿鏂?|

### NOT changed锛堝喕缁撹寖鍥达紝diff = 0锛?
```text
MonthBranchResolver / CalendarEngine / GanzhiDay / XunKong
CastingEngine / 鍏 / 绾崇敳 / 鍏翰 / 涓栧簲 / 鍏 / UI
鑷缓 Meeus 灏哄瓙锛氫繚鎸?DIAGNOSTIC ONLY / REJECTED AS GATE ORACLE
```

### 楠屾敹鏂█锛圕alendarEngine 瀹為檯鎵ц锛?
```text
2026-02-04 04:01:00 +08 鈫?涓?
2026-02-04 04:02:00 +08 鈫?涓?  锛堜慨澶嶇偣锛?
2026-02-04 04:02:07 +08 鈫?涓?
2026-02-04 04:02:08 +08 鈫?瀵?  锛堜氦鑺傜灛闂达紝鍚級
2026-02-04 04:02:09 +08 鈫?瀵?
2026-02-04 04:03:00 +08 鈫?瀵?
```

### Gate 鐘舵€?
```text
Gate A1  WAITING FOR USER MANUAL INPUT
Gate A2  PARTIALLY VERIFIED
         2026 LiChun = 04:02:08 +08:00锛涜鐐?precision gap FIXED
         鍏朵綑 2026 鑺傛皵 minute-level only锛堟棤浼€犵绾х湡鍊硷級
Gate A   READY FOR FINAL CLOSEOUT
```

### 楠岃瘉
```text
flutter test                       259 / 259 PASS锛堝師 232 + 鏂?27锛?
flutter analyze lib/domain test/domain   No issues found
flutter analyze锛堝叏浠擄級             27 issue = 鏀瑰姩鍓嶅熀绾匡紝new = 0锛宺emoved = 0
```

---

## 2026-09-11 路 GUAYAN-2.0-R3-B-CALENDAR锛堢绾垮巻娉曞熀纭€灞傦紝鏈彂甯冿級

> **璺嚎鍙樻洿锛堥噸瑕侊級**锛氬師鏂规銆屾妸 1900鈥?100 鍏?4824 鏉¤妭姘旂‖缂栫爜杩?Dart 婧愮爜銆?
> 宸插簾寮冿紝鏀逛负 **骞村害鏁版嵁鍖?+ 鏈湴浠撳偍 + 瀹屽叏绂荤嚎璁＄畻**锛?
>
> ```text
> 绠楁硶灞炰簬绋嬪簭锛岃妭姘斿睘浜庡彲楠岃瘉鏁版嵁銆?
> 鍘嗘硶鏁版嵁鍙互閫愬勾澧炲姞锛屼笉瑕佹眰閲嶆柊缂栬瘧 APP銆?
> 宸插鍏ュ勾浠藉畬鍏ㄧ绾挎帓鐩橈紱鏈鍏ュ勾浠芥槑纭嫆缁濇湀寤鸿绠椼€?
> 姘歌繙涓嶆嬁杩戜技缁撴灉鍐掑厖绮剧‘缁撴灉銆?
> ```
>
> 绾?Dart 棰嗗煙灞傦紝闆?Flutter 渚濊禆銆侀浂杩愯鏃剁綉缁溿€侀浂澶╂枃搴撱€侀浂杩戜技 fallback銆?

### 鏂板锛坙ib/domain/calendar/ 鈥?鍘嗘硶鍩燂級
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `calendar_request.dart` | 杈撳叆濂戠害锛歭ocalDateTime + utcOffset + dayBoundaryRule锛屾樉寮忎紶鍏?|
| `calendar_context.dart` | 杈撳嚭濂戠害锛歩nstantUtc / monthBranch / day / xunKong |
| `calendar_engine.dart` | 鑱氬悎鏈堝缓 + 鏃ヨ景 + 鏃┖ |
| `calendar_error.dart` | 绫诲瀷鍖栧け璐ワ紙娌跨敤椤圭洰銆屾姏寮傚父銆嶆棦鏈変綋绯伙紝涓嶅彟绔?Result锛?|
| `day_boundary_rule.dart` | `midnight` / `ziHourStart`锛?*鏃犻殣寮忛粯璁ゅ€?* |
| `day/ganzhi_day.dart` | 鏃ユ煴锛欽DN 鈫?鍏崄鐢插瓙锛堥敋鐐?1949-10-01 鐢插瓙鏃ワ級 |
| `day/xun_kong.dart` | 鏃┖锛氱敱鏃鎺ㄥ锛屼笉缁存姢鎵嬫妱琛?|
| `solar_term/solar_term_id.dart` | 浜屽崄鍥涜妭姘?+ 澶槼榛勭粡 + 鑺?姘斿尯鍒?|
| `solar_term/solar_term.dart` | 鑺傛皵璁板綍锛堢湡婧愭槸**鐬棿**锛屼笉鏄棩鏈燂級 |
| `solar_term/solar_term_provider.dart` | 鏁版嵁鏉ユ簮鎶借薄锛堝彲鏇挎崲杈圭晫锛?|
| `solar_term/calendar_year_data.dart` | 宸叉牎楠岀殑鍗曞勾鏁版嵁 |
| `solar_term/month_branch_resolver.dart` | 鏈堝缓锛氬崄浜屻€岃妭銆嶅尯闂村垽鏂?|
| `import/calendar_data_pack.dart` | 鏁版嵁鍖呭師濮嬪舰鎬?|
| `import/calendar_data_pack_parser.dart` | JSON 鈫?鏁版嵁鍖咃紙鍙璇硶缁撴瀯锛?|
| `import/calendar_data_pack_terms.dart` | 鑺傛皵鍒楄〃瑙勫垯锛堟暟閲?鍞竴/閫掑/骞翠唤鍚堢悊鎬э級 |
| `import/calendar_data_pack_validator.dart` | 鍏冩暟鎹牎楠?+ 姹囨€诲け璐ュ師鍥?|
| `import/calendar_data_pack_importer.dart` | 瑙ｆ瀽 鈫?鏍￠獙 鈫?淇鍒ゅ畾 鈫?**鍘熷瓙鎻愪氦** |
| `store/calendar_data_store.dart` | 鏈湴浠撳偍杈圭晫 + 鍐呭瓨瀹炵幇 |
| `store/stored_solar_term_provider.dart` | 浠撳偍 鈫?Provider锛堝紓姝ヨ杞藉揩鐓э紝寮曟搸淇濇寔鍚屾锛?|

### 鏂板锛坙ib/services 涔嬪鐨勬湰杞骇鐗╋級
- `assets/calendar/2019..2028.calendar.json` 鈥?**绉嶅瓙鏁版嵁鍖?10 骞?*锛?63 琛岀骇鍒紝
  涓庣敤鎴峰鍏ヤ娇鐢?*瀹屽叏鐩稿悓鐨勬牸寮?*锛屼笉瀛樺湪銆屽唴缃蛋 Dart 甯搁噺銆嶇殑绗簩濂椾綋绯伙級
- `tool/calendar_pack_gen/generate_calendar_packs.dart` 鈥?寮€鍙戦樁娈电敓鎴愬櫒
  锛?*涓嶅弬涓?App 杩愯鏃?*锛?

### 鍏抽敭濂戠害
- **鏈堝缓杈圭晫**锛歚instant < 浜よ妭 鈫?鏃ф湀寤篳锛沗instant >= 浜よ妭 鈫?鏂版湀寤篳锛?
  宸插仛銆屼氦鑺傚墠 1 绉?/ 浜よ妭鏃跺埢 / 浜よ妭鍚?1 绉掋€嶄笁鎬佹柇瑷€锛?
- **缂哄皯骞翠唤**锛氭姏 `CalendarDataMissing`锛?*绂佹杩戜技琛ョ畻**锛?
- **瀵煎叆鍘熷瓙鎬?*锛氭牎楠屽叏閮ㄩ€氳繃鍓嶇粷涓嶅啓浠撳偍锛屼笉瀛樺湪銆屽浜嗕竴鍗娿€嶇殑涓棿鎬侊紱
- **淇瑙勫垯**锛歂EW / UPDATE / SAME / DOWNGRADE 鍥涙€侊紝闄嶇骇瀵煎叆琚嫆缁濅笖鏃ф暟鎹笉鍙橈紱
- **鏃ョ晫**锛氫粨搴撴棦鏈変唬鐮佹湭鍐荤粨瑙勫垯锛屾晠鏍稿績灞傚悓鏃跺疄鐜颁袱绉嶅苟瑕佹眰鏄惧紡浼犲叆锛?
  鏈€缁堥噰鐢ㄥ摢涓€绉嶇暀缁欎笟鍔″眰鍐冲畾銆?

### 鏁版嵁鏉ユ簮锛堝彲澶嶆牳锛?
- 鏉ユ簮锛?*棣欐腐澶╂枃鍙?HKO**銆屼簩鍗佸洓绡€姘ｇ殑鏃ユ湡鍙婃檪闁撹硣鏂欍€嶏紱
  HKO 娉ㄦ槑鍏跺ぉ鏂囨暟鎹潵鑷嫳鍥?**HM Nautical Almanac Office** 涓?
  缇庡浗 **United States Naval Observatory**锛?
- 绔偣锛歚https://www.hko.gov.hk/en/gts/astronomy/data/files/24SolarTerms_<YEAR>.xml`锛?
- 鍘熷鏃堕棿鍩哄噯 HKT锛圲TC+8锛夛紝鐢熸垚鏃剁粺涓€鎶樼畻涓?**UTC**锛?
- **绮惧害濡傚疄璁板綍锛氭潵婧愪负鍒嗛挓绾э紝鏁呯浣嶆亽涓?`:00`**锛屼笉铏氭瀯绉掔骇绮惧害锛?
- 瑕嗙洊骞翠唤 2019鈥?028锛圚KO 鍏紑鑼冨洿锛夛紱
- 浜ゅ弶楠岃瘉锛欻KO 涓庢棩鏈浗绔嬪ぉ鏂囧彴 NAOJ 鍦ㄩ噸鍙犲勾浠介€愰」涓€鑷?
  锛堜緥锛?026 灏忓瘨 HKO 16:23 HKT = NAOJ 17:23 JST = 08:23 UTC锛夈€?

### 娴嬭瘯锛?103锛屽叡 232/232 閫氳繃锛?
| 娴嬭瘯 | 瑕嗙洊 |
| --- | --- |
| `ganzhi_day_test.dart` | T1 鏃ユ煴锛?*13 涓法骞翠唬鍩哄噯**锛?900鈥?023锛屽惈闂版棩 2020-02-29锛夛紝鍙岀嫭绔嬫簮鏍￠獙 |
| `xun_kong_test.dart` | T2 鏃┖锛氬叚鏃喕缁撳€?+ 瀹屾暣 60 鏃ュ惊鐜?+ **鐙珛鎬ц川楠岃瘉**锛堢┖浜?= 鏃唴鏈鐩栦簩鏀級 |
| `calendar_data_pack_parser_test.dart` | T3 瑙ｆ瀽锛氬悎娉?/ 璇硶閿?/ 鏍归潪瀵硅薄 / terms 闈炴暟缁?/ 鍏冪礌闈炲璞?|
| `calendar_data_pack_validator_test.dart` | T4 鏍￠獙锛?4-23-25 鏉?/ 閲嶅 / 鏈煡 / 鍊掑簭 / 闈炰弗鏍奸€掑 / 闈炴硶 UTC / 闈?Z / 鍏冩暟鎹己澶?/ 骞翠唤閿欎綅 / 璺ㄥ勾杈圭晫涓嶈鏉€ |
| `calendar_pack_import_test.dart` | T5 **瀵煎叆鍘熷瓙鎬?Golden**锛圛NVALID 瀵煎叆鍚庢棫鏁版嵁閫愬瓧娈典笉鍙橈級+ T6 淇鍥涙€?|
| `month_branch_resolver_test.dart` | T7 鍗佷簩銆岃妭銆嵜?3 鏃剁偣杈圭晫 + 璺ㄥ叕鍘嗗勾 + 銆屾皵銆嶄笉鍒囨崲鏈堝缓 |
| `calendar_engine_test.dart` | T8 缂哄皯骞翠唤鎷掔粷 + T9 寮曟搸缁煎悎 Golden锛堢湡瀹炴暟鎹寘鍏ㄩ摼璺級 |
| `day_boundary_test.dart` | 鏃ョ晫涓よ鍒?脳 22:59:59 / 23:00:00 / 23:59:59 / 00:00:00 + 璺ㄦ湀璺ㄥ勾闂版棩 |
| `offline_gate_test.dart` | 搂26 绂荤嚎闂ㄧ锛氭棤缃戠粶渚濊禆銆佹棤 Flutter 渚濊禆銆佹棤 `DateTime.now` |

### 楠岃瘉
- `flutter test` 鈫?**232/232 閫氳繃**锛堝熀绾?129锛岄浂鍥炲綊锛夛紱
- `flutter analyze --no-pub lib/domain test/domain` 鈫?**0 issue**锛?
- `dart format --output=none --set-exit-if-changed`锛圧3-B 鏂囦欢锛夆啋 **0 changed**锛?
- 5+100 闂ㄧ锛歚lib/domain/calendar/` 鍏ㄩ儴鏂囦欢 **鈮?99 琛?*锛屾瘡鐩綍 鈮?5 鏂囦欢锛?
- `git diff --check` 鈫?clean銆?

### 鏈仛锛堟槑纭竟鐣岋級
- 鍘嗘硶绠＄悊 UI / 瀵煎叆鎸夐挳 / 鏂囦欢閫夋嫨鍣?/ 瑕嗙洊纭寮圭獥锛堝睘鍚庣画 UI 灞傦級锛?
- 瀹屾暣澶╂枃绠楁硶锛堜粎淇濈暀 `SolarTermProvider` 鍙浛鎹㈣竟鐣岋紝鏈疄鐜?`Astronomical*`锛夛紱
- 鏃鸿“ / 鏈堢牬 / 鏃ュ啿 / 绁炵厼 / 鍥涙煴瀹屾暣绯荤粺 鈥斺€?鍧囦笉鍦ㄦ湰杞€?

---

## 2026-09-11 路 GUAYAN-2.0-R3-ENGINE-A锛堟帓鐩樺紩鎿?路 鍗︿綋灞傦紝鏈彂甯冿級

> R3 绗竴闃舵锛氭妸銆屾帓鐩樸€嶄粠婕旂ず妗ｆ鍙樻垚**鐪熷疄璁＄畻**銆傜函 Dart 棰嗗煙灞傦紝
> 闆?Flutter 渚濊禆 鈥斺€?Widget 涓€寰嬩笉寰楄嚜琛屾帓鍗︼紙鎬昏鍒?搂10锛夈€?
> 鏈疆瑕嗙洊 R3 娓呭崟 12 椤逛腑鐨?9 椤癸紙鍗︿綋灞傦級锛?
> 鍥涙煴 / 鏈堝缓 / 鏃ヨ景 / 鏃┖闇€骞叉敮鍘嗘硶锛岀暀寰?R3-B銆?

### 鏂板锛坙ib/domain/ 鈥?鍩虹鍧愭爣锛?
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `wu_xing.dart` | 浜旇 + 鐢熷厠锛沗relationTo(self)` 涓哄叚浜插垽瀹氬敮涓€鍏ュ彛 |
| `di_zhi.dart` | 鍗佷簩鍦版敮锛氫簲琛?/ 闃撮槼 / 鍏啿 / 鍏悎 |
| `tian_gan.dart` | 鍗佸ぉ骞诧細浜旇 / 闃撮槼 / 鍏崄鐢插瓙鍙栧共 |

### 鏂板锛坙ib/domain/casting/ 鈥?鎺掔洏寮曟搸锛?
| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| `bagua.dart` | 鍏崷锛堜笁鐖昏嚜涓嬭€屼笂锛? 鍗︾ + 浜旇 + 鍏堝ぉ搴?|
| `najia.dart` | 绾崇敳琛紙骞叉敮锛夛細涔剧撼鐢插，銆佸潳绾充箼鐧革紱鍐呭鍗﹀垎鍒鍗?|
| `palace.dart` | 浜埧鍏鍗﹀簭 + 涓栧簲锛?*绠楁硶鐢熸垚锛岄潪纭紪鐮?64 鏉?*锛?|
| `hexagram_names.dart` | 鍏崄鍥涘崷鍚嶈〃锛堜笂鍗?脳 涓嬪崷锛?|
| `hexagram64.dart` | 鍏埢闃撮槼 鈫?鍗﹀悕 / 瀹綅 / 涓栧簲 |
| `six_relative.dart` | 鍏翰锛堜互瀹綅浜旇涓恒€屾垜銆嶏級 |
| `six_spirit.dart` | 鍏锛堟寜鏃ュ共璧蜂緥锛岃嚜鍒濈埢鍚戜笂椤烘帓锛?|
| `cast_chart.dart` | 鎺掔洏缁撴灉妯″瀷锛圕astLine / CastChart锛?|
| `casting_engine.dart` | 寮曟搸缁勮锛氭湰鍗?/ 鍙樺崷 / 鍔ㄥ彉 / 绾崇敳 / 涓栧簲 / 鍏翰 / 鍏 |

### 璁捐瑕佺偣
- **涓栧簲涓嶇‖缂栫爜**锛氱敱銆屾湰瀹崷閫愮埢缈昏浆 鈫?娓搁瓊鍥炵炕鍥涚埢 鈫?褰掗瓊杩樺師鍐呭崷銆?
  鐢熸垚鍏 64 鍗︼紝涓栫埢搴忓垪鑷劧涓?6/1/2/3/4/5/4/3锛屾秷鐏竴寮犳槗鎶勯敊鐨勮〃锛?
- **鍙樺崷鍏翰浠嶅彇鏈崷涔嬪**涓恒€屾垜銆嶏紙浼犵粺鍥哄畾瑙勫垯锛屽紩鎿庡唴宸叉敞閲婇槻姝㈣褰?bug 鏀规帀锛夛紱
- **闈欏崷涓嶇敓鎴愬彉鍗?*鈥斺€斾笉杩斿洖銆屼笌鏈崷鐩稿悓銆嶇殑浼彉鍗︼紱
- **鏃犳棩骞插垯鍏涓?null**锛屼笉鐚滈粯璁ゆ棩骞诧紱闈炴硶杈撳叆鎶涘紓甯革紝缁濅笉杩斿洖鍗婃垚鍝併€?

### 淇
- `wu_xing.dart` 鈥?`relationTo` 鐨勩€屾垜鐢?/ 鐢熸垜銆嶄笌銆屾垜鍏?/ 鍏嬫垜銆嶄袱瀵规柟鍚?
  鍒ゆ柇鍐欏弽锛屽鑷村叚浜?**瀛愬瓩涓庣埗姣嶉鍊?*锛涚敱缁忓吀鍗﹀鐓ф祴璇曟崟鑾峰悗淇銆?

### 娴嬭瘯锛?23锛屽叡 129/129 閫氳繃锛?
- `test/domain/casting/hexagram_tables_test.dart` 鈥?鍏崷浜旇 / 64 鍗﹁〃鍞竴鎬?/
  鍏椤哄簭涓庝笘鐖诲簭鍒楋紙涔惧銆佸厬瀹級/ 涓栧簲鐩搁殧涓?/ 绾崇敳鍐呭鍗?/ 鍏翰 / 鍏璧蜂緥锛?
- `test/domain/casting/casting_engine_test.dart` 鈥?**缁忓吀鎺掔洏瀵圭収**锛圙ate A 鐨?
  绂荤嚎绛変环鐗╋級锛氫咕涓哄ぉ銆佸潳涓哄湴銆佹辰灞卞捀 鍏ㄧ埢绾崇敳路鍏翰路涓栧簲閫愰」姣斿锛?
  鑰侀槼鍙橀槾銆佽€侀槾鍙橀槼銆佸鍔ㄧ埢銆侀潤鍗︽棤鍙樺崷銆佸叚绁炴寜鏃ュ共鎺ュ叆銆侀潪娉曡緭鍏ユ嫆缁濓紱
- `flutter analyze --no-pub lib/domain test/domain`锛?*0 issue**銆?

### 鏈満鐜锛堜笉鍏ュ簱锛?
- `scripts/flutter.local.ps1` 鈥?閲嶅缓鏈満 Flutter 鍖呰鑴氭湰銆傛湰鏈?`$env:PATH`
  琚鍓嚦浠呭墿 pnpm shim锛岀己 `System32` / `git` / `flutter` / `PowerShell`锛?
  鐩存帴璋冪敤 `flutter` 鎶?`Error: PowerShell executable not found`銆?
  璇ヨ剼鏈ˉ榻?PATH 鍚庤浆鍙戯紱鍥?`pwsh` 浜︿笉鍦?PATH锛岄』鐢ㄧ粷瀵硅矾寰勮皟鐢細
  `& "$PSHOME\pwsh.exe" -File scripts/flutter.local.ps1 test`

### 鏈仛锛圧3-B锛?
- 鍥涙煴锛堝勾/鏈?鏃?鏃舵煴锛? 鏈堝缓 / 鏃ヨ景 / 鏃┖ 鈥斺€?闇€骞叉敮鍘嗘硶锛堝惈鑺傛皵鎺ㄧ畻锛夛紱
- 鎶婂紩鎿庢帴鍏ュ鍗﹂〉锛屾浛鎹?`ReviewTraditionalProfile` 婕旂ず妗ｆ鍗犱綅瀛楁銆?

---

## 2026-09-10 路 GUAYAN-2.0-R5-BASELINE-CLOSEOUT锛堝熀绾挎敹鍙ｏ紝鏈彂甯冿級

> 鏀跺彛 `3c00187` 閬楃暀鍩虹嚎锛氭帓鍗?lines 椤哄簭 Bug 鐙珛钀藉簱锛坄7266332`锛夛紱
> 瀹″崷 4 涓孩娴嬮€愰」濂戠害瀹¤鈥斺€? 椤?TEST STALE銆? 椤规贩鍚?
> 锛堟柇瑷€杩囨椂 + 鏂囨湰鍒楁棤鍙崇晫鐨勭湡瀹炵己闄凤級锛屾仮澶嶅叏閲忔祴璇曠豢鑹层€?
> 鏈疆绂佹鏂板姛鑳斤紙鎺掔洏寮曟搸/鍏崇郴/鍗︿緥/璁粌鍧囨湭鍔級銆?

### T1 路 鎺掑崷锛坈ommit 7266332锛?
- `casting_draft.dart` 鈥?`CastingDraft.demo().lines` 鐢卞€掑簭鏀瑰崌搴忥紝
  閿佹 `index = position - 1` 濂戠害锛?
- `casting_page_test.dart` 鈥?琛ラ€愮埢浣嶅洖褰掞紙yao_status_1..6 + 缂栬緫寰芥爣 + 寰呭綍鏂囨锛夈€?

### T2/T3 路 瀹″崷濂戠害瀹¤缁撹涓庝慨澶?
| 澶辫触椤?| 瀹氭€?| 澶勭悊 |
| --- | --- | --- |
| F1 鍩虹嚎 31/47 | TEST STALE | 3c00187 鍩虹嚎鍊兼敼涓?18/24/34锛堜笁鏉″甫锛夛紝鏈哄埗鏈涪锛涙祴璇曟敼涓恒€屽悓鏍峰紡鏂囨湰鍏鍏变韩鍩虹嚎 + 鎭?3 鏉″熀绾垮甫銆嶏紝涓嶅啀缁戝畾鍘嗗彶缁濆鍧愭爣 |
| F2 绁炵厼寮哄埗 4脳4 | TEST STALE | 3c00187 瀹氱鍗炽€屾寜瀹為檯鏁版嵁娓叉煋銆佷笉鍐嶅己鍒剁┖鍗犱綅銆嶏紙commit message 鏄庣ず淇搴曢儴绌烘礊锛夛紱娴嬭瘯鏀逛负鎸夋暟鎹覆鏌?+ 鏃犲崰浣?+ 4 鍒楀嚑浣曚繚鎸?|
| F3 鍩烘湰淇℃伅鎷嗗垎鏂█ | TEST STALE | 鍏巻/鍐滃巻涓?meta 鍚堝苟涓哄崟琛岋紙绱у噾鍖栵級锛屼俊鎭叏鍦紱娴嬭瘯鏀?textContaining 楠岃瘉淇℃伅鍦ㄥ満 |
| F4 瓒呴暱绾抽煶涓嶅帇鐖绘Ы | 娣峰悎 | 缁濆 24px 鏂█琚?FittedBox(contain) 鏀惧ぇ澶辨晥锛堢缉鏀炬棤鍏冲寲锛夛紱鐪熷疄缂洪櫡锛氫富/鍙樺崷鏂囨湰鍒楁棤鍙崇晫鍙┛杩囩埢妲?鈫?鍒楀灏侀《 74/88 璁捐 px锛屽垪缂樿鍓?|

### 淇敼
| 璺緞 | 璇存槑 |
| --- | --- |
| `review_hexagram_line_row.dart` | 涓诲崷鏂囨湰鍒?136鈫?10銆佸彉鍗﹀垪 278鈫?66 灏侀《锛涚被鏂囨。瀵归綈瀹為檯鍩虹嚎 18/24/34 涓?contain |
| `review_shensha_card.dart` | 绫绘枃妗ｆ敼涓恒€屾暟鎹┍鍔ㄥ浐瀹?4 鍒椼€嶏紱绉婚櫎鏈娇鐢?CastingTokens import |
| `review_page_test.dart` | F1/F2/F3/F4 鍥涙祴閲嶅啓涓虹缉鏀炬棤鍏?/ 缁撴瀯鏃犲叧濂戠害 |

### 楠岃瘉
- `flutter test`锛?*106/106 閫氳繃**锛堝惈瀹″崷 26/26锛夛紱`flutter analyze` 鏈疆鏂囦欢 0 issue銆?
- `pubspec.lock`锛氭祴璇曠敤 `--no-pub` 杩愯锛屾棤渚濊禆娴姩锛屼笉鍏ュ簱銆?
- `uploads/screenshots/`锛氫汉宸ラ獙鏀舵埅鍥撅紝淇濇寔鏈窡韪師鐘躲€?

---

## 2026-08-31 路 GUAYAN-2.0-REVIEW-BASELINE-R4锛堝鍗﹂灞忓熀绾垮榻愬畾绋匡紝鏈彂甯冿級

> 鍙姩涓や釜缁勪欢锛氬叚鐖诲崷鐩橈紙Baseline Alignment锛? 绁炵厼锛團IXED 4脳4锛夛紝
> 鍏朵綑宸插畾绋?UI 涓€寰嬩笉鍔ㄣ€傜湡姝ｅ缓绔?琛屽熀绾?+ 鍒椾腑蹇冪嚎"锛屾秷鐏瑙夊弬宸€?

### 鍏埢鍗︾洏
| 椤?| 璇存槑 |
| --- | --- |
| Primary Baseline | RowTop + 19锛氬叚绁?浼忕脳2/涓诲崷姝ｆ枃/涓栧簲/鍙樺崷姝ｆ枃/鍙樺崷涓栧簲 鍏ㄩ儴鏁板閿佸畾鍚屼竴鏉″熀绾匡紙Flutter `Baseline` 缁勪欢锛?|
| NaYin Baseline | RowTop + 35锛氫富/鍙樺崷绾抽煶鍚勮嚜灞呬腑浜庢鏂囧垪 |
| 琛岄珮 / 鍒椾腑蹇?| 48 DIP锛涘叚绁?2 浼忕62/100 姝ｆ枃174/318 鐖?22/358 涓栧簲250/388 鍔ㄧ埢268 绠ご280 |
| 瀛楀彿灞傜骇 | 杈呭姪淇℃伅锛堝叚绁?.4/浼忕9/涓栧簲8.8锛夊父瑙勪笉鍔犵矖锛涙鏂?10.5 鍔犵矖锛?314D59锛夛紱绾抽煶 9 甯歌 |
| 鑷€傚簲 | 400 璁捐绌洪棿 + FittedBox(scaleDown)锛涜鍐呮棤杈规锛屽垎鍓茬嚎鐢辫〃鏍肩嫭绔嬬粯鍒讹紝FittedBox 鐖堕珮鎭?48 鏃犵旱鍚戠缉鏀?|

### 绁炵厼
| 椤?| 璇存槑 |
| --- | --- |
| FIXED 4脳4 | 鏍煎 89銆佹牸楂?18銆佸垪璺?6銆佽璺?4锛?16 椤圭暀绌哄崰浣嶃€?16 鎵嶅姞绗?5 琛岋紱绂佹鑷敱 Wrap锛涚 4 琛屾案鍦ㄥ崱鍐?|

### Token / 琛ㄥご
- 鏂板 `linePrimary #314D59`銆乣shenShaItem #5C7078`锛沢uaTitle 13 / guaName 10.8

### 娴嬭瘯锛?3锛屽叡 106/106 閫氳繃锛?
- R4 鍩虹嚎閿佸畾锛圔aseline 鈭?{19,35}锛氫富 6 鏉?/ 绾抽煶 2 鏉★級
- R4 绁炵厼鍥哄畾 4脳4锛?6 鏍笺€佸悓鍒楀榻愩€佺 4 琛屽湪鍗″唴锛?
- R4 绁炵厼 <16 椤癸紙12 绌轰綅鍗犱綅淇濇寔 4脳4锛?
- analyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 2026-08-31 路 GUAYAN-2.0-REVIEW-ONSCREEN-R3锛堝鍗﹂灞忚垝閫傜揣鍑戠増锛屾湭鍙戝竷锛?

> **纭棬绂侊細鍏埢鍏蹇呴』鍦ㄥ鍗﹂灞忓畬鏁存樉绀?*锛堜笉鍐嶆帴鍙椾笅婊戞墠鑳界湅鍒版湵闆€/鍒濈埢锛夈€?

### 甯冨眬璋冩暣
| 椤?| 鍙樺寲 |
| --- | --- |
| 鍗﹀悕 Header | 66 鈫?54 DIP锛堜富/鍙樺崷鏍囬 + 鍗﹀悕鍚勪竴琛岋紝h2 12 / gua 10锛?|
| 浼忕 | 3 瀛楃煭鏍煎紡锛氬叚浜茬畝绉?+ 鍦版敮 + 浜旇锛堣储瀵呮湪 / 鐖舵湭鍦熲€︼級锛屼笉鍐嶈瀹藉害瑁佸垏 |
| 鍏埢琛岄珮 | 56 鈫?48 DIP锛屾鏂囦袱琛屽畬鏁淬€佹棤鐪佺暐鍙?|
| 鍒楀 | 鍏 24 / 浼忕 28 / 涓栧簲 12 / 鍔ㄧ埢 12 / 绠ご 6 / 鐖绘Ы 24锛?60 DIP 涓嶆孩鍑猴級 |
| 绱у噾鍖?| 鍥涙煴 40 / 绁炵厼 chip 19 / BasicInfo 84 / 椤甸潰闂磋窛 6 |
| 琛ㄥ熬 | 銆岀偣鍑讳换涓€鐖绘煡鐪嬪叧绯汇€佽鍒欎緷鎹笌鍏崇郴澶囨敞銆?|

### 娴嬭瘯
- 鏂板纭棬绂佹祴璇曪細430脳932 涓嬪叚鐖诲叚琛?+ 琛ㄥ熬鍦ㄥ簳閮ㄥ鑸尯涔嬩笂瀹屾暣鍙
- 浼忕鏂█鏇存柊涓?3 瀛楃煭鏍煎紡
- 楠岃瘉锛歠lutter test 103/103 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 2026-08-31 路 GUAYAN-2.0-REVIEW-ONSCREEN锛堝鍗︿竴灞忕増鏀跺彛锛屾湭鍙戝竷锛?

> 鏁翠綋鏀跺彛锛氫竴灞忓厛鐪嬪畬鏁村熀鏈俊鎭?+ 鍥涙煴 + 4脳4 绁炵厼 + 瀹屾暣鍗︾洏锛?
> 銆屽叧绯荤劍鐐广€嶄笉鍐嶅父椹诲ぇ鍗★紝鏀圭偣鏌愪竴鐖?鈫?楂樹寒 鈫?Bottom Sheet锛堝叧绯诲垪琛?瑙勫垯渚濇嵁/
> 鍏崇郴澶囨敞/杩涘叆鍏崇郴椤碉級銆傚崷鐩樺交搴曞彇娑堢渷鐣ュ彿锛堝叚浜插湴鏀笌绾抽煶鎷嗕袱琛岋級銆?

### 瀹″崷椤?
| 璺緞 | 璇存槑 |
| --- | --- |
| `review_page.dart` | 涓€灞忓竷灞€閲嶆帓锛涘垹闄ゅ父椹诲叧绯荤劍鐐瑰崱锛涚偣鐖婚珮浜?+ 寮瑰眰锛沷nOpenRelations |
| `review_basic_info_card.dart` | 绱у噾鍗曞崱锛堥棶浜?鏂瑰紡 chip/鍏巻/鍐滃巻/meta锛?|
| `review_four_pillars_strip.dart` | soft 搴?44 楂?+ teal/warm 鍙岃壊 + 鏃┖鍙冲榻?|
| `review_shensha_card.dart` | chip 20 楂樼揣鍑?4脳4 |
| `review_hexagram_result_table.dart` | 琛ㄥご + 琛岀偣鍑婚€忎紶 + 鏂拌〃灏炬彁绀?|
| `review_hexagram_line_row.dart` | 鍏翰鍦版敮/绾抽煶鎷嗕袱琛屻€佹棤鐪佺暐鍙凤紱11 鍒楀浐瀹氭Ы浣嶏紱鍙偣楂樹寒 |
| `review_line_detail_sheet.dart`锛堟柊澧烇級 | 鐐圭埢寮瑰眰锛氬綋鍓嶇埢 + 鍏崇郴鍒楄〃 + 瑙勫垯渚濇嵁 + 澶囨敞(GAP) + 杩涘叧绯婚〉 |
| 鍒犻櫎 `review_relation_focus_card.dart` | 鈥?|
| `review_page_state.dart` / `review_case_adapter.dart` | allRelations / relationsInvolving / relationLabel |
| `review_demo_data.dart` | 瀵归綈涓€灞忕増 SVG锛堥棶浜?09:30/涓冩湀鍗佸叓 路 宸虫椂/鐢抽厜绌猴級 |

### 鎺掑崷椤?
| 璺緞 | 璇存槑 |
| --- | --- |
| `line_editor_sheet.dart` | 鐖昏薄閫夐」鍗?mainAxisExtent 58 鍥哄畾锛堚墺58 DIP 纭棬绂侊級锛屼慨澶?BOTTOM OVERFLOWED 1.2px |

### Token / 鍏变韩
- `casting_tokens.dart`锛歡ua #927848銆乸illarTeal #4F8685銆佹柊澧?pillarWarm #A8605C
- `shared/yao_glyph.dart` / `moving_marker.dart`锛氭弿杈瑰搴︽寜涓€灞忕増 SVG 寰皟

### 娴嬭瘯
- `review_page_test.dart`锛氫竴灞忕増閫傞厤 + 鐐圭埢寮瑰眰锛堝叧绯诲垪琛?/ 杩涘叆鍏崇郴椤靛洖璋冿級+ 绐勫睆 360 鏃犳孩鍑?
- `casting_page_test.dart`锛氭柊澧炪€岀埢璞″脊灞傜獎灞?360脳640 鏃?RenderFlex 婧㈠嚭銆?
- `foundation_test.dart`锛氬鍗﹀垎鏀柇瑷€鏀逛负 绁炵厼
- 楠岃瘉锛歠lutter test 102/102 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 2026-08-30 路 GUAYAN-2.0-UI-CORRECTION-R2锛堟帓鍗?+ 瀹″崷澧為噺淇锛屾湭鍙戝竷锛?

> 鍦?R1 宸插畾绋垮熀纭€涓婂仛澧為噺淇锛氬垹鎺掑崷椤堕儴鑽夌鎽樿鍗°€佽捣鍗︽椂闂存樉绀哄叕鍘?鍐滃巻銆?
> 鍏埢褰曞叆琛岀粺涓€ 52 DIP銆佺鐓炲浐瀹?4 鍒椼€佹渶缁堝崷鐩樼粍浠讹紙鍐呭祵涓?鍙樺崷鏍囬锛夈€?
> 缁熶竴鐖绘Ы 24脳6锛堥槼/闃?绌轰骸浠呭唴閮ㄥ～鍏呬笉鍚岋級銆佸姩鐖绘爣璁?12脳12銆佹枃鏈笉寰楀帇鐖汇€?

### 鏂板锛坙ib/presentation/shared/ 鈥?鎺掑崷/瀹″崷寮哄埗澶嶇敤锛?
| 璺緞 | 璇存槑 |
| --- | --- |
| `yao_glyph.dart` | 缁熶竴鐖绘Ы 24脳6锛歽ang 瀹炲績 / yin 宸﹀彸鏂嚎 / voidYao 绌哄績鎻忚竟 rx1 #7E9098 w1.5 |
| `moving_marker.dart` | 鍔ㄧ埢鏍囪 12脳12锛氳€侀槾 鈼?#A17F45 / 鑰侀槼 脳 #567866锛孊ounding Box 涓€鑷?|
| `test/presentation/shared/yao_glyph_test.dart` | 鍏变韩缁勪欢灏哄鍐荤粨娴嬭瘯锛圲I-05/06 缁勪欢绾э級 |

### 鎺掑崷椤?
| 璺緞 | 璇存槑 |
| --- | --- |
| `casting_page.dart` | 鍒犻櫎 CastingDraftContext锛埪?.1锛?|
| `casting_time_row.dart` | 閲嶅啓锛?8 楂橈紝鍏巻 + 鍐滃巻 + 鍙充笂鐘舵€?chip锛埪? SVG锛?|
| `casting_page_state.dart` | 鏂板 lunarPlaceholder锛圙AP锛氬啘鍘嗘崲绠楀緟鎺ュ叆锛宲resentation mock锛?|
| `six_yao_input_row.dart` | 鏅€氳 = 缂栬緫琛?= 52 DIP锛埪?锛夛紱杩佺Щ鍏变韩 YaoGlyph |
| `line_editor_sheet.dart` | 杩佺Щ鍏变韩 YaoGlyph + MovingMarker |
| 鍒犻櫎 `casting_draft_context.dart`銆佹棫 `casting/widgets/yao_glyph.dart` | 鈥?|

### 瀹″崷椤?
| 璺緞 | 璇存槑 |
| --- | --- |
| `review_page_state.dart` | 浼忕鎷嗕袱鍒楋紙hiddenSpirit1/2锛? isVoid锛堜富鍗?鍙樺崷锛夛紱绾抽煶鏀瑰崐瑙掓嫭鍙?|
| `review_case_adapter.dart` / `review_demo_data.dart` | 浼忕涓ゅ垪 + isVoid 閫忎紶锛涙寜 SVG #12锛氫簲鐖讳竵閰夈€佷笁鐖讳笝鐢崇┖浜?|
| `review_shensha_card.dart` | 绁炵厼鍥哄畾 4 鍒楁暟鎹┍鍔ㄧ綉鏍硷紙搂5锛?16 椤圭户缁姞琛岋級 |
| `review_hexagram_result_table.dart` | 鏈€缁堝崷鐩樼粍浠讹細鍐呭祵銆愪富鍗︺€?銆愬彉鍗︺€戞爣棰?+ 鍏鎺掔洏 + 琛ㄥ熬锛埪?/搂12锛?|
| `review_hexagram_line_row.dart` | 11 鍒楀喕缁撳竷灞€锛氬叚绁?浼忕脳2/涓诲彉鍗︽枃瀛?鐖绘Ы(24脳6)/涓栧簲/鍔ㄧ埢(12脳12)/绠ご锛涙枃鏈?Ellipsis 涓嶅帇鐖伙紙搂11锛?|
| `review_page.dart` | 绉婚櫎 HexagramResultHeader锛堥伩鍏嶆爣棰橀噸澶嶆覆鏌擄級 |
| 鍒犻櫎 `review_hexagram_result_header.dart` | 鈥?|

### 娴嬭瘯
- `casting_page_test.dart`锛歎I-01锛堟棤 DraftContext锛? UI-02锛堝叕鍘?鍐滃巻锛? UI-03锛堣楂?52 涓€鑷达級
- `review_page_test.dart`锛歎I-04锛堢鐓?4 鍒楋級/ UI-05锛堢埢妲?24脳6锛? UI-06锛堝姩鐖?12脳12锛?
  UI-07锛堣秴闀挎枃鏈笉鍘嬬埢锛? UI-08锛堝彉鍗︾埢妲?鍙樺崷涓栧簲鍚屾樉锛? R1 娴嬭瘯閫傞厤
- `foundation_test.dart`锛氬鍗﹀垎鏀柇瑷€鏀逛负銆愪富鍗︺€?

### GAP / 鍋忓樊
- 鍐滃巻涓?presentation mock锛坙unarPlaceholder锛夛紝鐪熷疄鎹㈢畻寰呮帓鐩樺紩鎿庢帴鍏ワ紱
- 绌轰骸 isVoid 浠?UI 琛ㄧ幇锛堟紨绀烘。妗堟彁渚涳級锛學idget 涓嶈绠楁棳绌猴紱
- 婕旂ず pos2锛堣€侀槼锛夋寜璇箟娓叉煋闃虫Ы + X锛孲VG #12 鐢讳綔闃?X锛堟湁鎰忎慨姝ｏ紝淇濇寔闃撮槼璇箟涓€鑷达級銆?
- 楠岃瘉锛歠lutter test 100/100 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛沝ebug APK 鏋勫缓閫氳繃銆?

---

## 2026-08-30 路 GUAYAN-2.0-REVIEW-UI-R1锛堝鍗﹂〉 XYUI 宸ヤ綔鍙板畾绋垮疄鏂斤紝鏈彂甯冿級

> **瀹″崷椤垫渶缁堣瑙?*锛氭寜浜哄伐瀹氱鎬?SVG 鎶娿€屽鍗︺€嶅崰浣嶉〉瀹炵幇涓?XYUI 闀块〉鎺掔洏宸ヤ綔鍙?
> 锛圔asicInfo 鈫?ShenSha 鈫?FourPillars 鈫?HexagramHeader 鈫?HexagramTable 鈫?RelationFocus锛夈€?
> 浼犵粺鎺掔洏瀛楁鐢辨紨绀烘。妗堟彁渚涳紙鎺掔洏寮曟搸 R3 鍓嶄笉閫犲亣绠楁硶锛夛紱鐪熷疄鍗︿緥缁?App Shell
> `onGenerated` 妗ユ帴鎺ュ叆锛屽叚鐖?鍦版敮/鍏崇郴鐒︾偣鍏ㄩ儴鏉ヨ嚜鐜版湁 Domain銆?

### 鏂板锛坙ib/presentation/review/锛?
| 璺緞 | 璇存槑 |
| --- | --- |
| `review_page.dart`锛堥噸鍐欙級 | 瀹″崷宸ヤ綔鍙扮粍瑁咃紙搂3 甯冨眬锛?|
| `review_page_state.dart` | 绾?Dart 鐘舵€佹ā鍨嬶紙搂7 鍏ㄩ儴瀛楁锛屾湭鎺ュ叆瀛楁鏄惧紡 nullable锛?|
| `review_case_adapter.dart` | HexagramCase + 浼犵粺妗ｆ 鈫?ReviewPageState锛涚劍鐐瑰叧绯绘潵鑷?calculateRelations |
| `review_demo_data.dart` | 瑙嗚瀹氱婕旂ず鏁版嵁锛堟辰灞卞捀鈫掓辰姘村洶 / 16 绁炵厼 / 涓欏崍骞粹€︿竵閰夋椂 / 鍏浼忕鍏翰绾抽煶涓栧簲锛?|
| `widgets/review_app_bar.dart` | 椤舵爮锛堣繑鍥?chevron + 瀹″崷 + 鎺掔洏缁撴灉锛屄?锛?|
| `widgets/review_basic_info_card.dart` | 鍩烘湰淇℃伅鍗★紙搂2锛?|
| `widgets/review_shensha_card.dart` | 绁炵厼鐙珛鍗＄墖 + 鑷€傚簲 Wrap 缃戞牸锛埪?/搂8锛?|
| `widgets/review_four_pillars_strip.dart` | 鍥涙煴鏉★細骞?鏈?鏃?鏃?鏃┖锛埪?/搂9锛?|
| `widgets/review_hexagram_result_header.dart` | 鎺掔洏缁撴灉澶?+ 涓?鍙樺崷鏍囬锛埪?锛?|
| `widgets/review_hexagram_result_table.dart` | 鍏埢鎺掔洏涓讳綋琛紙搂6锛屼笂鐖诲湪涓婂垵鐖诲湪涓嬶級 |
| `widgets/review_hexagram_line_row.dart` | 鍏埢鍗曡锛堝叚绁?涓诲崷鍚紡绁?鍙樺崷 + 鐭㈤噺鐖昏薄 + 涓栧簲/鍔ㄧ埢锛?|
| `widgets/review_relation_focus_card.dart` | 鍏崇郴鐒︾偣鍗★紙搂7/搂13锛岃鍒欎緷鎹烦杞鍒欏簱锛?|
| `test/presentation/review/review_page_test.dart` | 搂22 Test A鈥揌 + 閫傞厤鍣?鐒︾偣鍏崇郴/鍙屾暟鎹矾寰?|

### 淇敼
| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/presentation/casting/casting_tokens.dart` | 琛ュ厖 搂4 Token锛歳elationRed / relationBlue / traditionalGold / pillarTeal |
| `lib/presentation/casting/casting_page.dart` | 鏂板鍙€?`onGenerated` 鍥炶皟锛堢敓鎴愬悗閫氱煡 Shell锛?|
| `lib/app/app_shell.dart` | 瀹″崷椤甸殣钘忓叏灞€ AppBar锛堣嚜甯?XYUI TopBar锛夛紱`_latestCase` 妗ユ帴鎺掑崷缁撴灉 |
| `test/foundation_test.dart` | 瀹″崷鍒嗘敮鏂█閫傞厤锛堟棤鍏ㄥ眬 AppBar + 瀹屾暣鎺掔洏/鍏崇郴鐒︾偣锛?|

### GAP锛堟湰杞瀹炴爣娉級
- 鍏/浼忕/鍏翰/绁炵厼/鍥涙煴/鍗﹀悕/绾抽煶锛氭帓鐩樺紩鎿庯紙R3锛夎惤鍦板墠浠呮紨绀烘。妗堟彁渚涳紝
  鐪熷疄鍗︿緥涓嬫樉寮忕疆绌猴紝涓嶅仛鍋囧叚鐖荤畻娉曪紱
- 涓栧簲/鐢熷厠/鍥炲ご鐢熷洖澶村厠锛氬叧绯昏鍒欏睘 R3/R4锛屾湰杞粎鍏ュ彛锛圧elationFocusCard chips锛夛紱
- 鎺掑崷椤点€屾煡鐪嬪鍗?鈥恒€嶅叆鍙ｅ鑸粛涓鸿瑙夋€侊紙鍚庣画杞鎺ラ€氾級銆?
- 楠岃瘉锛歠lutter test 84/84 閫氳繃锛沘nalyze 鏈疆鏂囦欢 0 issue锛?1 鏉℃棫浠ｇ爜鍛婅鏈姩锛夛紱
  debug APK 鏋勫缓閫氳繃銆?

---

## 2026-08-30 路 GUAYAN-2.0-CASTING-UI-R1锛堟帓鍗﹂〉 XYUI 宸ヤ綔鍙板畾绋垮疄鏂斤紝鏈彂甯冿級

> **鎺掑崷椤垫渶缁堣瑙?*锛氬簾寮冦€屾柟妗?2 绾靛悜娴佺▼杞ㄣ€嶏紝鎸変汉宸ユ媿鏉跨殑鎬?SVG 鏀逛负
> 鎺掑崷宸ヤ綔鍙?鈥斺€?1 璧峰崷鏃堕棿 鈫?2 闂簨淇℃伅 鈫?3 鍏埢褰曞叆 鈫?4 瑙勫垯鍖?鈫?5 鐢熸垚鎺掔洏銆?
> 鏈疆涓鸿瑙夐鏋?+ 鐘舵€佺粍浠?+ 蹇呰浜や簰鍩虹锛涗笉鍋氬鍗﹂〉閲嶆瀯銆佸叧绯诲紩鎿庛€佸畬鏁磋鍒?CRUD銆?

### 鏂板锛坙ib/presentation/casting/widgets/锛?
| 璺緞 | 璇存槑 |
| --- | --- |
| `casting_app_bar.dart` | 椤舵爮锛堝崷鐪?/ 鎺掑崷 / 涓夌偣鏇村锛屄?.1锛?|
| `casting_draft_context.dart` | 鑽夌涓婁笅鏂囧崱锛堣崏绋夸腑锛屄?.2锛?|
| `casting_time_row.dart` | 璧峰崷鏃堕棿绗竴琛岋紙搂5.3锛屾棩鏈?鏃堕棿+鏃惰景锛?|
| `casting_question_row.dart` | 闂簨淇℃伅绗簩琛岋紙搂5.4锛屼富棰?姝ｆ枃/瀵硅薄/鑳屾櫙锛?|
| `six_yao_input_panel.dart` | 鍏埢褰曞叆绗笁琛岄潰鏉匡紙搂5.5锛屽綋鍓嶆楠?chip锛?|
| `six_yao_input_row.dart` | 鍏埢鍗曡锛堝凡褰?寰呭綍/缂栬緫涓夋€侊紝搂8/搂9锛?|
| `yao_glyph.dart` | 鐖荤煝閲忓浘褰紙闃撮槼绾?+ 鑰侀槾绌哄績鍦?鑰侀槼 X锛屄?0锛?|
| `casting_rule_pack_row.dart` | 瑙勫垯鍖呯鍥涜锛埪?.6锛屼慨鏀?鈥猴級 |
| `casting_generate_row.dart` | 鐢熸垚鎺掔洏绗簲琛岋紙locked/ready/generated锛屄?.7/搂14锛?|
| `casting_chip.dart` | XYUI 鑳跺泭寰芥爣 + 鐭㈤噺 chevron |
| `line_editor_sheet.dart` | 鐖昏薄閫夋嫨寮瑰眰锛堝皯闃?灏戦槼/鑰侀槾/鑰侀槼 + 娓呴櫎锛?|
| `time_editor_sheet.dart` | 璧峰崷鏃堕棿寮瑰眰锛堟棩鏈?鏃堕棿/鏃惰景鑷姩鎹㈢畻锛屄?1锛?|
| `question_editor_sheet.dart` | 闂簨淇℃伅寮瑰眰锛堝洓椤规枃鏈紝搂12锛?|
| `rule_pack_sheet.dart` | 瑙勫垯鍖呭崰浣嶅脊灞傦紙搂13锛屼笉閫犲亣 CRUD锛?|
| `test/presentation/casting/casting_page_test.dart`锛堥噸鍐欙級 | Test A鈥揇 + 琛岄『搴?+ 鑽夌浠撳簱 + 绾€昏緫 |

### 鏂板锛坙ib/services/draft/锛?
| 璺緞 | 璇存槑 |
| --- | --- |
| `casting_draft.dart` | 鑽夌妯″瀷锛堝惈瑙嗚瀹氱婕旂ず鑽夌 CastingDraft.demo锛?|
| `draft_repository.dart` | DraftRepository 鎺ュ彛杈圭晫 + 鍐呭瓨瀹炵幇锛埪?5锛屼笉鎶?DB 鍐欒繘 Widget锛?|

### 淇敼
| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 娴佺▼杞?鈫?XYUI 鎺掑崷宸ヤ綔鍙帮紙鐘舵€佸叏閮ㄨ繘鍏?CastingPageState锛?|
| `lib/presentation/casting/casting_page_state.dart` | 閲嶅啓锛欸enerationState / DraftState / CastingPageState锛埪? 鍏ㄩ儴瀛楁锛?|
| `lib/presentation/casting/casting_tokens.dart` | 瀵归綈浠诲姟涔?搂3 瀹氱 Token 鍊?|
| `lib/app/navigation/guayan_main_tab_bar.dart` | 鐧藉簳 + 鑳跺泭閫変腑锛涙帓鍗﹀浘鏍?鈫?鑹崷鐭㈤噺锛埪?6锛屾棤 Unicode 鈽讹級 |
| `test/foundation_test.dart`锛堥噸鍐欙級 | Test E 浜斿鑸?/ Test F 鑹崷鍥炬爣 / 鐘舵€佷繚鎸?/ 鏇村鑿滃崟 |

### 鍒犻櫎锛堟柟妗?2 娴佺▼杞ㄧ粍浠讹級
`casting_top_bar / casting_flow_header / casting_flow_rail / casting_workflow / casting_step_node / casting_step_card / casting_step_status / casting_generate_step / casting_context_strip`锛坵idgets/ 涓?9 涓枃浠讹級

### 楠岃瘉
- `flutter test`锛氬叏閲忛€氳繃锛堝惈 Test A鈥揊锛?
- `flutter analyze`锛氭湰杞柊澧?淇敼鏂囦欢 0 issue锛堝瓨閲忛仐鐣?21 椤?lint 涓嶅彉锛岃鍏?BACKLOG锛?
- Android debug 鏋勫缓鎴愬姛锛坄build/app/outputs/flutter-apk/app-debug.apk`锛?

### 璇存槑锛圙AP锛屽悗缁樁娈碉級
- 瀹屾暣骞叉敮鍘嗘硶寮曟搸锛堝勾鏈堟棩骞叉敮 / 鏃┖ / 绾崇敳锛夋湭鍋氾紝鏈疆浠呭皬鏃垛啋鏃惰景鍩虹鏄犲皠锛?
- 鑷畾涔夎鍒欏寘 CRUD 鏈仛锛堝崰浣嶅脊灞傦紝淇濈暀 RuleId + RuleVersion锛夛紱
- 銆屾煡鐪嬪鍗?鈥恒€嶆湰杞负瑙嗚鍗犱綅锛岃法 tab 瀵艰埅灞炲悗缁紱
- 鑽夌鎸佷箙鍖栦负鍐呭瓨瀹炵幇锛屾帴鍙ｈ竟鐣屽凡瀹氬瀷锛圖raftRepository锛夈€?

---

## 2026-08-30 路 鎺掑崷椤?XYUI 鏀归€狅紙Vertical Casting Workflow锛屾湭鍙戝竷锛?

> **鏂规 2 路 绾靛悜鎺掑崷娴佺▼杞?*锛氳捣鍗︽椂闂?鈫?闂簨淇℃伅 鈫?鍏埢杈撳叆 鈫?瑙勫垯鍖?鈫?鐢熸垚鎺掔洏銆?
> 瑙嗚浠ヤ换鍔′功 SVG 涓哄敮涓€鍩哄噯锛涙湰杞负瑙嗚闃舵锛堜笉鍋氬畬鏁磋〃鍗曚笌鎺掔洏绠楁硶锛夛紝
> 姝ラ鎽樿涓烘紨绀哄崰浣嶅€硷紝寰呯敤鎴风湡鏈烘埅鍥句汉宸ラ獙鏀躲€?

### 鏂板锛坙ib/presentation/casting/锛?
| 璺緞 | 璇存槑 |
| --- | --- |
| `casting_tokens.dart` | XYUI 瑙嗚 Token 闆嗕腑锛埪?8锛?|
| `casting_page_state.dart` | CastingStepState锛坈urrent/pending/completed/warning/locked锛? 鏁版嵁妯″瀷 |
| `widgets/casting_top_bar.dart` | XYUI 椤舵爮锛堟帓鍗?鍓爣棰?涓夌偣鏇村锛?|
| `widgets/casting_flow_header.dart` | CASTING FLOW 澶撮儴锛堝綋鍓嶆楠?x/5锛?|
| `widgets/casting_workflow.dart` | 娴佺▼杞ㄧ粍瑁咃紙rail + 姝ラ琛岋級 |
| `widgets/casting_flow_rail.dart` | 绾靛悜绔栫嚎 |
| `widgets/casting_step_node.dart` | 鑺傜偣鐘舵€佸叏闆嗭紙鏁板瓧/瀵瑰嬀/!/閿侊紝鐭㈤噺缁樺埗锛?|
| `widgets/casting_step_card.dart` | 姝ラ鍗″洓绉嶇姸鎬侊紙鍚畬鎴愭憳瑕侊級 |
| `widgets/casting_step_status.dart` | 鐘舵€佸窘鏍?+ chevron |
| `widgets/casting_generate_step.dart` | 鐢熸垚姝ラ锛坙ocked/ready/completed/warning锛?|
| `widgets/casting_context_strip.dart` | 娴佺▼涓婁笅鏂囨潯锛堣鍒欏寘/鎺㈤拡/宸插畬鎴?x/5锛?|
| `test/presentation/casting/casting_page_test.dart` | 宸ヤ綔娴佺姸鎬佹祴璇曪紙鎺ㄨ繘/鐢熸垚/闇€閲嶆柊鐢熸垚/鎺㈤拡/缁勪欢鐘舵€侊級 |

### 淇敼
| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 鍗犱綅椤?鈫?绾靛悜娴佺▼杞紙鐘舵€佹満椹卞姩锛?|
| `lib/app/navigation/guayan_main_tab_bar.dart`锛堟柊澧烇級 | XYUI 搴曢儴瀵艰埅 + 浜斿浘鏍?CustomPainter锛埪?5锛?|
| `lib/app/navigation/main_tabs.dart` | MainTab 澧炲姞 iconBuilder |
| `lib/app/app_shell.dart` | NavigationBar 鈫?GuayanMainTabBar锛涙帓鍗﹂〉鏃犲叏灞€ AppBar |
| `lib/app/more_menu.dart` | 鏀寔鑷畾涔?icon锛堟帓鍗﹂〉涓夌偣锛?|
| `test/foundation_test.dart` | 閫傞厤鏂?UI锛圶YUI 瀵艰埅/娴佺▼杞?鎺㈤拡 Key/涓夌偣鏇村锛?|
| `file-tree.md`銆乣CHANGELOG.md` | 鏈枃浠?|

### 楠岃瘉
- `flutter test`锛?*63/63 閫氳繃**锛堥鍩?53 + foundation 鏇存柊 10 + 鎺掑崷椤垫柊澧?10锛?
- `flutter analyze`锛氭湰杞柊澧?淇敼鏂囦欢 0 issue锛堝瓨閲忛仐鐣?21 椤?lint 璁板叆 BACKLOG锛?
- Android debug 鏋勫缓鎴愬姛锛坄build/app/outputs/flutter-apk/app-debug.apk`锛?

### 璇存槑
- 鐘舵€佽繘鍏ョ湡瀹?State锛屼笉浠庨鑹插弽鎺紱宸插畬鎴愭楠ゅ彲閲嶆柊杩涘叆锛?
  鐢熸垚鍚庝慨鏀瑰叧閿暟鎹?鈫?鐢熸垚姝ラ鏍囪銆岄渶閲嶆柊鐢熸垚銆嶏紙涓嶆竻绌哄凡濉唴瀹癸級銆?
- 鍘熴€岀姸鎬佹帰閽堬細0銆嶅绔嬫枃鏈Щ闄わ紝鎺㈤拡璇箟淇濈暀鍦?Context Strip锛堝彲鐐瑰嚮閫掑锛夈€?
- 瀹屾暣璧峰崷鏃堕棿閫夋嫨鍣?/ 闂簨缂栬緫鍣?/ 鍏埢缂栬緫鍣?/ 瑙勫垯鍖呯鐞?/ 鎺掔洏绠楁硶 鈫?鍚庣画闃舵锛圔ACKLOG锛夈€?

---

## 2026-08-30 路 GUAYAN-2.0-DOMAIN-HARDENING锛圫table Relation Identity 鏀跺彛锛屾湭鍙戝竷锛?

> **鑳屾櫙锛?* 浜哄伐鏍搁獙 DOMAIN 闃舵鍚庤鍙富浣撹璁★紝瑕佹眰灏佹 4 涓暟鎹吋瀹归棶棰?
> 锛坈anonical 纰版挒 / 瑙勫垯鐗堟湰 replay / Domain 涓嶅彉閲?/ 鏈満鑴氭湰鍏ュ簱锛夛紝
> 涓嶉噸鏋勩€佷笉杩涘叆 R3銆傞獙鏀跺彞鍗囩骇锛?
> RelationInstance 鍙噸寤猴紱RelationNote 涓嶅け蹇嗭紱RuleVersion 鍙樺寲涓嶈兘璁╁巻鍙插崷渚嬪け蹇嗭紱
> 浠绘剰鍚堟硶 RuleId/Subtype 涓嶈兘鍒堕€犺韩浠界鎾烇紱鍧?Case 鏁版嵁涓嶈兘鍒堕€犻噸澶嶈韩浠姐€?

### 鏂板

| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/domain/rule_execution_context.dart` | 瑙勫垯鐗堟湰 replay 涓婁笅鏂囷紙RuleVersionRef / RuleExecutionContext锛?|
| `test/domain/relation_key_collision_test.dart` | T1 canonical 鏃犳涔夋€э紙鍚?`|`/`->`/`<->`/`\` 鐨勭鎾炲洖褰掞級 |
| `test/domain/rule_version_replay_test.dart` | T2 鏃у崷渚?v1 鈫?绯荤粺鍗囩骇 v2 鈫?reload 鈫?replay v1 鈫?绗旇鎭㈠ |
| `test/domain/domain_invariants_test.dart` | T3 鐖讳綅/鍏埢涓嶅彉閲?+ 鍧?JSON 鎷掔粷 |

### 淇敼

| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/domain/relation_key.dart` | canonical 鏃犳涔夊寲锛氬瓧绗︿覆瀛楁绋冲畾杞箟锛坄\`鈫抈\\`锛宍|`鈫抈\|`锛夛紝鍗曞皠缂栫爜 |
| `lib/domain/hexagram_case.dart` | 鏂板 `ruleContext` 瀛楁锛堣窡闅忔寔涔呭寲锛夛紱runtime 鏍￠獙鎭板ソ 6 鐖汇€乸osition 鎭颁负 1..6銆佹棤閲嶅 |
| `lib/domain/line_endpoint.dart` | 鏋勯€犳敼涓?runtime 鏍￠獙鐖讳綅锛?..6锛夛紝JSON 鍙嶅簭鍒楀寲鍚屾牎楠?|
| `lib/domain/line_state.dart` | 鍚屼笂 |
| `lib/domain/relation_calculator.dart` | 瑙勫垯鐗堟湰浼樺厛鍙?`case.ruleContext.versionForOrDefault(ruleId)`锛屾棤璁板綍鍥為€€ v1 |
| `.gitignore` | `scripts/flutter.local.ps1` 涓嶅叆搴擄紱`*.apk` 蹇界暐 |
| `scripts/flutter.ps1` | 绉诲嚭鐗堟湰鎺у埗锛堝垹闄わ紱宸ヤ綔鍖烘敼涓?`scripts/flutter.local.ps1`锛?|
| `lib/domain/README.md` | 琛ュ厖 escaping / replay 濂戠害 / runtime 涓嶅彉閲忚璁¤鏄?|
| `file-tree.md`銆乣CHANGELOG.md` | 鏈枃浠?|

### 楠岃瘉

- `flutter test`锛?*53/53 閫氳繃**锛堝師 Test A鈥揈 + T8 鍏ㄩ儴缁х画閫氳繃锛涙柊澧?T1 纰版挒 7 椤广€?
  T2 replay 4 椤广€乀3 涓嶅彉閲?12 椤癸級
- `flutter analyze`锛氭湰杞柊澧?淇敼鏂囦欢 0 issue锛堝瓨閲忛仐鐣?21 椤?lint 璁板叆 BACKLOG锛?
- Android debug 鏋勫缓鎴愬姛锛坄build/app/outputs/flutter-apk/app-debug.apk`锛?
- 鏈惎鍔?Android 妯℃嫙鍣?

---

## 2026-08-30 路 GUAYAN-2.0-DOMAIN锛圫table Relation Identity锛屾湭鍙戝竷锛?

> **闃舵鐩爣锛?* RelationInstance 鍙互閲嶅缓锛孯elationNote 涓嶈兘澶卞繂銆?
> 鍙仛鍥涗釜鏍稿績 Domain锛圚exagramCase / LineState / RelationInstance / RelationNote锛?
> 涓庣ǔ瀹氬叧绯昏韩浠?RelationKey锛屼笉鎵╄寖鍥淬€傝璁℃枃妗ｈ `lib/domain/README.md`銆?

### 鏂板鏂囦欢

| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/domain/hexagram_case.dart` | 鍗︿緥鎸佷箙鍖栨牴瀵硅薄锛堟渶灏忛鏋讹級 |
| `lib/domain/line_state.dart` | 涓€鐖荤姸鎬侊細鐖讳綅 / 鍔ㄩ潤 / 鎵€鍊煎湴鏀?|
| `lib/domain/line_endpoint.dart` | 鍏崇郴绔偣绋冲畾韬唤锛堝崷渚?+ 鐖讳綅锛?|
| `lib/domain/relation_type.dart` | 鍏崇郴绫诲瀷鏋氫妇 + 绯荤粺 RuleId 甯搁噺 |
| `lib/domain/relation_key.dart` | 鍏崇郴绋冲畾璇箟 key锛圫table Relation Identity 鏍稿績锛?|
| `lib/domain/relation_instance.dart` | 鍏蜂綋鍏崇郴瀹炰緥锛堥噸绠楀彲閲嶅缓锛?|
| `lib/domain/relation_calculator.dart` | 鏈€灏忕‘瀹氭€у叧绯昏绠楋紙鍔ㄥ彉/鍏啿/鍏悎锛?|
| `lib/domain/relation_note.dart` | 鍏崇郴绗旇锛坈aseId + RelationKey 缁戝畾锛?|
| `lib/domain/relation_note_store.dart` | 绗旇缁戝畾瀛樺偍锛堢函鍐呭瓨 + JSON 瀵煎叆瀵煎嚭锛?|
| `test/domain/domain_test_utils.dart` | 鍏变韩婕旂ず鍗︿緥锛堝姩鍙?+ 鍏啿锛?|
| `test/domain/relation_key_test.dart` | Test A 纭畾鎬?/ Test B 宸紓鎬?/ 鏂瑰悜澶勭悊 |
| `test/domain/relation_key_serialization_test.dart` | RelationKey JSON round-trip 涓庡睍绀哄悕瑙ｈ€?|
| `test/domain/relation_rebinding_test.dart` | Test C 閲嶇畻鎭㈠ / Test D 涓嶄覆绗旇 / Test E 椤哄簭鏃犲叧 |
| `test/domain/relation_serialization_test.dart` | T8 搴忓垪鍖?鈫?鍙嶅簭鍒楀寲 鈫?閲嶇畻 鈫?閲嶆柊缁戝畾鍏ㄩ摼 |
| `scripts/flutter.ps1` | 鏈満 Flutter 鍖呰鑴氭湰锛圓PPDATA/浠ｇ悊/鐩磋皟 snapshot锛?|

### 淇敼鏂囦欢

| 璺緞 | 璇存槑 |
| --- | --- |
| `lib/domain/README.md` | 鍗犱綅璇存槑 鈫?Stable Relation Identity 璁捐鏂囨。 |
| `file-tree.md` | 璁板綍 DOMAIN 闃舵鏂板鏂囦欢銆佺洰褰曟爲涓庤亴璐?|
| `CHANGELOG.md` | 鏈枃浠?|

### 楠岃瘉

- `flutter test`锛?*31/31 閫氳繃**锛?1 棰嗗煙 + 10 Foundation/Widget锛?
- `flutter analyze`锛氭湰杞柊澧炴枃浠?0 issue锛堝瓨閲忛仐鐣?21 椤?lint 璁板叆 BACKLOG锛?
- 鏈惎鍔?Android 妯℃嫙鍣紱鎵嬫満楠屾敹鍖呮瀯寤鸿鏋勫缓浜х墿
- RelationKey 缁勬垚锛氱被鍨嬫満鍣ㄥ悕 + RuleId + RuleVersion + subtype + 绔偣锛堝崷渚? 鐖讳綅锛夛紱
  鏈夊悜鍏崇郴淇濆簭锛圓鈫払 鈮?B鈫扐锛夛紝瀵圭О鍏崇郴鎺掑簭锛圓-B == B-A锛夛紱caseId 涓嶅叆 key锛岀瑪璁版寜
  `(caseId + RelationKey)` 缁戝畾銆?

---

## 2026-08-27 路 鎴愭灉褰掓。鎻愪氦锛堟湭鍙戝竷锛?

> **鑳屾櫙锛?* 寮€鍙戞満鍐呭瓨鑰楀敖宕╂簝閲嶅惎锛圙radle 鎻愪氦鍐呭瓨 errno 1455锛夛紝鍒ゅ畾鏈満鏆備笉鍏峰缁х画寮€鍙戞潯浠躲€?
> 涓洪伩鍏嶆垚鏋滀涪澶憋紝灏嗗伐浣滃尯鍏ㄩ儴鏈彁浜ゆ垚鏋滀竴娆℃€у綊妗ｆ彁浜わ紝骞舵帹閫?GitHub銆?
>
> 鎻愪氦锛歚feat: archive 2.0 training data layer, design assets and low-mem build config`
> 鍒嗘敮锛歚feat/guayan-2.0`锛堟帹閫佸悗涓庤繙绔悓姝ワ級

### 鏈鎻愪氦鏂囦欢瀹¤

| 璺緞 | 绫诲瀷 | 澶у皬 | 璇存槑 |
| --- | --- | --- | --- |
| `lib/data/training_question.dart` | 鏂板 | 586 B | 2.0 璁粌鏁版嵁妯″瀷锛歚TrainingModule` / `RelationType` / `TrainingQuestion` |
| `lib/data/wuxing_questions.dart` | 鏂板 | 3.0 KB | 浜旇鐢熷厠棰樺簱锛氱浉鐢?5 棰?+ 鐩稿厠 5 棰橈紙`allWuxingQuestions`锛?|
| `AGENTS.md` | 鏂板 | 2.1 KB | 椤圭洰浠ｇ爜瑙勫垯锛氭枃浠剁粍缁?/ 鏋舵瀯鍒嗗眰 / 鍛藉悕 / 鏂囨。绾緥 / 鐗堟湰涓庢瀯寤?|
| `CHANGELOG.md` | 鏂板 | 鏈枃浠?| 鏂囦欢瀹¤涓庡彉鏇存棩蹇?|
| `uploads/XYUI1ComponentDocumentView.axaml` | 鏂板 | 5.2 KB | 鍙傝€冭祫鏂欙細Avalonia 缁勪欢瑙嗗浘鏂囨。 |
| `uploads/鍗︾溂 2.0 路 鍏埢鎺掑崷銆佸叧绯诲彲瑙嗗寲銆佽嚜瀹氫箟瑙勫垯涓庡崷渚嬪鐩樻€诲紑鍙戣鍒?md` | 鏂板 | 20.9 KB | 鍙傝€冭祫鏂欙細鍗︾溂 2.0 鎬诲紑鍙戣鍒?|
| `浜旇鐩稿厠鐗规晥/閲戝厠鏈?html` | 鏂板 | 8.7 KB | 鐩稿厠鍔ㄧ敾鍘熷瀷锛氶噾鍏嬫湪 |
| `浜旇鐩稿厠鐗规晥/鏈ㄥ厠鍦?html` | 鏂板 | 7.0 KB | 鐩稿厠鍔ㄧ敾鍘熷瀷锛氭湪鍏嬪湡 |
| `浜旇鐩稿厠鐗规晥/鍦熷厠姘?html` | 鏂板 | 5.5 KB | 鐩稿厠鍔ㄧ敾鍘熷瀷锛氬湡鍏嬫按 |
| `浜旇鐩稿厠鐗规晥/姘村厠鐏?html` | 鏂板 | 10.2 KB | 鐩稿厠鍔ㄧ敾鍘熷瀷锛氭按鍏嬬伀 |
| `浜旇鐩稿厠鐗规晥/鐏厠閲?html` | 鏂板 | 8.1 KB | 鐩稿厠鍔ㄧ敾鍘熷瀷锛氱伀鍏嬮噾 |
| `浜旇鐩哥敓鐗规晥/閲戠敓姘?html` | 鏂板 | 6.8 KB | 鐩哥敓鍔ㄧ敾鍘熷瀷锛氶噾鐢熸按 |
| `浜旇鐩哥敓鐗规晥/姘寸敓鏈?html` | 鏂板 | 8.7 KB | 鐩哥敓鍔ㄧ敾鍘熷瀷锛氭按鐢熸湪 |
| `浜旇鐩哥敓鐗规晥/鏈ㄧ敓鐏?html` | 鏂板 | 5.9 KB | 鐩哥敓鍔ㄧ敾鍘熷瀷锛氭湪鐢熺伀 |
| `浜旇鐩哥敓鐗规晥/鐏敓鍦?html` | 鏂板 | 7.1 KB | 鐩哥敓鍔ㄧ敾鍘熷瀷锛氱伀鐢熷湡 |
| `浜旇鐩哥敓鐗规晥/鍦熺敓閲?html` | 鏂板 | 6.7 KB | 鐩哥敓鍔ㄧ敾鍘熷瀷锛氬湡鐢熼噾 |
| `android/gradle.properties` | 淇敼 | 鈥?| 浣庡唴瀛樼害鏉燂細JVM 鍫?`-Xmx1G`銆並otlin daemon `-Xmx256m`銆乣org.gradle.workers.max=1`锛岄伩鍏嶆瀯寤烘彁浜ゅ唴瀛樿€楀敖锛坋rrno 1455锛?|
| `file-tree.md` | 淇敼 | 鈥?| 鍚屾鏂板鏂囦欢銆佺洰褰曟爲銆佽亴璐ｈ〃涓庢渶鍚庣紪杈戞椂闂?|

### 鎻愪氦鍚庝粨搴撳揩鐓у璁?

- 璺熻釜鏂囦欢鏁帮細**109 鈫?125**锛?16锛?
- 椤跺眰鍒嗗竷锛歚lib/` 77 路 `android/` 19 路 `浜旇鐩稿厠鐗规晥/` 5 路 `浜旇鐩哥敓鐗规晥/` 5 路 `test/` 2 路 `memory/` 2 路 `uploads/` 2 路 鏍圭洰褰曟潅椤?13
- 鍒嗘敮鐘舵€侊細`feat/guayan-2.0`锛圚EAD = `b408199 feat: establish Guayan 2.0 foundation`锛岄鍏?`master` 1 涓彁浜わ紱`master` 涓?`origin/master` 鍚屾浜?`5c4bdb6`锛?
- 鏈窡韪?鏈彁浜ゅ唴瀹癸細鏃狅紙鍏ㄩ儴宸插綊妗ｏ級
- 澶у瀷鐩綍璇存槑锛歚build/`锛堢害 3 GB 鏋勫缓浜х墿锛変笌 `.dart_tool/` 鐢?`.gitignore` 鎺掗櫎锛屼笉鍏ュ簱

---

## 鐗堟湰鍘嗗彶鎽樿

| 鐗堟湰 | 鏃ユ湡 | 绫诲瀷 | 璇存槑 |
| --- | --- | --- | --- |
| `v0.1.10` | 2026-05-22 | 鏂板 | 鍏崇郴杩炶繛鐪嬶細25 缁勯厤瀵?+ 50 寮犲崱娑堥櫎 + 鍥炵倝 |
| `v0.1.9` | 2026-05-22 | 鏂板 | 鏂瑰潡閫熺瓟娓告垙妯℃澘锛屽崟棰樹笅钀?+ 璁℃椂 + 鍥炵倝 |
| `v0.1.8.3` | 2026-05-18 | 閲嶆瀯 | 鏃у叆鍙ｈ縼绉诲埌閫氱敤缁冧範妗嗘灦 |
| `v0.1.7.x` | 2026-05-18 | 鏂板/閲嶆瀯 | 浠ユ垜涓轰腑蹇冨涔犻〉銆佸渾鐩樼粨鏋勫崌绾с€佹椇鐩镐紤鍥氭 |
| `v0.1.6.x` | 2026-05-16 | 浼樺寲/淇 | 杞洏灏哄绋冲畾銆佷笁闃舵缁熻銆佸洖鐐夋潵婧愭爣绛?|
| `v0.1.5` | 2026-05-16 | 鏂板 | 浜旇鐩稿厠瀛︿範椤点€亀rongCount 淇銆佸洖鐐夊脊绐?|
| `v0.1.4.x` | 2026-05-16 | 鏂板/淇 | 鍥炵倝閿欓閲嶅仛绯荤粺銆佺浉鐢熺粌涔犱笁闃舵銆佺瓟棰樺弽棣堣壊 |
| `v0.1.3.x` | 2026-05-16 | 鏂板/浼樺寲 | 浜旀潯鐩哥敓 HTML 鍔ㄧ敾鎺ュ叆銆侀捇鏈ㄥ彇鐏€佽疆鐩樿妭濂忎紭鍖?|
| `v0.1.1` 鈥?`v0.1.2.x` | 2026-05-15 | 鍩虹 | 椤圭洰楠ㄦ灦涓庝簲琛屽熀纭€鍔熻兘 |

> 瀹屾暣鐗堟湰鍘嗗彶瑙?`file-tree.md` 绗?8 鑺傘€傛爣绛?v0.1.1 鈥?v0.1.10 鍧囧凡鎺ㄩ€?GitHub銆?


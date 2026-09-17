import 'package:guayan_trainer/domain/shensha/shensha_models.dart';

const goldenShenShaContext = ShenShaContext(
  yearGanZhi: '丙午',
  monthGanZhi: '丁酉',
  dayGanZhi: '癸巳',
  hourGanZhi: '壬戌',
  shiPosition: 4,
  shiIsYang: false,
);

const goldenDateMonthDayExpected = <String, String>{
  '驿马': '亥',
  '桃花': '午',
  '华盖': '丑',
  '贵人': '卯巳',
  '天禄': '子',
  '天喜': '辰',
  '天医': '申',
  '文昌': '卯',
  '劫煞': '寅',
  '灾煞': '卯',
  '金舆': '寅',
  '亡神': '申',
  '将星': '酉',
  '谋星': '未',
  '羊刃': '亥',
  '往亡': '子',
};

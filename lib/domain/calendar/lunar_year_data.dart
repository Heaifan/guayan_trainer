/// 农历换算所需的年度数据（2019–2029）。
///
/// 编码沿用传统 lunarInfo：低 4 位为闰月，0x10000 为闰月大月标记，
/// 0x8000..0x8 依次表示正月至腊月是否为大月。
const lunarYearInfo = <int, int>{
  2019: 0x0a930,
  2020: 0x07954,
  2021: 0x06aa0,
  2022: 0x0ad50,
  2023: 0x05b52,
  2024: 0x04b60,
  2025: 0x0a6e6,
  2026: 0x0a4e0,
  2027: 0x0d260,
  2028: 0x0ea65,
  2029: 0x0d530,
};

final lunarNewYear = <int, DateTime>{
  2019: DateTime.utc(2019, 2, 5),
  2020: DateTime.utc(2020, 1, 25),
  2021: DateTime.utc(2021, 2, 12),
  2022: DateTime.utc(2022, 2, 1),
  2023: DateTime.utc(2023, 1, 22),
  2024: DateTime.utc(2024, 2, 10),
  2025: DateTime.utc(2025, 1, 29),
  2026: DateTime.utc(2026, 2, 17),
  2027: DateTime.utc(2027, 2, 6),
  2028: DateTime.utc(2028, 1, 26),
  2029: DateTime.utc(2029, 2, 13),
};

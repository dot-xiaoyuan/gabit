import Foundation

extension Date {
    /// 获取日期的字符串表示 (yyyy-MM-dd)
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// 获取日期的中文表示 (月日)
    var chineseDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    /// 获取星期几的中文表示
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    /// 判断是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// 判断是否是昨天
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// 获取本周的开始日期
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// 获取本周的结束日期
    var endOfWeek: Date {
        let calendar = Calendar.current
        let startOfWeek = self.startOfWeek
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }
    
    /// 获取指定天数前的日期
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    /// 获取指定天数后的日期
    func daysAfter(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

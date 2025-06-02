import Foundation

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        let components1 = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date1)
        let components2 = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date2)
        return components1.yearForWeekOfYear == components2.yearForWeekOfYear &&
               components1.weekOfYear == components2.weekOfYear
    }
    
    func weekDateRange(for date: Date) -> String {
        let startOfWeek = self.startOfWeek(for: date)
        let endOfWeek = self.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        return "\(dateFormatter.string(from: startOfWeek)) - \(dateFormatter.string(from: endOfWeek))"
    }
    
    func monthDateRange(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
} 
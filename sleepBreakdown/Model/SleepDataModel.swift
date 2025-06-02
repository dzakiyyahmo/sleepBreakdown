import Foundation
import SwiftData

@Model
class SleepData {
    var date: Date
    var totalSleepDuration: TimeInterval
    var remSleepDuration: TimeInterval
    var coreSleepDuration: TimeInterval
    var deepSleepDuration: TimeInterval
    var awakeDuration: TimeInterval
    var sleepStart: Date?
    var sleepEnd: Date?
    
    init(date: Date, 
         totalSleepDuration: TimeInterval = 0,
         remSleepDuration: TimeInterval = 0,
         coreSleepDuration: TimeInterval = 0,
         deepSleepDuration: TimeInterval = 0,
         awakeDuration: TimeInterval = 0,
         sleepStart: Date? = nil,
         sleepEnd: Date? = nil) {
        self.date = date
        self.totalSleepDuration = totalSleepDuration
        self.remSleepDuration = remSleepDuration
        self.coreSleepDuration = coreSleepDuration
        self.deepSleepDuration = deepSleepDuration
        self.awakeDuration = awakeDuration
        self.sleepStart = sleepStart
        self.sleepEnd = sleepEnd
    }
} 
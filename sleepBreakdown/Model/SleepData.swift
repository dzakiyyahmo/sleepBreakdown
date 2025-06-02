import Foundation
import SwiftData

@Model
final class SleepData {
    var date: Date
    var totalSleepDuration: TimeInterval
    var remSleepDuration: TimeInterval
    var coreSleepDuration: TimeInterval
    var deepSleepDuration: TimeInterval
    var unspecifiedSleepDuration: TimeInterval
    var awakeDuration: TimeInterval
    var sleepStart: Date?
    var sleepEnd: Date?
    var restednessScore: Double
    var notes: String
    
    init(date: Date) {
        self.date = date
        self.totalSleepDuration = 0
        self.remSleepDuration = 0
        self.coreSleepDuration = 0
        self.deepSleepDuration = 0
        self.unspecifiedSleepDuration = 0
        self.awakeDuration = 0
        self.sleepStart = nil
        self.sleepEnd = nil
        self.restednessScore = 0
        self.notes = ""
    }
    
    init(date: Date, totalSleepDuration: TimeInterval, remSleepDuration: TimeInterval, coreSleepDuration: TimeInterval, deepSleepDuration: TimeInterval, awakeDuration: TimeInterval, unspecifiedSleepDuration: TimeInterval, sleepStart: Date?, sleepEnd: Date?, restednessScore: Double, notes: String) {
        self.date = date
        self.totalSleepDuration = totalSleepDuration
        self.remSleepDuration = remSleepDuration
        self.coreSleepDuration = coreSleepDuration
        self.deepSleepDuration = deepSleepDuration
        self.awakeDuration = awakeDuration
        self.unspecifiedSleepDuration = unspecifiedSleepDuration
        self.sleepStart = sleepStart
        self.sleepEnd = sleepEnd
        self.restednessScore = restednessScore
        self.notes = notes
    }
}

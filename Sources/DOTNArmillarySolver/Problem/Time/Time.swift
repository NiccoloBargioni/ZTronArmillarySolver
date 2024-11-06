import Foundation
import SwiftUI

final class Time: Hashable, CustomStringConvertible, ObservableObject, @unchecked Sendable {
    var description: String
    
    let hoursLock: DispatchSemaphore = .init(value: 1)
    let minutesLock: DispatchSemaphore = .init(value: 1)
    let secondsLock: DispatchSemaphore = .init(value: 1)
    let descriptionLock: DispatchSemaphore = .init(value: 1)

    @Published private var hour: Int
    @Published private var minute: Int
    @Published private var second: Int

    init(hour: Int, minute: Int, second: Int) {
        assert(hour >= 0 && minute >= 0 && second >= 0)
        self.hour = hour
        self.minute = minute
        self.second = second

        self.description = "\(hour):\(minute):\(second)"
    }

    convenience init(copy: Time) {
        copy.hoursLock.wait()
        copy.minutesLock.wait()
        copy.secondsLock.wait()
        self.init(hour: copy.hour, minute: copy.minute, second: copy.second)
        copy.secondsLock.signal()
        copy.minutesLock.signal()
        copy.hoursLock.signal()
    }
    
    func getHour() -> Int {
        self.hoursLock.wait()
        
        defer {
            self.hoursLock.signal()
        }
        
        return self.hour
    }

    func getMinute() -> Int {
        self.minutesLock.wait()
        
        defer {
            self.minutesLock.signal()
        }

        return self.minute
    }

    func getSecond() -> Int {
        self.secondsLock.wait()
        
        defer {
            self.secondsLock.signal()
        }

        return self.second
    }

    func setHour(_ hour: Int) {
        assert(hour >= 0 && hour <= 12)
        self.hoursLock.wait()
        self.hour = hour
        self.hoursLock.signal()
        
        self.updateDescription()
    }

    func setMinute(_ minute: Int) {
        assert(minute >= 0 && minute < 60)
        self.minutesLock.wait()
        self.minute = minute
        self.minutesLock.signal()
        
        self.updateDescription()
    }

    func setSecond(_ second: Int) {
        assert(second >= 0 && second < 60)
        self.secondsLock.wait()
        self.second = second
        self.secondsLock.signal()
        
        self.updateDescription()
    }

    func adding(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> Time {
        let hours = hours ?? 0
        let minutes = minutes ?? 0
        let seconds = seconds ?? 0

        self.hoursLock.wait()
        self.hour = (self.hour + hours + 12) % 12
        self.hoursLock.signal()
        
        self.minutesLock.wait()
        self.minute = (self.minute + minutes + 60) % 60
        self.minutesLock.signal()
        
        self.secondsLock.wait()
        self.second = (self.second + seconds + 60) % 60
        self.secondsLock.signal()

        self.updateDescription()
        
        return self
    }

    nonisolated public static func == (_ lhs: Time, _ rhs: Time) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
    }

    public func hash(into hasher: inout Hasher) {
        self.hoursLock.wait()
        self.minutesLock.wait()
        self.secondsLock.wait()
        hasher.combine(self.hour)
        hasher.combine(self.minute)
        hasher.combine(self.second)
        self.secondsLock.signal()
        self.minutesLock.signal()
        self.hoursLock.signal()
    }

    public func getImmutableCopy() -> ImmutableTime {
        self.hoursLock.wait()
        self.minutesLock.wait()
        self.secondsLock.wait()

        
        defer {
            self.secondsLock.signal()
            self.minutesLock.signal()
            self.hoursLock.signal()
        }
        
        return ImmutableTime(hour: self.hour, minute: self.minute, second: self.second)
    }
    
    private final func updateDescription() -> Void {
        self.descriptionLock.wait()
        self.secondsLock.wait()
        self.minutesLock.wait()
        self.hoursLock.wait()
                
        self.description = "\(hour):\(minute):\(second)"

        self.hoursLock.signal()
        self.minutesLock.signal()
        self.secondsLock.signal()
        self.descriptionLock.signal()
    }
}

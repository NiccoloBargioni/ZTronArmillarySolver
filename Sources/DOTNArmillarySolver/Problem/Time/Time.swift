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
        print(#function)
        assert(hour >= 0 && minute >= 0 && second >= 0)
        self.hour = hour
        self.minute = minute
        self.second = second

        self.description = "\(hour):\(minute):\(second)"
        print("End of \(#function)")
    }

    convenience init(copy: Time) {
        print(#function)
        copy.hoursLock.wait()
        copy.minutesLock.wait()
        copy.secondsLock.wait()
        self.init(hour: copy.hour, minute: copy.minute, second: copy.second)
        copy.secondsLock.signal()
        copy.minutesLock.signal()
        copy.hoursLock.signal()
        print("End of \(#function)")
    }
    
    func getHour() -> Int {
        print(#function)
        self.hoursLock.wait()
        
        defer {
            self.hoursLock.signal()
        }
        
        print("End of \(#function)")
        return self.hour
    }

    func getMinute() -> Int {
        print(#function)
        self.minutesLock.wait()
        
        defer {
            self.minutesLock.signal()
        }

        print("End of \(#function)")
        return self.minute
    }

    func getSecond() -> Int {
        print(#function)
        self.secondsLock.wait()
        
        defer {
            self.secondsLock.signal()
        }

        print("End of \(#function)")
        return self.second
    }

    func setHour(_ hour: Int) {
        print(#function)
        assert(hour >= 0 && hour <= 12)
        self.hoursLock.wait()
        self.hour = hour
        self.hoursLock.signal()
        
        self.updateDescription()
        print("End of \(#function)")
    }

    func setMinute(_ minute: Int) {
        print(#function)
        assert(minute >= 0 && minute < 60)
        self.minutesLock.wait()
        self.minute = minute
        self.minutesLock.signal()
        
        self.updateDescription()
        print("End of \(#function)")
    }

    func setSecond(_ second: Int) {
        print(#function)
        assert(second >= 0 && second < 60)
        self.secondsLock.wait()
        self.second = second
        self.secondsLock.signal()
        
        self.updateDescription()
        print("End of \(#function)")
    }

    func adding(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> Time {
        print(#function)
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
        
        print("End of \(#function)")
        return self
    }

    nonisolated public static func == (_ lhs: Time, _ rhs: Time) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
    }

    public func hash(into hasher: inout Hasher) {
        print(#function)
        self.hoursLock.wait()
        self.minutesLock.wait()
        self.secondsLock.wait()
        hasher.combine(self.hour)
        hasher.combine(self.minute)
        hasher.combine(self.second)
        self.secondsLock.signal()
        self.minutesLock.signal()
        self.hoursLock.signal()
        print("End of \(#function)")
    }

    public func getImmutableCopy() -> ImmutableTime {
        print(#function)
        self.hoursLock.wait()
        self.minutesLock.wait()
        self.secondsLock.wait()

        
        defer {
            self.secondsLock.signal()
            self.minutesLock.signal()
            self.hoursLock.signal()
        }
        
        print("End of \(#function)")
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

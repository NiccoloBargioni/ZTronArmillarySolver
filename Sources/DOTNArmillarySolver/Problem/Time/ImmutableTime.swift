import Foundation

final class ImmutableTime: AnyTime {
    private var hour: Int
    private var minute: Int
    private var second: Int

    init(hour: Int, minute: Int, second: Int) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    func getHour() -> Int {
        return self.hour
    }

    func getMinute() -> Int {
        return self.minute
    }

    func getSecond() -> Int {
        return self.second
    }

    func adding(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> ImmutableTime {
        let hours = hours ?? 0
        let minutes = minutes ?? 0
        let seconds = seconds ?? 0

        let newHour = (self.hour + hours + 12) % 12
        let newMinute = (self.minute + minutes + 60) % 60
        let newSeconds = (self.second + seconds + 60) % 60

        return ImmutableTime(hour: newHour, minute: newMinute, second: newSeconds)
    }

    public static func == (_ lhs: ImmutableTime, _ rhs: ImmutableTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hour)
        hasher.combine(self.minute)
        hasher.combine(self.second)
    }

    public func getMutableCopy() -> Time {
        return Time(hour: self.hour, minute: self.minute, second: self.second)
    }
}

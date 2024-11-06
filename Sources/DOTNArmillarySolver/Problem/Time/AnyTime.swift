import Foundation

protocol AnyTime: Hashable {
    func getMinute() -> Int
    func getHour() -> Int
    func getSecond() -> Int
    func adding(hours: Int?, minutes: Int?, seconds: Int?) -> Self
}

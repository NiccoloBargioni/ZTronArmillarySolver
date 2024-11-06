import Foundation

// swiftlint:disable identifier_name
extension Range where Bound: BinaryFloatingPoint {
    func lerp(_ t: Bound) -> Bound {
        return (1-t)*self.lowerBound + t*self.upperBound
    }
}

extension ClosedRange where Bound: BinaryFloatingPoint {
    func lerp(_ t: Bound) -> Bound {
        return (1-t)*self.lowerBound + t*self.upperBound
    }
}
// swiftlint:enable identifier_name

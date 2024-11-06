import Foundation

extension Double {
    func toDegrees() -> Double {
        return self * (180.0/Double.pi)
    }

    func toRadians() -> Double {
        return self * (Double.pi/180.0)
    }
}

extension Float {
    func toDegrees() -> Float {
        return self * (180.0/Float.pi)
    }

    func toRadians() -> Float {
        return self * (Float.pi/180.0)
    }

}

extension CGFloat {
    func toDegrees() -> CGFloat {
        return self * (180.0/CGFloat.pi)
    }

    func toRadians() -> CGFloat {
        return self * (CGFloat.pi/180.0)
    }
}

extension Int {
    func toDegrees() -> CGFloat {
        return CGFloat(self) * (180.0/CGFloat.pi)
    }

    func toRadians() -> CGFloat {
        return CGFloat(self) * (CGFloat.pi/180.0)
    }

}

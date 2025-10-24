import ZTronProblemSolver
import Foundation
import os
import Combine

public class AtlasProblemModel: ObservableObject, @unchecked Sendable {
    private static let logger: Logger = Logger(subsystem: "com.zombietron.atlas", category: "AtlasProblemModel")
    internal var currentTime: Time
    private var subscription: AnyCancellable?

    private let currentTimeLock: DispatchSemaphore = .init(value: 1)
    
    public init(currentTime: Time) {
        self.currentTime = currentTime
        self.subscription = self.currentTime.objectWillChange.receive(on: RunLoop.main).sink { @Sendable _ in
            Task(priority: .userInitiated) { @MainActor in
                self.objectWillChange.send()
            }
        }
    }

    func getTime() -> Time {
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        return Time.init(copy: self.currentTime)
    }

    func setTime(_ time: Time) {
        self.currentTimeLock.wait()
        self.currentTime = time
        self.currentTimeLock.signal()
    }

    func setHour(_ hour: Int) {
        assert(hour > 0 && hour <= 12)
        self.currentTimeLock.wait()
        self.currentTime.setHour(hour)
        self.currentTimeLock.signal()
    }

    func setMinute(_ minute: Int) {
        assert(minute >= 0 && minute < 60 && minute % 5 == 0)
        self.currentTimeLock.wait()
        self.currentTime.setMinute(minute)
        self.currentTimeLock.signal()
    }

    func setSecond(_ second: Int) {
        assert(second >= 0 && second < 60 && second % 5 == 0)
        self.currentTimeLock.wait()
        self.currentTime.setSecond(second)
        self.currentTimeLock.signal()
    }

    func getHour() -> Int {
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        return self.currentTime.getHour()
    }

    func getMinute() -> Int {
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }

        return self.currentTime.getMinute()
    }

    func getSecond() -> Int {
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        return self.currentTime.getSecond()
    }

    func solve() -> [AtlasButton: Int] {
        let agent = ProblemSolvingAgent<ImmutableTime, AtlasButton>(
            strategy: BFS()
        )

        self.currentTimeLock.wait()
        let problem = AtlasProblem(initialState: self.currentTime.getImmutableCopy())
        self.currentTimeLock.signal()
        
        guard let solution = try? agent.solve(problem: problem) else {
            #if DEBUG
            Self.logger.error("No solution exists for initial time \(self.currentTime)")
            #endif
            fatalError()
        }

        var outputSolution: [AtlasButton: Int] = [:]

        solution.forEach { solutionBit in
            if outputSolution[solutionBit] == nil {
                outputSolution[solutionBit] = 0
            }

            outputSolution[solutionBit]! += 1
        }

        return outputSolution
    }

    deinit {
        self.subscription = nil
    }

}

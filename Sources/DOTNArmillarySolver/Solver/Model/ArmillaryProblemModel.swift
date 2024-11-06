import ZTronProblemSolver
import Foundation
import os
import Combine

class AtlasProblemModel: ObservableObject, @unchecked Sendable {
    private static let logger: Logger = Logger(subsystem: "com.zombietron.atlas", category: "AtlasProblemModel")
    internal var currentTime: Time
    private var subscription: AnyCancellable?

    private let currentTimeLock: DispatchSemaphore = .init(value: 1)
    
    init(currentTime: Time) {
        print(#function)
        self.currentTime = currentTime
        self.subscription = self.currentTime.objectWillChange.receive(on: RunLoop.main).sink { @Sendable _ in
            Task(priority: .userInitiated) { @MainActor in
                self.objectWillChange.send()
            }
        }
        print("End of \(#function)")
    }

    func getTime() -> Time {
        print(#function)
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        print("End of \(#function)")
        return Time.init(copy: self.currentTime)
    }

    func setTime(_ time: Time) {
        print(#function)
        self.currentTimeLock.wait()
        self.currentTime = time
        self.currentTimeLock.signal()
        print("End of \(#function)")
    }

    func setHour(_ hour: Int) {
        print(#function)
        assert(hour > 0 && hour <= 12)
        self.currentTimeLock.wait()
        self.currentTime.setHour(hour)
        self.currentTimeLock.signal()
        print("End of \(#function)")
    }

    func setMinute(_ minute: Int) {
        assert(minute >= 0 && minute < 60 && minute % 5 == 0)
        print(#function)
        self.currentTimeLock.wait()
        self.currentTime.setMinute(minute)
        self.currentTimeLock.signal()
        print("End of \(#function)")
    }

    func setSecond(_ second: Int) {
        print(#function)
        assert(second >= 0 && second < 60 && second % 5 == 0)
        self.currentTimeLock.wait()
        self.currentTime.setSecond(second)
        self.currentTimeLock.signal()
        print("End of \(#function)")
    }

    func getHour() -> Int {
        print(#function)

        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        print("End of \(#function)")
        return self.currentTime.getHour()
    }

    func getMinute() -> Int {
        print(#function)
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }

        print("End of \(#function)")
        return self.currentTime.getMinute()
    }

    func getSecond() -> Int {
        print(#function)
        self.currentTimeLock.wait()
        
        defer {
            self.currentTimeLock.signal()
        }
        
        print("End of \(#function)")
        return self.currentTime.getSecond()
    }

    func solve() -> [AtlasButton: Int] {
        print(#function)
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

        print("End of \(#function)")
        return outputSolution
    }

    deinit {
        self.subscription = nil
    }

}

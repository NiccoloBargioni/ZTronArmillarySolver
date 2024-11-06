import ZTronProblemSolver

// swiftlint:disable identifier_name
internal enum AtlasButton: String {
    case LB
    case LF
    case MB
    case MF
    case RB
    case RF
    
    static func fromIndex(_ i: Int) -> AtlasButton {
        assert(i >= 0 && i < 6)
        return [.LB, .LF, .MB, .MF, .RB, .RF][i]
    }
}
// swiftlint:enable identifier_name

internal class AtlasProblem: Problem<ImmutableTime, AtlasButton> {
    private var initialState: ImmutableTime

    init(initialState: ImmutableTime) {
        self.initialState = initialState
        super.init()
    }

    override func getInitialState() throws -> ImmutableTime {
        return self.initialState
    }

    override func getAvailableActions(node: SearchNode<ImmutableTime, AtlasButton>) throws -> [AtlasButton] {
        return [.LB, .LF, .MB, .MF, .RB, .RF]
    }

    override func getResult(action: AtlasButton, node: SearchNode<ImmutableTime, AtlasButton>) throws -> ImmutableTime {
        return self.actions[action]!(node.getState())
    }

    override func isGoal(state: ImmutableTime) throws -> Bool {
        return state.getHour() == 10 && state.getMinute() == 5 && state.getSecond() == 40
    }

    override func getCost(action: AtlasButton, state: ImmutableTime) throws -> Float {
        return 1
    }

    private let actions: [AtlasButton: (_: ImmutableTime) -> ImmutableTime] = [
        .LB: { time in
            return time.adding(hours: 1, minutes: -5)
        },

        .LF: { time in
            return time.adding(hours: -1, minutes: 5)
        },

        .MB: { time in
            return time.adding(hours: -1, minutes: 5, seconds: -5)
        },

        .MF: { time in
            return time.adding(hours: 1, minutes: -5, seconds: 5)
        },

        .RB: { time in
            return time.adding(minutes: 5, seconds: 5)
        },

        .RF: { time in
            return time.adding(minutes: -5, seconds: -5)
        }
    ]
}

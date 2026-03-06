public struct FilterLayer: Hashable, Sendable {
    public let region: Rect
    public let primitives: [FilterPrimitive]

    public init(region: Rect, primitives: [FilterPrimitive]) {
        self.region = region
        self.primitives = primitives
    }
}

public struct FilterPrimitive: Hashable, Sendable {
    public let effect: FilterEffect
    public let input: FilterInput
    public let input2: FilterInput?
    public let result: String?
    public let subregion: Rect?

    public init(
        effect: FilterEffect,
        input: FilterInput = .sourceGraphic,
        input2: FilterInput? = nil,
        result: String? = nil,
        subregion: Rect? = nil
    ) {
        self.effect = effect
        self.input = input
        self.input2 = input2
        self.result = result
        self.subregion = subregion
    }
}

public enum FilterInput: Hashable, Sendable {
    case sourceGraphic
    case sourceAlpha
    case named(String)
}

public enum FilterEffect: Hashable, Sendable {
    case gaussianBlur(stdDeviationX: Double, stdDeviationY: Double)
    case offset(dx: Double, dy: Double)
    case flood(color: Color, opacity: Double)
    case blend(mode: FilterBlendMode)
    case composite(operator: FilterCompositeOperator, k1: Double, k2: Double, k3: Double, k4: Double)
    case merge(inputs: [FilterInput])
    case colorMatrix(type: ColorMatrixType, values: [Double])
}

public enum FilterBlendMode: String, Hashable, Sendable {
    case normal
    case multiply
    case screen
    case darken
    case lighten
}

public enum FilterCompositeOperator: String, Hashable, Sendable {
    case over
    case `in`
    case out
    case atop
    case xor
    case arithmetic
}

public enum ColorMatrixType: String, Hashable, Sendable {
    case matrix
    case saturate
    case hueRotate
    case luminanceToAlpha
}

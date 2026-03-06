import Foundation

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
    case morphology(operator: MorphologyOperator, radiusX: Double, radiusY: Double)
    case convolveMatrix(orderRows: Int, orderCols: Int, kernel: [Double], divisor: Double, bias: Double, targetX: Int, targetY: Int, edgeMode: ConvolveEdgeMode, preserveAlpha: Bool)
    case tile
    case displacementMap(scale: Double, xChannelSelector: ChannelSelector, yChannelSelector: ChannelSelector)
    case turbulence(type: TurbulenceType, baseFrequencyX: Double, baseFrequencyY: Double, numOctaves: Int, seed: Double)
    case filterImage(imageData: Data)
    case componentTransfer(funcR: TransferFunction, funcG: TransferFunction, funcB: TransferFunction, funcA: TransferFunction)
    case diffuseLighting(surfaceScale: Double, diffuseConstant: Double, lightSource: LightSource)
    case specularLighting(surfaceScale: Double, specularConstant: Double, specularExponent: Double, lightSource: LightSource)
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

public enum MorphologyOperator: String, Hashable, Sendable {
    case erode
    case dilate
}

public enum ConvolveEdgeMode: String, Hashable, Sendable {
    case duplicate
    case wrap
    case none
}

public enum ChannelSelector: String, Hashable, Sendable {
    case r = "R"
    case g = "G"
    case b = "B"
    case a = "A"
}

public enum TurbulenceType: String, Hashable, Sendable {
    case turbulence
    case fractalNoise
}

public enum TransferFunctionType: String, Hashable, Sendable {
    case identity
    case table
    case discrete
    case linear
    case gamma
}

public struct TransferFunction: Hashable, Sendable {
    public let type: TransferFunctionType
    public let tableValues: [Double]
    public let slope: Double
    public let intercept: Double
    public let amplitude: Double
    public let exponent: Double
    public let offset: Double

    public init(
        type: TransferFunctionType = .identity,
        tableValues: [Double] = [],
        slope: Double = 1,
        intercept: Double = 0,
        amplitude: Double = 1,
        exponent: Double = 1,
        offset: Double = 0
    ) {
        self.type = type
        self.tableValues = tableValues
        self.slope = slope
        self.intercept = intercept
        self.amplitude = amplitude
        self.exponent = exponent
        self.offset = offset
    }
}

public enum LightSource: Hashable, Sendable {
    case distantLight(azimuth: Double, elevation: Double)
    case pointLight(x: Double, y: Double, z: Double)
    case spotLight(x: Double, y: Double, z: Double, pointsAtX: Double, pointsAtY: Double, pointsAtZ: Double, specularExponent: Double, limitingConeAngle: Double?)
}

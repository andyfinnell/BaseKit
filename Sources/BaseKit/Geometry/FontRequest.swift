/// An unresolved request for a font face. Producers (e.g. an SVG layout
/// engine) describe the face they want in primitive terms; the rendering
/// layer is responsible for translating it into a concrete platform font
/// (`CTFont` / `NSFont` / `UIFont`).
///
/// Carries only primitive data so the producer doesn't have to depend on
/// CoreText. Fields mirror CSS / SVG font properties:
///
/// - `families` is the font-family fallback list as authored (may contain
///   CSS generic keywords like `"serif"`, `"sans-serif"`, etc.). The
///   resolver expands generics.
/// - `weight` is the numeric CSS weight (100–900; 400 = normal, 700 =
///   bold).
/// - `italic` is true for `font-style: italic` or `oblique`.
/// - `widthTrait` is the CoreText-style stretch value in `[-1.0, +1.0]`.
///   `nil` means "no width override" (normal). Producers can pre-compute
///   this from CSS keywords (`ultra-condensed = -1`, `expanded = +0.5`,
///   etc.).
/// - `smallCaps` is true for `font-variant: small-caps`.
/// - `sizeAdjustAspect` is the SVG `font-size-adjust` aspect ratio
///   (x-height ÷ font-size). When set, the renderer scales the rendered
///   size so the resolved font's x-height matches the requested ratio.
/// - `pointSize` is the requested font size before any `sizeAdjustAspect`
///   correction.
public struct FontRequest: Hashable, Codable, Sendable {
    public let families: [String]
    public let weight: Double
    public let italic: Bool
    public let widthTrait: Double?
    public let smallCaps: Bool
    public let sizeAdjustAspect: Double?
    public let pointSize: Double

    public init(
        families: [String],
        weight: Double = 400,
        italic: Bool = false,
        widthTrait: Double? = nil,
        smallCaps: Bool = false,
        sizeAdjustAspect: Double? = nil,
        pointSize: Double
    ) {
        self.families = families
        self.weight = weight
        self.italic = italic
        self.widthTrait = widthTrait
        self.smallCaps = smallCaps
        self.sizeAdjustAspect = sizeAdjustAspect
        self.pointSize = pointSize
    }
}

extension FontRequest {
    /// A request for a specific resolved face name at a given size — the
    /// shortcut for HUD overlays / non-SVG callers that already know the
    /// exact PostScript name they want.
    public static func resolved(name: String, size: Double) -> FontRequest {
        FontRequest(families: [name], pointSize: size)
    }
}

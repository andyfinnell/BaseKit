public struct TextRun: Hashable, Codable, Sendable {
    public enum Attribute: Hashable, Codable, Sendable {
        /// A pre-resolved font face by PostScript name. Used by callers
        /// that bypass the full font-matching pipeline (HUD overlays,
        /// editor round-trips). Paired with `.fontSize`.
        case fontName(String)
        /// Point size paired with `.fontName`. Ignored when the run
        /// carries a `.fontRequest`.
        case fontSize(Double)
        /// A font face described by family + traits + size. The renderer
        /// is responsible for resolving this to a platform font. SVG
        /// layout emits this; carries enough state to handle font
        /// fallback, stretch, variant, and `font-size-adjust` without
        /// the producer touching CoreText.
        case fontRequest(FontRequest)
        case textAlign(TextAlignment)
        case letterSpacing(Double)
        case wordSpacing(Double)
    }

    public let text: String
    public let attributes: [Attribute]
    public let decorations: [Decoration]?
    public let textDecorationLines: TextDecorationLine?
    public let dx: Double
    public let dy: Double
    /// Per-run baseline shift in user units, SVG-y-down (positive =
    /// visually down). Distinct from `dy`: this offset is applied only
    /// to this run's glyphs and does NOT advance the current text
    /// position for subsequent runs. Carries the resolved sum of SVG's
    /// `baseline-shift` and `alignment-baseline` per spec §10.9.2.
    public let baselineShift: Double

    public init(
        text: String,
        attributes: [Attribute],
        decorations: [Decoration]? = nil,
        textDecorationLines: TextDecorationLine? = nil,
        dx: Double = 0,
        dy: Double = 0,
        baselineShift: Double = 0
    ) {
        self.text = text
        self.attributes = attributes
        self.decorations = decorations
        self.textDecorationLines = textDecorationLines
        self.dx = dx
        self.dy = dy
        self.baselineShift = baselineShift
    }
}

extension TextRun {
    public var needsPerRunRendering: Bool {
        decorations != nil || textDecorationLines != nil || dx != 0 || dy != 0
            || baselineShift != 0
    }
}

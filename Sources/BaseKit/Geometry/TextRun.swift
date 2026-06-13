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
    /// Absolute per-glyph positions in the TextLayer's local user
    /// space (SVG-y-down, same convention as `dy` and
    /// `TextLayer.position`). Indexed by glyph in the run's CTRun
    /// iteration order. When set, callers MUST disable ligatures upstream
    /// so glyph-index aligns 1:1 with character-index within the run —
    /// per SVG 1.1 §10.5, explicit per-character positioning breaks
    /// ligatures.
    ///
    /// Outer nil = no per-glyph data on this run (fast framesetter
    /// path applies). Inner nil at index `i` = that glyph uses its
    /// natural CT advance instead of an explicit position. When any
    /// run in a TextLayer sets this (or `perGlyphRotations`), the
    /// entire layer renders via the per-glyph composition path.
    public let perGlyphOffsets: [Point?]?
    /// Per-glyph rotations in radians, SVG sense (positive = clockwise
    /// visually, matching SVG `rotate=`). Rotation is around the
    /// glyph's own origin (baseline-left). Indexing and nil semantics
    /// mirror `perGlyphOffsets`.
    public let perGlyphRotations: [Double?]?

    public init(
        text: String,
        attributes: [Attribute],
        decorations: [Decoration]? = nil,
        textDecorationLines: TextDecorationLine? = nil,
        dx: Double = 0,
        dy: Double = 0,
        baselineShift: Double = 0,
        perGlyphOffsets: [Point?]? = nil,
        perGlyphRotations: [Double?]? = nil
    ) {
        self.text = text
        self.attributes = attributes
        self.decorations = decorations
        self.textDecorationLines = textDecorationLines
        self.dx = dx
        self.dy = dy
        self.baselineShift = baselineShift
        self.perGlyphOffsets = perGlyphOffsets
        self.perGlyphRotations = perGlyphRotations
    }
}

extension TextRun {
    public var needsPerRunRendering: Bool {
        decorations != nil || textDecorationLines != nil || dx != 0 || dy != 0
            || baselineShift != 0
    }

    /// True when this run carries explicit per-glyph position or
    /// rotation data. Any such run forces the entire TextLayer onto
    /// the per-glyph composition path (mixing with the framesetter's
    /// natural layout in one layer is not supported).
    public var needsPerGlyphRendering: Bool {
        perGlyphOffsets != nil || perGlyphRotations != nil
    }
}

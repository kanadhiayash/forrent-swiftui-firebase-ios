import SwiftUI
import UIKit
import XCTest
@testable import For_Rent

final class ForRentThemeTests: XCTestCase {
    func test_brandColorsMatchApprovedPalette() {
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Brand.navy), RGB(0x0A, 0x1A, 0x3A))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Brand.royalBlue), RGB(0x25, 0x63, 0xEB))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Brand.teal), RGB(0x10, 0xB9, 0x81))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Brand.lightGray), RGB(0xF2, 0xF4, 0xF7))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Brand.white), RGB(0xFF, 0xFF, 0xFF))
    }

    func test_semanticCanvasAndTextResolveForLightAndDark() {
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.canvas, style: .light), RGB(0xFF, 0xFF, 0xFF))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.canvas, style: .dark), RGB(0x07, 0x12, 0x25))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.textPrimary, style: .light), RGB(0x0A, 0x1A, 0x3A))
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.textPrimary, style: .dark), RGB(0xF8, 0xFA, 0xFC))
    }

    func test_primaryActionUsesApprovedRoyalBlue() {
        let approvedRoyalBlue = RGB(0x25, 0x63, 0xEB)

        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.actionPrimary, style: .light), approvedRoyalBlue)
        XCTAssertEqual(rgbComponents(for: ForRentTheme.Colors.actionPrimary, style: .dark), approvedRoyalBlue)
    }

    func test_semanticColorsAreNotClear() {
        let colors = [
            ForRentTheme.Colors.canvas,
            ForRentTheme.Colors.surface,
            ForRentTheme.Colors.surfaceSubtle,
            ForRentTheme.Colors.surfaceRaised,
            ForRentTheme.Colors.surfaceSelected,
            ForRentTheme.Colors.textPrimary,
            ForRentTheme.Colors.textSecondary,
            ForRentTheme.Colors.textMuted,
            ForRentTheme.Colors.border,
            ForRentTheme.Colors.separator,
            ForRentTheme.Colors.actionPrimary,
            ForRentTheme.Colors.actionPressed,
            ForRentTheme.Colors.link,
            ForRentTheme.Colors.focus,
            ForRentTheme.Colors.success,
            ForRentTheme.Colors.successSurface,
            ForRentTheme.Colors.warning,
            ForRentTheme.Colors.warningSurface,
            ForRentTheme.Colors.destructive,
            ForRentTheme.Colors.destructiveSurface
        ]

        for color in colors {
            XCTAssertGreaterThan(alpha(for: color, style: .light), 0)
            XCTAssertGreaterThan(alpha(for: color, style: .dark), 0)
        }
    }

    private func rgbComponents(
        for color: Color,
        style: UIUserInterfaceStyle = .light,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> RGB {
        let resolvedColor = UIColor(color).resolvedColor(
            with: UITraitCollection(userInterfaceStyle: style)
        )
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        XCTAssertTrue(
            resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha),
            "Expected sRGB color",
            file: file,
            line: line
        )

        return RGB(
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255))
        )
    }

    private func alpha(for color: Color, style: UIUserInterfaceStyle) -> CGFloat {
        let resolvedColor = UIColor(color).resolvedColor(
            with: UITraitCollection(userInterfaceStyle: style)
        )
        var alpha: CGFloat = 0

        XCTAssertTrue(resolvedColor.getRed(nil, green: nil, blue: nil, alpha: &alpha))
        return alpha
    }
}

private struct RGB: Equatable {
    let red: Int
    let green: Int
    let blue: Int

    init(_ red: Int, _ green: Int, _ blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

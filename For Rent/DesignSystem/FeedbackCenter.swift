import SwiftUI
import Combine

struct AppFeedback: Equatable, Identifiable {
    enum Tone {
        case success
        case information
        case warning
        case error
    }

    let id = UUID()
    let message: String
    let tone: Tone

    static func success(_ message: String) -> AppFeedback {
        AppFeedback(message: message, tone: .success)
    }

    static func error(_ message: String) -> AppFeedback {
        AppFeedback(message: message, tone: .error)
    }
}

@MainActor
final class FeedbackCenter: ObservableObject {
    @Published private(set) var current: AppFeedback?

    func show(_ feedback: AppFeedback) {
        current = feedback
    }

    func dismiss() {
        current = nil
    }
}

struct FeedbackHost: ViewModifier {
    @EnvironmentObject private var feedbackCenter: FeedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let feedback = feedbackCenter.current {
                    FeedbackToast(feedback: feedback)
                        .padding(.horizontal, ForRentTheme.Spacing.md)
                        .padding(.top, ForRentTheme.Spacing.xs)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                        .task(id: feedback.id) {
                            try? await Task.sleep(for: .seconds(3))
                            guard feedbackCenter.current?.id == feedback.id else { return }
                            withAnimation(.easeOut(duration: ForRentTheme.Motion.standard)) {
                                feedbackCenter.dismiss()
                            }
                        }
                }
            }
            .animation(
                reduceMotion ? nil : .easeOut(duration: ForRentTheme.Motion.standard),
                value: feedbackCenter.current
            )
    }
}

private struct FeedbackToast: View {
    let feedback: AppFeedback

    var body: some View {
        HStack(spacing: ForRentTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.headline)

            Text(feedback.message)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(foreground)
        .padding(ForRentTheme.Spacing.md)
        .background(background, in: RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))
        .overlay(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.control)
                .stroke(foreground.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }

    private var icon: String {
        switch feedback.tone {
        case .success: "checkmark.circle.fill"
        case .information: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        }
    }

    private var foreground: Color {
        switch feedback.tone {
        case .success: ForRentTheme.Colors.forest
        case .information: ForRentTheme.Colors.primary
        case .warning: ForRentTheme.Colors.ink
        case .error: ForRentTheme.Colors.coral
        }
    }

    private var background: Color {
        switch feedback.tone {
        case .success: ForRentTheme.Colors.mint
        case .information: ForRentTheme.Colors.surfaceStrong
        case .warning: ForRentTheme.Colors.yellow
        case .error: ForRentTheme.Colors.peach
        }
    }
}

extension View {
    func feedbackHost() -> some View {
        modifier(FeedbackHost())
    }
}

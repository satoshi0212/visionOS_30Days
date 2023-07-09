import SwiftUI

extension View {

    func typeText(
        text: Binding<String>,
        finalText: String,
        isFinished: Binding<Bool>,
        cursor: String = "|",
        isAnimated: Bool = true
    ) -> some View {
        self.modifier(
            TypeTextModifier(
                text: text,
                finalText: finalText,
                isFinished: isFinished,
                cursor: cursor,
                isAnimated: isAnimated
            )
        )
    }
}

private struct TypeTextModifier: ViewModifier {
    @Binding var text: String
    var finalText: String
    @Binding var isFinished: Bool
    var cursor: String
    var isAnimated: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isAnimated == false {
                    text = finalText
                    isFinished = true
                }
            }
            .task {
                guard isAnimated else { return }

                // Blink the cursor a few times.
                for _ in 1 ... 2 {
                    text = cursor
                    try? await Task.sleep(for: .milliseconds(500))
                    text = ""
                    try? await Task.sleep(for: .milliseconds(200))
                }

                // Type out the title.
                for index in finalText.indices {
                    text = String(finalText.prefix(through: index)) + cursor
                    let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * 100
                    try? await Task.sleep(for: .milliseconds(milliseconds))
                }

                // Wrap up the title sequence.
                try? await Task.sleep(for: .milliseconds(400))
                text = finalText
                isFinished = true
            }
    }
}

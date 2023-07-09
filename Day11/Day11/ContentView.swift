import SwiftUI
import RealityKit

struct ContentView: View {

    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            VStack {
                Spacer()

                VStack {
                    Text(model.finalTitle)
                        .monospaced()
                        .font(.system(size: 50, weight: .bold))
                        .padding(.horizontal, 40)
                        .hidden()
                        .overlay(alignment: .leading) {
                            Text(model.titleText)
                                .monospaced()
                                .font(.system(size: 50, weight: .bold))
                                .padding(.leading, 40)
                        }
                    Text("詳細はフェードイン")
                        .font(.title)
                        .opacity(model.isTitleFinished ? 1 : 0)
                }

                Spacer()
            }
            .typeText(
                text: $model.titleText,
                finalText: model.finalTitle,
                isFinished: $model.isTitleFinished,
                isAnimated: !model.isTitleFinished)
            .animation(.default.speed(0.25), value: model.isTitleFinished)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .environment(ViewModel())
    }
}

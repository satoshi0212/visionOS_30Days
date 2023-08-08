import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var viewModel: ViewModel

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
            let textEntities = viewModel.spawnText(text: "Fetching Slack...", color: .blue)
            Task{
                await viewModel.removeTextEntities(textEntities: textEntities)
            }
        }
        .onChange(of: viewModel.messages, { oldValue, newValue in
            let newMessages = viewModel.filterNewMessages(oldMessages: oldValue, newMessages: newValue)
            print(newMessages)
            for message in newMessages {
                let textEntities = viewModel.spawnText(text: message)
                Task{
                    await viewModel.removeTextEntities(textEntities: textEntities)
                }
            }
        })
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}

import SwiftUI

struct LogView: View, Identifiable {

    var id = UUID()
    var viewModel: ViewModel

    var body: some View {
        VStack {
            List(viewModel.messages, id: \.self) { message in
                Text(message)
                    .font(.title)
                    .foregroundColor(.mint)
                    .shadow(color: Color.black.opacity(0.5), radius: 0.5, x: 3, y: 3)
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .allowsHitTesting(false)
    }
}

#Preview {
    LogView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}

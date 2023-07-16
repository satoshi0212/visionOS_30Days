import SwiftUI

struct HomeView: View {

    @Environment(ViewModel.self) private var model

    var body: some View {

        @Bindable var model = model

        TabView(selection: $model.selectedType) {
            ForEach(ViewModel.SelectionType.allCases) { selectionType in
                ContentView()
                    .environment(model)
                    .tag(selectionType)
                    .tabItem {
                        Label(selectionType.title, systemImage: selectionType.imageName)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ViewModel())
}

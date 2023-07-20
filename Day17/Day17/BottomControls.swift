import SwiftUI

struct BottomControls: View {

    var viewModel: ViewModel

    @State private var isPickerVisible: Bool = false

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .scaleButtonGuide) {
            HStack(spacing: 17) {
                Toggle(isOn: $viewModel.isTransparent) {
                    Label("Transparent", systemImage: "cube.transparent")
                }
                .help("Transparent")

                Toggle(isOn: $isPickerVisible) {
                    Label("Scale", systemImage: "scale.3d")
                }
                .help("Scale")
                .alignmentGuide(.scaleButtonGuide) { context in
                    context[HorizontalAlignment.center]
                }
            }
            .toggleStyle(.button)
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
            .padding(12)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
            .alignmentGuide(.controlPanelGuide) { context in
                context[HorizontalAlignment.center]
            }
            ScalePicker(viewModel: viewModel, isVisible: $isPickerVisible)
                .alignmentGuide(.scaleButtonGuide) { context in
                    context[HorizontalAlignment.center]
                }
        }
        .onChange(of: viewModel.isTransparent) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.updateTransparency()
            }
        }
        .onChange(of: viewModel.selectedScale) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.updateScale()
            }
        }
    }
}

private struct ScalePicker: View {

    var viewModel: ViewModel

    @Binding var isVisible: Bool

    var body: some View {
        Grid(alignment: .leading) {
            Text("Scale")
                .font(.title)
                .padding(.top, 5)
                .gridCellAnchor(.center)
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            ForEach(Scales.allCases) { scale in
                GridRow {
                    Button {
                        viewModel.selectedScale = scale
                        isVisible = false
                    } label: {
                        Text(scale.name)
                    }
                    .buttonStyle(.borderless)

                    Image(systemName: "checkmark")
                        .opacity(scale == viewModel.selectedScale ? 1 : 0)
                }
            }
        }
        .padding(12)
        .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        .opacity(isVisible ? 1 : 0)
        .animation(.default.speed(2), value: isVisible)
    }
}

extension HorizontalAlignment {
    private struct ControlPanelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    static let controlPanelGuide = HorizontalAlignment(
        ControlPanelAlignment.self
    )
}

extension HorizontalAlignment {

    private struct ScaleButtonAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    fileprivate static let scaleButtonGuide = HorizontalAlignment(
        ScaleButtonAlignment.self
    )
}

#Preview {
    BottomControls(viewModel: ViewModel())
}

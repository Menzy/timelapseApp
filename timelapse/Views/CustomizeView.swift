import SwiftUI

struct CustomizeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: DisplaySettings
    @State private var showingColorPicker = false
    @EnvironmentObject var globalSettings: GlobalSettings // Use global settings
    
    var body: some View {
        NavigationView {
            Form {
                Section("Display Style") {
                    Picker("Style", selection: $settings.style) {
                        ForEach(TimeDisplayStyle.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                    
                    if settings.style == .grid {
                        Picker("Grid Shape", selection: $globalSettings.gridShape) {
                            ForEach(GridShape.allCases, id: \.self) { shape in
                                Text(shape.rawValue.capitalized).tag(shape)
                            }
                        }
                    }
                    
                    Picker("Color", selection: $settings.displayColor) {
                        ForEach(DisplayColor.getPresets(for: globalSettings.backgroundStyle)) { preset in
                            HStack {
                                Circle()
                                    .fill(preset.color)
                                    .frame(width: 20, height: 20)
                                Text(preset.name)
                            }
                            .tag(preset.color)
                        }
                    }
                    .onChange(of: settings.displayColor) { oldValue, newValue in
                        // Update isUsingDefaultColor based on selection
                        let defaultColor = globalSettings.backgroundStyle == .light ? Color.black : Color.white
                        settings.isUsingDefaultColor = (newValue == defaultColor)
                    }
                    .onChange(of: settings.style) { oldStyle, newStyle in
                        // Ensure color persists when changing styles
                        if !settings.isUsingDefaultColor {
                            settings.displayColor = settings.displayColor
                        }
                    }
                }
                
                Section("Background Style") {
                    Picker("Background", selection: $globalSettings.backgroundStyle) { // Modify global settings
                        ForEach(BackgroundStyle.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                    .onChange(of: globalSettings.backgroundStyle) { oldStyle, newStyle in
                        settings.updateColor(for: newStyle)
                    }
                }
                
                Section("Counter Type") {
                    Toggle("Show Percentage", isOn: $settings.showPercentage)
                }
            }
            .navigationTitle("Customize")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

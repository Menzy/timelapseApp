import SwiftUI

enum TimeDisplayStyle: String, CaseIterable, Codable {
    case grid
    case circle
    case progressBar
    case boldText
}

enum GridShape: String, CaseIterable {
    case circle
    case square
    case roundedRectangle
}

enum BackgroundStyle: String, CaseIterable, Codable {
    case light
    case dark
    case device
}

struct DisplayColor: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    
    static func getPresets(for backgroundStyle: BackgroundStyle) -> [DisplayColor] {
        let defaultColor: Color = backgroundStyle == .light ? .black : .white
        let defaultColorName = backgroundStyle == .light ? "Black" : "White"
        return [
            DisplayColor(name: defaultColorName, color: defaultColor),
            DisplayColor(name: "Blue", color: .blue),
            DisplayColor(name: "Purple", color: .purple),
            DisplayColor(name: "Pink", color: .pink),
            DisplayColor(name: "Green", color: .green),
            DisplayColor(name: "Orange", color: .orange)
        ]
    }
}

class DisplaySettings: ObservableObject, Identifiable, Codable {
    private let _id: UUID
    var id: UUID { _id }
    @Published var style: TimeDisplayStyle = .grid
    @Published var showPercentage = false
    @Published var displayColor: Color = .white
    @Published var backgroundStyle: BackgroundStyle = .dark
    @Published var isUsingDefaultColor: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case style
        case showPercentage
        case displayColor
        case backgroundStyle
        case isUsingDefaultColor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(UUID.self, forKey: .id)
        style = try container.decode(TimeDisplayStyle.self, forKey: .style)
        showPercentage = try container.decode(Bool.self, forKey: .showPercentage)
        backgroundStyle = try container.decode(BackgroundStyle.self, forKey: .backgroundStyle)
        isUsingDefaultColor = try container.decode(Bool.self, forKey: .isUsingDefaultColor)
        
        // Decode Color as UIColor components
        let components = try container.decode([CGFloat].self, forKey: .displayColor)
        if components.count == 4 {
            displayColor = Color(red: components[0], green: components[1], blue: components[2], opacity: components[3])
        } else {
            displayColor = .white // Default color if decoding fails
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: .id)
        try container.encode(style.rawValue, forKey: .style)
        try container.encode(showPercentage, forKey: .showPercentage)
        try container.encode(backgroundStyle.rawValue, forKey: .backgroundStyle)
        try container.encode(isUsingDefaultColor, forKey: .isUsingDefaultColor)
        
        // Encode Color as array of components
        if let components = displayColor.cgColor?.components {
            try container.encode(components, forKey: .displayColor)
        } else {
            try container.encode([1.0, 1.0, 1.0, 1.0], forKey: .displayColor) // White color as fallback
        }
    }
    
    func updateColor(for backgroundStyle: BackgroundStyle) {
        // Only update if using default color and the new color would be different
        if isUsingDefaultColor {
            let newColor = backgroundStyle == .light ? Color.black : Color.white
            if displayColor != newColor {
                DispatchQueue.main.async {
                    self.displayColor = newColor
                }
            }
        }
    }
    
    init(backgroundStyle: BackgroundStyle = .dark) {
        self._id = UUID()
        self.backgroundStyle = backgroundStyle
        self.displayColor = backgroundStyle == .light ? .black : .white
        self.isUsingDefaultColor = true
        
        // Ensure color is properly set based on effective background style
        if backgroundStyle == .device {
            let isDark = UserDefaults.standard.bool(forKey: "systemIsDark")
            self.displayColor = isDark ? .white : .black
        }
    }
    
    init() {
        self._id = UUID()
        self.backgroundStyle = .dark
        self.displayColor = .white
        self.isUsingDefaultColor = true
    }
}

//
//  ColorOption.swift
//  Progress
//
//  Created by Sabrina Bea on 6/14/24.
//

import SwiftUI

enum ColorOption: CaseIterable, Codable {
    case red
    case brickRed
    case orange
    case redOrange
    case yellowOrange
    case yellow
    case tennisBall
    case coolGreen
    case leafGreen
    case mint
    case teal
    case cyan
    case blue
    case navy
    case indigo
    case purple
    case hotPink
    case electricRaspberry
    case raspberry
    case fuschia
    case pink
    case lightPink
    case lightGray
    case gray
    case khaki
    case darkKhaki
    case chestnut
    case mauve
    case maroon
    case burgundy
    case lavender
    case lilac
    case dinosaurPurple
    case forestGreen
    case pastelYellow
    case royalPurple
    case violet
    
    
    static var rainbow: [ColorOption] {
        allCases.sorted { a, b in
            let uA = UIColor(a.color)
            let uB = UIColor(b.color)
            var hueA: CGFloat = 0
            var hueB: CGFloat = 0
            
            _ = withUnsafeMutablePointer(to: &hueA) { ptr in
                uA.getHue(ptr, saturation: nil, brightness: nil, alpha: nil)
            }
            _ = withUnsafeMutablePointer(to: &hueB) { ptr in
                uB.getHue(ptr, saturation: nil, brightness: nil, alpha: nil)
            }
            
            return hueA < hueB
        }
    }
    
    var color: Color {
        switch self {
        case .red: return Color(red: 0.8, green: 0, blue: 0)
        case .brickRed: return Color(red: 0.59, green: 0, blue: 0)
        case .orange: return Color(red: 1, green: 0.4, blue: 0.05)
        case .redOrange: return Color(red: 1, green: 0.22, blue: 0)
        case .yellowOrange: return .orange
        case .yellow: return .yellow
        case .tennisBall: return Color(red: 0.86, green: 0.91, blue: 0.39)
        case .coolGreen: return .green
        case .leafGreen: return Color(red: 0.43, green: 0.63, blue: 0.19)
        case .mint: return Color(red: 0.45, green: 0.95, blue: 0.65)
        case .teal: return Color(red: 0.2, green: 0.54, blue: 0.64)
        case .cyan: return Color(red: 0.48, green: 0.9, blue: 1)
        case .blue: return Color(red: 0, green: 0.3, blue: 0.9)
        case .navy: return Color(red: 0, green: 0, blue: 0.4)
        case .indigo: return .indigo
        case .purple: return Color(red: 0.55, green: 0.21, blue: 0.88)
        case .hotPink: return Color(red: 0.89, green: 0.22, blue: 0.62)
        case .raspberry: return Color(red: 0.79, green: 0.18, blue: 0.36)
        case .electricRaspberry: return .pink
        case .fuschia: return Color(red: 0.89, green: 0.24, blue: 0.93)
        case .pink: return Color(red: 1, green: 0.41, blue: 0.70)
        case .lightPink: return Color(red: 0.93, green: 0.72, blue: 0.82)
        case .lightGray: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gray: return .gray
        case .khaki: return Color(red: 0.79, green: 0.75, blue: 0.61)
        case .darkKhaki: return .brown
        case .chestnut: return Color(red: 0.35, green: 0.14, blue: 0.03)
        case .mauve: return Color(red: 0.47, green: 0.31, blue: 0.38)
        case .maroon: return Color(red: 0.41, green: 0.07, blue: 0.07)
        case .burgundy: return Color(red: 0.23, green: 0.04, blue: 0.10)
        case .lavender: return Color(red: 0.75, green: 0.71, blue: 0.98)
        case .lilac: return Color(red: 0.58, green: 0.41, blue: 0.76)
        case .dinosaurPurple: return Color(red: 0.61, green: 0.16, blue: 0.43)
        case .forestGreen: return Color(red: 0.06, green: 0.17, blue: 0.04)
        case .pastelYellow: return Color(red: 0.96, green: 0.90, blue: 0.58)
        case .royalPurple: return Color(red: 0.25, green: 0.04, blue: 0.25)
        case .violet: return Color(red: 0.39, green: 0.07, blue: 0.83)
        }
    }
    
    var luminance: Double {
        let rgb = UIColor(color).cgColor.components!
        return (0.2126 * rgb[0]) + (0.7152 * rgb[1]) + (0.0722 * rgb[2])
        // return (0.299 * rgb[0]) + (0.587 * rgb[1]) + (0.114 * rgb[2])
        // return (0.299 * rgb[0] * rgb[0]) + (0.587 * rgb[1] * rgb[1]) + (0.114 * rgb[2] * rgb[2])
    }
    
    var contrastingFontColor: Color {
        // return Color.white //.shadow(.drop(color: .init(.sRGBLinear, white: 0, opacity: 0.6), radius: 2, x: 0, y: 1))
        return luminance > 0.56 ? Color.black : Color.white
    }
    
    var successColor: Color {
        return self == .coolGreen || self == .leafGreen ? Self.forestGreen.color : Self.coolGreen.color
    }
    
    var errorColor: Color {
        return self == .red || self == .redOrange ? Self.yellowOrange.color : Self.red.color
    }
    
    var infoColor: Color {
        return self == .blue ? Self.cyan.color : Self.blue.color
    }
    
    var inactiveColor: Color {
        return self == .gray ? Self.lightGray.color : Self.gray.color
    }
    
    var warnColor: Color {
        return self == .tennisBall || self == .pastelYellow || self == .lightPink ? Self.coolGreen.color : Self.tennisBall.color
    }
    
    var needsAttentionColor: Color {
        return self == .yellowOrange || self == .yellow || self == .lightGray || self == .khaki ? Self.redOrange.color : Self.yellowOrange.color
    }
    
    var label: String {
        switch self  {
        case .red: return "Red"
        case .brickRed: return "Brick Red"
        case .orange: return "Orange"
        case .redOrange: return "Red Orange"
        case .yellowOrange: return "Yellow Orange"
        case .yellow: return "Yellow"
        case .coolGreen: return "Cool Green"
        case .mint: return "Mint"
        case .teal: return "Teal"
        case .cyan: return "Cyan"
        case .blue: return "Blue"
        case .navy: return "Navy"
        case .indigo: return "Indigo"
        case .purple: return "Purple"
        case .pink: return "Pink"
        case .lightPink: return "Light Pink"
        case .lightGray: return "Light Gray"
        case .gray: return "Gray"
        case .khaki: return "Khaki"
        case .darkKhaki: return "Dark Khaki"
        case .chestnut: return "Chestnut"
        case .mauve: return "Mauve"
        case .maroon: return "Maroon"
        case .burgundy: return "Burgundy"
        case .lavender: return "Lavender"
        case .lilac: return "Lilac"
        case .dinosaurPurple: return "Dinosaur Purple"
        case .hotPink: return "Hot Pink"
        case .raspberry: return "Raspberry"
        case .electricRaspberry: return "Electric Raspberry"
        case .fuschia: return "Fuschia"
        case .forestGreen: return "Forest Green"
        case .pastelYellow: return "Pastel Yellow"
        case .royalPurple: return "Royal Purple"
        case .violet: return "Violet"
        case .tennisBall: return "Tennis Ball"
        case .leafGreen: return "Leaf Green"
        }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
            ForEach(ColorOption.rainbow, id: \.self) { colorOption in
                Text(colorOption.label)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 175, height: 75, alignment: .center)
                    .background(colorOption.color)
                    .foregroundStyle(colorOption.contrastingFontColor)
                    .cornerRadius(20)
            }
        }
    }
}

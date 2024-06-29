//
//  ColorPaletteView.swift
//  ToDoList
//
//  Created by Диана Мишкова on 29.06.24.
//

import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedBaseColor: Color
    @Binding var brightness: Double

    @State private var currentPoint: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red]), startPoint: .leading, endPoint: .trailing)
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let point = value.location
                                    let width = geometry.size.width
                                    let height = geometry.size.height

                                    let clampedX = min(max(point.x, 0), width)
                                    let clampedY = min(max(point.y, 0), height)

                                    currentPoint = CGPoint(x: clampedX, y: clampedY)

                                    selectedBaseColor = getColorAtPoint(point: currentPoint, in: geometry.size)
                                })
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .position(currentPoint)
            }
        }
    }

    func getColorAtPoint(point: CGPoint, in size: CGSize) -> Color {
        let hue = point.x / size.width
        let saturation: CGFloat = 1.0
        return Color(hue: hue, saturation: saturation, brightness: 1.0)
    }
}


extension Color {
    init?(hex: String) {
        let r, g, b: CGFloat
        let hexColor = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard hexColor.count == 6, let intCode = Int(hexColor, radix: 16) else {
            return nil
        }
        r = CGFloat((intCode >> 16) & 0xff) / 255.0
        g = CGFloat((intCode >> 8) & 0xff) / 255.0
        b = CGFloat(intCode & 0xff) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        let components = self.cgColor?.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0

        let hexString = String(format: "#%02X%02X%02X", Int(r * 255.0), Int(g * 255.0), Int(b * 255.0))
        return hexString
    }
}

//
//  ColorPicker.swift
//  ToDoList
//
//  Created by Диана Мишкова on 29.06.24.
//

import SwiftUI
import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @State private var brightness: Double = 1.0
    
    private var colorPickerPalette: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let colors: [Color] = (0..<Int(width)).map { x in
                let r = Double(x) / width
                return Color(red: r, green: 0.5, blue: 0.5)  // Здесь создаем градиент цветов
            }
            
            ForEach(colors.indices, id: \.self) { index in
                Rectangle()
                    .fill(colors[index])
                    .frame(width: 2, height: height)
                    .position(x: CGFloat(index), y: height / 2)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Выбранный цвет:")
                .font(.headline)
                .padding()
            
            HStack {
                Text(selectedColor.description)  // Показать цвет в формате HEX
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            
            // Цветовая палитра
            colorPickerPalette
                .frame(height: 40)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = min(max(0, value.location.x), 200)  // Ограничиваем перемещение пальца по палитре
                            let r = Double(x) / 200
                            selectedColor = Color(red: r, green: 0.5, blue: 0.5)
                        }
                )
            
            // Ползунок яркости
            Slider(value: $brightness, in: 0...1) {
                Text("Яркость")
            }
            .onChange(of: brightness) { newValue in
                let hue = selectedColor.hsba.hue
                let saturation = selectedColor.hsba.saturation
                let brightness = newValue
                selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
            }
            
            // Прямоугольник для отображения выбранного цвета
            Rectangle()
                .fill(selectedColor)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
        }
        .padding()
    }
}
#Preview {
    ColorPicker()
}

import SwiftUI

struct ColorPicker: View {
    @State private var selectedBaseColor: Color = .white
    @State var selectedColor: Color
    @State private var colorCode: String = "#FFFFFF"
    @State private var brightness: Double = 1.0
    @State var todoItem: TodoItem
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fileCache: FileCache

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Выбранный цвет")
                        .font(.headline)
                    Text(colorCode)
                        .font(.subheadline)
                }
                Spacer()
                Rectangle()
                    .fill(selectedColor)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .padding()

            ColorPaletteView(selectedBaseColor: $selectedBaseColor, brightness: $brightness)
                .frame(height: 30)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding()

            VStack {
                Text("Яркость")
                    .font(.headline)
                Slider(value: $brightness, in: 0...1, step: 0.01) {
                }
                .padding()
                .onChange(of: brightness) {
                    updateSelectedColor()
                }
            }
        }
        .padding()
        .onChange(of: selectedBaseColor) {
            updateSelectedColor()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Отменить") {
                dismiss()
            },
            trailing: Button("Сохранить") {
                todoItem.colorHex = selectedColor
                fileCache.addItem(todoItem)
                do {
                    try fileCache.save(to: "todoItems.json")
                    dismiss()
                } catch {
                    print("Error saving data: \(error)")
                }
            }
        )
    }

    func updateSelectedColor() {
        let uiColor = UIColor(selectedBaseColor)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        selectedColor = Color(hue: hue, saturation: saturation, brightness: self.brightness)
        colorCode = selectedColor.toHex() ?? "#FFFFFF"
    }
}


#Preview {
    ColorPicker(selectedColor: Color.white, todoItem: TodoItem(id: "1", text: "Купить что-то", importance: .important, completed: false, creationDate: Date(timeIntervalSince1970: 1822548800)))
        .environmentObject(FileCache())
}

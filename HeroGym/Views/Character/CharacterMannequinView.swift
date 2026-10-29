import SwiftUI

/// Визуальный манекен персонажа в WotLK-стиле
/// Отображает атлетический силуэт с интерактивными зонами мышц
/// и неоновой подсветкой тренированных зон
public struct CharacterMannequinView: View {
    @State private var selectedMuscle: MuscleGroup? = nil
    
    // Список мышц, которые были нагружены на текущей неделе (для неонового свечения)
    public var activeMuscles: Set<MuscleGroup> = [.chest, .arms, .abs]
    
    public init(activeMuscles: Set<MuscleGroup> = [.chest, .arms, .abs]) {
        self.activeMuscles = activeMuscles
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Фоновое сияние Frost Rune
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [WotLKTheme.ice.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                
                // Силуэт манекена из геометрических фигур в стилистике рыцаря/атлета
                VStack(spacing: 4) {
                    // Голова / Шлем
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [WotLKTheme.border, WotLKTheme.bgCardHover], startPoint: .top, endPoint: .bottom))
                            .frame(width: 38, height: 38)
                            .overlay(Circle().stroke(WotLKTheme.iceLight, lineWidth: 1.5))
                        
                        // Ледяной визор
                        RoundedRectangle(cornerRadius: 2)
                            .fill(WotLKTheme.iceBright)
                            .frame(width: 18, height: 4)
                            .shadow(color: WotLKTheme.iceBright, radius: 4)
                    }
                    
                    // Шея и трапеции
                    Trapezoid()
                        .fill(WotLKTheme.border.opacity(0.7))
                        .frame(width: 36, height: 10)
                    
                    // Плечи и Грудь
                    HStack(spacing: 5) {
                        // Левое плечо
                        muscleNode(group: .shoulders, width: 28, height: 32, corner: 6)
                        
                        // Грудь (центр)
                        muscleNode(group: .chest, width: 72, height: 38, corner: 8)
                        
                        // Правое плечо
                        muscleNode(group: .shoulders, width: 28, height: 32, corner: 6)
                    }
                    
                    // Руки (бицепс) + Пресс
                    HStack(spacing: 6) {
                        // Левая рука
                        muscleNode(group: .arms, width: 22, height: 44, corner: 6)
                        
                        // Пресс (6 кубиков)
                        muscleNode(group: .abs, width: 60, height: 50, corner: 6)
                        
                        // Правая рука
                        muscleNode(group: .arms, width: 22, height: 44, corner: 6)
                    }
                    
                    // Пояс / Таз
                    RoundedRectangle(cornerRadius: 4)
                        .fill(WotLKTheme.border)
                        .frame(width: 74, height: 14)
                    
                    // Ноги (Квадрицепсы / Бёдра)
                    HStack(spacing: 8) {
                        muscleNode(group: .legs, width: 34, height: 60, corner: 8)
                        muscleNode(group: .legs, width: 34, height: 60, corner: 8)
                    }
                    
                    // Икры
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isTrained(.legs) ? WotLKTheme.ice.opacity(0.4) : WotLKTheme.bgCardHover)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(isTrained(.legs) ? WotLKTheme.iceBright : WotLKTheme.border, lineWidth: 1))
                            .frame(width: 24, height: 42)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isTrained(.legs) ? WotLKTheme.ice.opacity(0.4) : WotLKTheme.bgCardHover)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(isTrained(.legs) ? WotLKTheme.iceBright : WotLKTheme.border, lineWidth: 1))
                            .frame(width: 24, height: 42)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Подпись выбранной группы мышц
            HStack(spacing: 8) {
                if let muscle = selectedMuscle {
                    Text("Выбрано: \(muscle.rawValue)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(WotLKTheme.goldLight)
                    
                    if activeMuscles.contains(muscle) {
                        Text("• Нагрузка на этой неделе 🔥")
                            .font(.system(size: 11))
                            .foregroundColor(WotLKTheme.iceBright)
                    }
                } else {
                    Text("Нажми на мышцу для деталей")
                        .font(.system(size: 12))
                        .foregroundColor(WotLKTheme.textMuted)
                }
            }
            .frame(height: 20)
        }
    }
    
    private func isTrained(_ group: MuscleGroup) -> Bool {
        activeMuscles.contains(group)
    }
    
    @ViewBuilder
    private func muscleNode(group: MuscleGroup, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
        let trained = isTrained(group)
        let isSelected = selectedMuscle == group
        
        RoundedRectangle(cornerRadius: corner)
            .fill(
                isSelected ? WotLKTheme.gold.opacity(0.4) :
                trained ? WotLKTheme.ice.opacity(0.35) :
                WotLKTheme.bgCardHover
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner)
                    .stroke(
                        isSelected ? WotLKTheme.goldLight :
                        trained ? WotLKTheme.iceBright :
                        WotLKTheme.border,
                        lineWidth: isSelected ? 2 : (trained ? 1.5 : 1)
                    )
            )
            .frame(width: width, height: height)
            .shadow(
                color: trained ? WotLKTheme.iceBright.opacity(0.4) : Color.clear,
                radius: trained ? 6 : 0
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    selectedMuscle = group
                }
            }
    }
}

// Вспомогательная фигура трапеции
struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.2, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

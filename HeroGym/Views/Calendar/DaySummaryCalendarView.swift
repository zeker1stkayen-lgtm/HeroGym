import SwiftUI
import SwiftData

/// Летопись тренировок:
/// - Маркирует ТОЛЬКО дни, когда была тренировка
/// - При выборе дня показывает сводку выполненной тренировки и утренний вес
public struct DaySummaryCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [Workout]
    
    @State private var selectedDate = Date()
    
    // Дни с тренировками (для демонстрации)
    private let sampleWorkoutDays: Set<Int> = [2, 5, 8, 12, 15, 19, 22, 26, 29]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                WotLKTheme.bgDeep.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        
                        // Календарная сетка месяца
                        VStack(spacing: 10) {
                            HStack {
                                Text("ОКТЯБРЬ 2026")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(WotLKTheme.goldLight)
                                Spacer()
                            }
                            
                            HStack {
                                ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { d in
                                    Text(d)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(WotLKTheme.textMuted)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                                ForEach(1...31, id: \.self) { day in
                                    let hasWorkout = sampleWorkoutDays.contains(day)
                                    let isSelected = day == 22
                                    
                                    VStack(spacing: 2) {
                                        Text("\(day)")
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                            .foregroundColor(isSelected ? WotLKTheme.bgDeep : WotLKTheme.textPrimary)
                                        
                                        // Точка ТОЛЬКО для тренировок
                                        if hasWorkout {
                                            Circle()
                                                .fill(isSelected ? WotLKTheme.bgDeep : WotLKTheme.strengthOrange)
                                                .frame(width: 4, height: 4)
                                        } else {
                                            Spacer().frame(height: 4)
                                        }
                                    }
                                    .frame(height: 34)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        isSelected ?
                                        LinearGradient(colors: [WotLKTheme.goldLight, WotLKTheme.gold], startPoint: .top, endPoint: .bottom) :
                                        LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
                                    )
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .wotlkCard(hasGlow: true)
                        
                        // Подсказка
                        HStack(spacing: 6) {
                            Circle().fill(WotLKTheme.strengthOrange).frame(width: 6, height: 6)
                            Text("Точки отмечают только дни выполненных тренировок")
                                .font(.system(size: 10))
                                .foregroundColor(WotLKTheme.textMuted)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        
                        // Сводка выбранного дня
                        VStack(alignment: .leading, spacing: 8) {
                            Text("СВОДКА ЗА 22 ОКТЯБРЯ (НЕДЕЛЯ 6)")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(WotLKTheme.goldLight)
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Жим лёжа").font(.system(size: 12)).foregroundColor(WotLKTheme.textPrimary)
                                    Spacer()
                                    Text("67×4×6").font(.system(size: 12, weight: .bold)).foregroundColor(WotLKTheme.iceLight)
                                    Text("RPE 8").font(.system(size: 10, weight: .bold)).foregroundColor(WotLKTheme.goldLight)
                                }
                                HStack {
                                    Text("Сведение в тренажёре").font(.system(size: 12)).foregroundColor(WotLKTheme.textPrimary)
                                    Spacer()
                                    Text("40×8").font(.system(size: 12, weight: .bold)).foregroundColor(WotLKTheme.iceLight)
                                    Text("RPE 7").font(.system(size: 10, weight: .bold)).foregroundColor(WotLKTheme.goldLight)
                                }
                            }
                            .padding(8)
                            .background(WotLKTheme.bgCardHover)
                            .cornerRadius(6)
                            
                            HStack {
                                Text("⚖️ Утренний вес:").font(.system(size: 11)).foregroundColor(WotLKTheme.textMuted)
                                Spacer()
                                Text("67.2 кг").font(.system(size: 12, weight: .bold)).foregroundColor(WotLKTheme.goldLight)
                            }
                            .padding(.top, 2)
                        }
                        .wotlkCard()
                    }
                    .padding(14)
                }
            }
            .navigationTitle("Летопись")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .foregroundColor(WotLKTheme.goldLight)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

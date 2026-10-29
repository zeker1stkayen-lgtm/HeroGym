import SwiftUI
import SwiftData

/// Обновленный список тренировок:
/// - Кнопка «Записать тренировку» открывает полноценную форму
/// - Кнопка «Редактировать» у каждой тренировки позволяет менять веса, повторы, подходы и RPE
public struct WorkoutListView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    @State private var showAddWorkout = false
    @State private var showCalendar = false
    @State private var editingWorkout: Workout? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                WotLKTheme.bgDeep.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        
                        // Выбранная дата
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ВЫБРАННАЯ ДАТА:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(WotLKTheme.textMuted)
                                Text("22 мая 2025 (Неделя 6)")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(WotLKTheme.goldLight)
                            }
                            Spacer()
                            Button {
                                showCalendar = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                    Text("Летопись")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(WotLKTheme.bgDeep)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(WotLKTheme.goldLight)
                                .cornerRadius(6)
                            }
                        }
                        .wotlkCard()
                        
                        // Кнопка записи новой тренировки
                        Button {
                            showAddWorkout = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Записать тренировку")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(WotLKTheme.bgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(
                                LinearGradient(colors: [WotLKTheme.goldLight, WotLKTheme.gold], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(8)
                        }
                        
                        // Карточки тренировок с кнопкой «Редактировать»
                        sampleWorkoutCard(
                            dateStr: "22.05.2025",
                            weekText: "Неделя 6",
                            exercises: [
                                ("Жим лёжа", "67×4×6", 8),
                                ("Сведение в тренажёре", "40×8", 7)
                            ]
                        )
                        
                        sampleWorkoutCard(
                            dateStr: "12.05.2025",
                            weekText: "Неделя 5",
                            exercises: [
                                ("Жим лёжа", "60×8×4", 7),
                                ("Гантели наклон", "13.6×12", 6)
                            ]
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Тренировки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(WotLKTheme.iceBright)
                    }
                }
            }
            .sheet(isPresented: $showAddWorkout) {
                AddWorkoutView()
            }
            .sheet(isPresented: $showCalendar) {
                DaySummaryCalendarView()
            }
        }
    }
    
    @ViewBuilder
    private func sampleWorkoutCard(dateStr: String, weekText: String, exercises: [(String, String, Int)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateStr)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.goldLight)
                Text(weekText)
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.textMuted)
                Spacer()
                
                // Кнопка редактирования тренировки
                Button {
                    showAddWorkout = true
                } label: {
                    Text("✏️ Изменить")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(WotLKTheme.iceBright)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(WotLKTheme.bgCardHover)
                        .cornerRadius(5)
                }
                
                Text("💪 Силовая")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(WotLKTheme.strengthOrange.opacity(0.15))
                    .foregroundColor(WotLKTheme.strengthOrange)
                    .cornerRadius(4)
            }
            
            Divider().background(WotLKTheme.border)
            
            VStack(spacing: 6) {
                ForEach(exercises, id: \.0) { ex in
                    HStack {
                        Text(ex.0)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(WotLKTheme.textPrimary)
                        Spacer()
                        Text(ex.1)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(WotLKTheme.iceLight)
                        Text("RPE \(ex.2)")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(WotLKTheme.gold.opacity(0.2))
                            .foregroundColor(WotLKTheme.goldLight)
                            .cornerRadius(4)
                    }
                }
            }
            
            HStack {
                Spacer()
                Text("+20 XP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(WotLKTheme.xpPurple)
            }
        }
        .wotlkCard()
    }
}

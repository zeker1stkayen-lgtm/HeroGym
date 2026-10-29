import SwiftUI
import SwiftData

/// Модальный экран создания тренировки
/// с поддержкой формата подходов (вес×повторы×подходы),
/// RPE на всё упражнение и подсказкой "Насколько тебе было тяжело?"
public struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var date = Date()
    @State private var weekNumberText = "6"
    @State private var workoutType: WorkoutType = .strength
    @State private var notes = ""
    
    // Черновик упражнений
    @State private var exercises: [ExerciseDraft] = [
        ExerciseDraft(
            name: "Жим лёжа",
            targetMuscle: .chest,
            isCardio: false,
            rpe: 8,
            sets: [SetDraft(weight: "67", reps: "4", setsCount: "6")]
        ),
        ExerciseDraft(
            name: "Сведение в тренажёре",
            targetMuscle: .chest,
            isCardio: false,
            rpe: 7,
            sets: [SetDraft(weight: "40", reps: "8", setsCount: "1")]
        )
    ]
    
    @State private var showRPEHelp = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                WotLKTheme.bgDeep.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Основные параметры
                        metaCard
                        
                        // Список упражнений
                        exercisesSection
                        
                        // Кнопка добавления упражнения
                        addExerciseButton
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Новая тренировка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(WotLKTheme.textMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveWorkout()
                        dismiss()
                    }
                    .foregroundColor(WotLKTheme.goldLight)
                    .fontWeight(.bold)
                }
            }
            .alert("Шкала RPE — Насколько тебе было тяжело?", isPresented: $showRPEHelp) {
                Button("Понятно", role: .cancel) {}
            } message: {
                Text("""
                Оценка субъективной тяжести упражнения:
                • 5–6: Легко, в запасе ещё 4+ повтора
                • 7–8: Рабочий подход, в запасе 2–3 повтора
                • 9: Очень тяжело, максимум 1 повтор в запасе
                • 10: Отказ! Больше не сделать ни одного повтора
                """)
            }
        }
    }
    
    // MARK: - Meta Card
    private var metaCard: some View {
        VStack(spacing: 12) {
            HStack {
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                    .colorScheme(.dark)
                    .foregroundColor(WotLKTheme.textPrimary)
            }
            
            HStack(spacing: 12) {
                // Номер недели
                VStack(alignment: .leading, spacing: 4) {
                    Text("Неделя цикла")
                        .font(.system(size: 11))
                        .foregroundColor(WotLKTheme.textMuted)
                    TextField("напр. 6", text: $weekNumberText)
                        .keyboardType(.numberPad)
                        .padding(8)
                        .background(WotLKTheme.bgCardHover)
                        .cornerRadius(6)
                        .foregroundColor(WotLKTheme.textPrimary)
                }
                .frame(width: 110)
                
                // Тип
                VStack(alignment: .leading, spacing: 4) {
                    Text("Тип тренировки")
                        .font(.system(size: 11))
                        .foregroundColor(WotLKTheme.textMuted)
                    Picker("Тип", selection: $workoutType) {
                        Text("💪 Силовая").tag(WorkoutType.strength)
                        Text("🏃 Кардио").tag(WorkoutType.cardio)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .wotlkCard()
    }
    
    // MARK: - Exercises Section
    private var exercisesSection: some View {
        VStack(spacing: 12) {
            ForEach($exercises) { $exercise in
                exerciseCard(exercise: $exercise)
            }
        }
    }
    
    @ViewBuilder
    private func exerciseCard(exercise: Binding<ExerciseDraft>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Название
            HStack {
                TextField("Название упражнения", text: exercise.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(WotLKTheme.iceBright)
                
                Spacer()
                
                Button {
                    exercises.removeAll(where: { $0.id == exercise.wrappedValue.id })
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(WotLKTheme.cutRed.opacity(0.8))
                }
            }
            
            if workoutType == .cardio {
                // Кардио блок (Время и Скорость)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Время (мин)")
                            .font(.system(size: 10))
                            .foregroundColor(WotLKTheme.textMuted)
                        TextField("30", text: exercise.cardioMinutes)
                            .keyboardType(.numberPad)
                            .padding(8)
                            .background(WotLKTheme.bgCardHover)
                            .cornerRadius(6)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Скорость / Темп (км/ч)")
                            .font(.system(size: 10))
                            .foregroundColor(WotLKTheme.textMuted)
                        TextField("8.5", text: exercise.cardioSpeed)
                            .keyboardType(.decimalPad)
                            .padding(8)
                            .background(WotLKTheme.bgCardHover)
                            .cornerRadius(6)
                    }
                }
            } else {
                // Силовые подходы
                VStack(alignment: .leading, spacing: 6) {
                    Text("ПОДХОДЫ (ВЕС × ПОВТОРЫ × ПОДХОДЫ)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(WotLKTheme.textMuted)
                    
                    ForEach($exercise.sets) { $set in
                        HStack(spacing: 6) {
                            TextField("Вес кг", text: $set.weight)
                                .keyboardType(.decimalPad)
                                .frame(width: 70)
                                .padding(6)
                                .background(WotLKTheme.bgCardHover)
                                .cornerRadius(6)
                            
                            Text("×")
                                .foregroundColor(WotLKTheme.textMuted)
                            
                            TextField("Повт.", text: $set.reps)
                                .keyboardType(.numberPad)
                                .frame(width: 55)
                                .padding(6)
                                .background(WotLKTheme.bgCardHover)
                                .cornerRadius(6)
                            
                            Text("×")
                                .foregroundColor(WotLKTheme.textMuted)
                            
                            TextField("Подх.", text: $set.setsCount)
                                .keyboardType(.numberPad)
                                .frame(width: 55)
                                .padding(6)
                                .background(WotLKTheme.bgCardHover)
                                .cornerRadius(6)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // RPE шкала на всё упражнение
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("RPE (тяжесть упражнения):")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(WotLKTheme.goldLight)
                    
                    Button {
                        showRPEHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(WotLKTheme.iceLight)
                    }
                    
                    Spacer()
                    
                    if let rpe = exercise.wrappedValue.rpe {
                        Text("\(rpe) / 10")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(rpeColor(rpe))
                    }
                }
                
                HStack(spacing: 6) {
                    ForEach(5...10, id: \.self) { rpeVal in
                        let isSelected = exercise.wrappedValue.rpe == rpeVal
                        Button {
                            exercise.wrappedValue.rpe = rpeVal
                        } label: {
                            Text("\(rpeVal)")
                                .font(.system(size: 12, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(isSelected ? rpeColor(rpeVal).opacity(0.3) : WotLKTheme.bgCardHover)
                                .foregroundColor(isSelected ? rpeColor(rpeVal) : WotLKTheme.textMuted)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? rpeColor(rpeVal) : WotLKTheme.border, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .wotlkCard()
    }
    
    private var addExerciseButton: some View {
        Button {
            exercises.append(
                ExerciseDraft(
                    name: "",
                    targetMuscle: .chest,
                    isCardio: workoutType == .cardio,
                    rpe: 8,
                    sets: [SetDraft(weight: "", reps: "", setsCount: "1")]
                )
            )
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("Добавить упражнение")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(WotLKTheme.goldLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(WotLKTheme.bgCardHover)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(WotLKTheme.gold.opacity(0.4), lineWidth: 1))
        }
    }
    
    private func rpeColor(_ rpe: Int) -> Color {
        switch rpe {
        case 5...6: return WotLKTheme.cardioGreen
        case 7...8: return WotLKTheme.goldLight
        case 9...10: return WotLKTheme.cutRed
        default: return WotLKTheme.iceLight
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            date: date,
            weekNumber: Int(weekNumberText),
            workoutType: workoutType,
            notes: notes
        )
        
        for exDraft in exercises {
            let ex = Exercise(
                name: exDraft.name.isEmpty ? "Упражнение" : exDraft.name,
                targetMuscle: exDraft.targetMuscle,
                isCardio: exDraft.isCardio,
                rpe: exDraft.rpe,
                cardioDurationMinutes: Double(exDraft.cardioMinutes),
                cardioSpeed: Double(exDraft.cardioSpeed)
            )
            
            for sDraft in exDraft.sets {
                let set = ExerciseSet(
                    weight: Double(sDraft.weight) ?? 0.0,
                    reps: Int(sDraft.reps) ?? 0,
                    setsCount: Int(sDraft.setsCount) ?? 1
                )
                ex.sets.append(set)
            }
            workout.exercises.append(ex)
        }
        
        modelContext.insert(workout)
    }
}

// Черновики для ввода
struct ExerciseDraft: Identifiable {
    let id = UUID()
    var name: String
    var targetMuscle: MuscleGroup
    var isCardio: Bool
    var rpe: Int?
    var cardioMinutes: String = ""
    var cardioSpeed: String = ""
    var sets: [SetDraft] = []
}

struct SetDraft: Identifiable {
    let id = UUID()
    var weight: String
    var reps: String
    var setsCount: String = "1"
}

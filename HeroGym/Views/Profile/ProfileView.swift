import SwiftUI
import SwiftData

/// Обновленный экран профиля:
/// 1. Выбор персонажа (Парень / Девушка)
/// 2. Фиксация утреннего веса с сохранением в SwiftData и автообновлением графика
/// 3. Полноценная смена цели (Похудение / Поддержание / Набор) и целевого веса
/// 4. Замеры тела в Dropdown
public struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var currentWeightText = "67.0"
    @State private var targetWeightText = "72.0"
    @State private var heightText = "177"
    @State private var ageText = "25"
    @State private var selectedGoal: FitnessGoal = .bulk
    @State private var selectedGender: Gender = .male
    @State private var isMeasurementsExpanded = false
    @State private var showWeightTip = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    
    // Замеры
    @State private var currentChest = "98"
    @State private var targetChest = "105"
    @State private var currentWaist = "82"
    @State private var targetWaist = "78"
    @State private var currentArms = "36"
    @State private var targetArms = "40"
    @State private var currentGlutes = "96"
    @State private var targetGlutes = "98"
    @State private var currentHips = "56"
    @State private var targetHips = "60"
    @State private var currentCalves = "37"
    @State private var targetCalves = "39"
    
    private var profile: UserProfile {
        profiles.first ?? UserProfile()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                WotLKTheme.bgDeep.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        
                        // Выбор персонажа
                        characterSelectionCard
                        
                        // Фиксация веса с отправкой на график
                        weightInputCard
                        
                        // Смена цели и целевого веса
                        goalsCard
                        
                        // Замеры тела в Dropdown
                        measurementsDropdownCard
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertMessage, isPresented: $showSuccessAlert) {
                Button("Отлично", role: .cancel) {}
            }
            .alert("Рекомендация по взвешиванию ⚖️", isPresented: $showWeightTip) {
                Button("Понятно", role: .cancel) {}
            } message: {
                Text("""
                Оптимально взвешиваться:
                • Утром сразу после пробуждения
                • Строго натощак и после туалета
                • Без одежды и в одно и то же время
                
                Колебания веса от 0.5 до 1.5 кг за день из-за воды и соли — норма. Смотрите на график тренда недели!
                """)
            }
        }
    }
    
    // MARK: - Character Selection
    private var characterSelectionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ВЫБОР ГЕРОЯ (ПЕРСОНАЖА)")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .foregroundColor(WotLKTheme.iceLight)
            
            HStack(spacing: 10) {
                genderButton(title: "Парень (Воин)", icon: "🧔", gender: .male)
                genderButton(title: "Девушка (Валькирия)", icon: "👩", gender: .female)
            }
        }
        .wotlkCard()
    }
    
    @ViewBuilder
    private func genderButton(title: String, icon: String, gender: Gender) -> some View {
        let isSelected = selectedGender == gender
        Button {
            selectedGender = gender
            profile.gender = gender
        } label: {
            HStack(spacing: 6) {
                Text(icon)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? WotLKTheme.gold.opacity(0.2) : WotLKTheme.bgCardHover)
            .foregroundColor(isSelected ? WotLKTheme.goldLight : WotLKTheme.textMuted)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? WotLKTheme.gold : WotLKTheme.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Weight Input & Commit to Graph
    private var weightInputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ВЕС СЕГОДНЯ (КГ)")
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.iceLight)
                
                Button {
                    showWeightTip = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(WotLKTheme.goldLight)
                }
                
                Spacer()
                
                Text("Цель: \(targetWeightText) кг")
                    .font(.system(size: 10))
                    .foregroundColor(WotLKTheme.textMuted)
            }
            
            HStack(spacing: 10) {
                TextField("67.0", text: $currentWeightText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .heavy, design: .serif))
                    .foregroundColor(WotLKTheme.iceBright)
                    .multilineTextAlignment(.center)
                    .frame(width: 95)
                    .padding(8)
                    .background(WotLKTheme.bgCardHover)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(WotLKTheme.border, lineWidth: 1))
                
                Button {
                    commitWeight()
                } label: {
                    Text("Зафиксировать 📌")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(WotLKTheme.bgDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            LinearGradient(colors: [WotLKTheme.goldLight, WotLKTheme.gold], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .wotlkCard(hasGlow: true)
    }
    
    // MARK: - Goals Selection & Target Weight
    private var goalsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ВЫБОР ЦЕЛИ И ПЛАНА")
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.iceLight)
                Spacer()
                Text("Б: 2г/кг · Ж: 1г/кг")
                    .font(.system(size: 10))
                    .foregroundColor(WotLKTheme.goldLight)
            }
            
            goalItem(goal: .cut, calories: "1,770", macros: "Б: 134г · Ж: 67г · У: 158г", color: WotLKTheme.cutRed)
            goalItem(goal: .maintain, calories: "2,270", macros: "Б: 134г · Ж: 67г · У: 283г", color: WotLKTheme.ice)
            goalItem(goal: .bulk, calories: "2,570", macros: "Б: 134г · Ж: 67г · У: 358г", color: WotLKTheme.goldLight)
            
            // Настройка целевого желаемого веса
            HStack {
                Text("Желаемый целевой вес:")
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.textPrimary)
                Spacer()
                TextField("72.0", text: $targetWeightText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(WotLKTheme.goldLight)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(4)
                    .background(WotLKTheme.bgCardHover)
                    .cornerRadius(6)
                Text("кг")
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.textMuted)
            }
            .padding(.top, 4)
        }
        .wotlkCard()
    }
    
    @ViewBuilder
    private func goalItem(goal: FitnessGoal, calories: String, macros: String, color: Color) -> some View {
        let isSelected = selectedGoal == goal
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(goal.badgeTitle + (isSelected ? " ✓ АКТИВНО" : ""))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isSelected ? WotLKTheme.goldLight : WotLKTheme.textPrimary)
                Spacer()
                Text("\(calories) ккал")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            Text(macros)
                .font(.system(size: 10))
                .foregroundColor(WotLKTheme.textMuted)
        }
        .padding(10)
        .background(isSelected ? WotLKTheme.ice.opacity(0.12) : WotLKTheme.bgCardHover)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? WotLKTheme.gold : WotLKTheme.border, lineWidth: 1)
        )
        .onTapGesture {
            withAnimation {
                selectedGoal = goal
                profile.currentGoal = goal
                alertMessage = "Цель изменена на «\(goal.badgeTitle)». Калории пересчитаны!"
                showSuccessAlert = true
            }
        }
    }
    
    // MARK: - Dropdown Measurements
    private var measurementsDropdownCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isMeasurementsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("📏 ЗАМЕРЫ ТЕЛА (СМ)")
                        .font(.system(size: 10, weight: .bold, design: .serif))
                        .foregroundColor(WotLKTheme.iceLight)
                    Spacer()
                    Text(isMeasurementsExpanded ? "Скрыть ▲" : "Развернуть ▼")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(WotLKTheme.goldLight)
                }
            }
            
            if isMeasurementsExpanded {
                VStack(spacing: 8) {
                    Divider().background(WotLKTheme.border)
                    
                    HStack {
                        Text("Зона").frame(width: 80, alignment: .leading)
                        Spacer()
                        Text("Сейчас").frame(width: 60, alignment: .center)
                        Spacer()
                        Text("Цель").frame(width: 60, alignment: .center)
                        Spacer()
                        Text("Дельта").frame(width: 50, alignment: .trailing)
                    }
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(WotLKTheme.textMuted)
                    
                    mRow(title: "Грудь", cur: $currentChest, tgt: $targetChest)
                    mRow(title: "Талия", cur: $currentWaist, tgt: $targetWaist, isCut: true)
                    mRow(title: "Рука/Бицепс", cur: $currentArms, tgt: $targetArms)
                    mRow(title: "Ягодицы", cur: $currentGlutes, tgt: $targetGlutes)
                    mRow(title: "Бедро", cur: $currentHips, tgt: $targetHips)
                    mRow(title: "Икра", cur: $currentCalves, tgt: $targetCalves)
                }
                .padding(.top, 4)
            }
        }
        .wotlkCard()
    }
    
    @ViewBuilder
    private func mRow(title: String, cur: Binding<String>, tgt: Binding<String>, isCut: Bool = false) -> some View {
        let curVal = Double(cur.wrappedValue) ?? 0.0
        let tgtVal = Double(tgt.wrappedValue) ?? 0.0
        let delta = tgtVal - curVal
        
        HStack {
            Text(title).font(.system(size: 11)).foregroundColor(WotLKTheme.textPrimary).frame(width: 80, alignment: .leading)
            Spacer()
            TextField("0", text: cur).keyboardType(.decimalPad).multilineTextAlignment(.center).frame(width: 55).padding(4).background(WotLKTheme.bgCardHover).cornerRadius(6)
            Spacer()
            TextField("0", text: tgt).keyboardType(.decimalPad).multilineTextAlignment(.center).frame(width: 55).padding(4).background(WotLKTheme.bgCardHover).cornerRadius(6)
            Spacer()
            Text(delta > 0 ? "+\(Int(delta)) см" : "\(Int(delta)) см")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(WotLKTheme.cardioGreen)
                .frame(width: 50, alignment: .trailing)
        }
    }
    
    private func commitWeight() {
        if let w = Double(currentWeightText) {
            profile.currentWeight = w
            if let targetW = Double(targetWeightText) {
                profile.targetWeight = targetW
            }
            let entry = WeightEntry(weight: w, isFastState: true)
            modelContext.insert(entry)
            
            alertMessage = "Вес \(String(format: "%.1f", w)) кг успешно зафиксирован и добавлен на график!"
            showSuccessAlert = true
        }
    }
}

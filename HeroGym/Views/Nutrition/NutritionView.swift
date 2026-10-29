import SwiftUI
import SwiftData

/// Экран учёта питания по приёмам пищи (Завтрак, Обед, Ужин, Перекусы)
/// с автоподсчётом калорий и недельной динамикой
public struct NutritionView: View {
    @Query private var profiles: [UserProfile]
    @Query private var meals: [MealEntry]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    
    // Дефолтные приёмы пищи в UI
    @State private var mealList: [MealDraft] = [
        MealDraft(name: "🍳 Завтрак", protein: "40", fat: "20", carbs: "80"),
        MealDraft(name: "🍲 Обед", protein: "50", fat: "25", carbs: "110"),
        MealDraft(name: "🥩 Ужин", protein: "45", fat: "22", carbs: "90")
    ]
    
    private var profile: UserProfile {
        profiles.first ?? UserProfile()
    }
    
    // Цель из калькулятора
    private var target: MacroTarget {
        CalorieEngine.target(
            for: profile.currentGoal,
            weightKg: profile.currentWeight,
            heightCm: profile.height,
            age: profile.age,
            gender: profile.gender,
            activity: profile.activityLevel
        )
    }
    
    // Сумма за день
    private var totalProtein: Double {
        mealList.reduce(0.0) { $0 + (Double($1.protein) ?? 0.0) }
    }
    private var totalFat: Double {
        mealList.reduce(0.0) { $0 + (Double($1.fat) ?? 0.0) }
    }
    private var totalCarbs: Double {
        mealList.reduce(0.0) { $0 + (Double($1.carbs) ?? 0.0) }
    }
    private var totalCalories: Double {
        (totalProtein * 4.0) + (totalFat * 9.0) + (totalCarbs * 4.0)
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                WotLKTheme.bgDeep.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // Переключатель дней
                        dateNavigator
                        
                        // Главное табло калорий дня
                        dailyCaloriesCard
                        
                        // Сравнение БЖУ с целевыми нормами
                        macroGaugesRow
                        
                        // Приёмы пищи (Завтрак, Обед, Ужин + Кнопка добавления)
                        mealsSection
                        
                        // Недельная динамика калорий и БЖУ
                        weeklyTrendSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Питание")
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
            .sheet(isPresented: $showCalendar) {
                DaySummaryCalendarView()
            }
        }
    }
    
    // MARK: - Date Navigator
    private var dateNavigator: some View {
        HStack {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(WotLKTheme.iceLight)
                    .padding(8)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(formattedDate(selectedDate))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.goldLight)
                Text(isToday(selectedDate) ? "Сегодня" : "")
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.textMuted)
            }
            
            Spacer()
            
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(WotLKTheme.iceLight)
                    .padding(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Daily Calories
    private var dailyCaloriesCard: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ИТОГО ЗА ДЕНЬ")
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .foregroundColor(WotLKTheme.iceLight)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(totalCalories))")
                            .font(.system(size: 32, weight: .heavy, design: .serif))
                            .foregroundColor(WotLKTheme.iceBright)
                        Text("/ \(Int(target.dailyCalories)) ккал")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(WotLKTheme.goldLight)
                    }
                }
                
                Spacer()
                
                // Процент попадания
                let pct = target.dailyCalories > 0 ? (totalCalories / target.dailyCalories) * 100 : 0
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(pct))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(pct >= 90 && pct <= 110 ? WotLKTheme.cardioGreen : WotLKTheme.goldLight)
                    Text("от нормы цели")
                        .font(.system(size: 10))
                        .foregroundColor(WotLKTheme.textMuted)
                }
            }
            
            // Прогресс бар
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(WotLKTheme.border)
                    
                    let progress = target.dailyCalories > 0 ? min(1.0, totalCalories / target.dailyCalories) : 0.0
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [WotLKTheme.ice, WotLKTheme.iceBright], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 10)
            
            Text("Формула: Б×4 + Ж×9 + У×4")
                .font(.system(size: 10))
                .foregroundColor(WotLKTheme.textMuted)
        }
        .wotlkCard(hasGlow: true)
    }
    
    // MARK: - Macro Gauges
    private var macroGaugesRow: some View {
        HStack(spacing: 8) {
            macroTile(title: "Белки (2г/кг)", current: totalProtein, target: target.proteinGrams, color: Color(hex: 0xEF4444))
            macroTile(title: "Жиры (1г/кг)", current: totalFat, target: target.fatGrams, color: WotLKTheme.gold)
            macroTile(title: "Углеводы", current: totalCarbs, target: target.carbsGrams, color: WotLKTheme.ice)
        }
    }
    
    @ViewBuilder
    private func macroTile(title: String, current: Double, target: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(WotLKTheme.textMuted)
                .lineLimit(1)
            
            Text("\(Int(current))г")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(color)
            
            Text("цель: \(Int(target))г")
                .font(.system(size: 10))
                .foregroundColor(WotLKTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(WotLKTheme.bgCardHover)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    // MARK: - Meals Section
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ПРИЁМЫ ПИЩИ")
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.iceLight)
                Spacer()
                Text("\(mealList.count) приёма")
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.textMuted)
            }
            
            ForEach($mealList) { $meal in
                mealCard(meal: $meal)
            }
            
            // Кнопка добавления приёма пищи
            Button {
                let nextIndex = mealList.count - 2
                mealList.append(MealDraft(name: "🥪 Перекус \(nextIndex > 0 ? nextIndex : 1)", protein: "", fat: "", carbs: ""))
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить приём пищи")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(WotLKTheme.goldLight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(WotLKTheme.bgCardHover)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(WotLKTheme.gold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4])))
            }
        }
    }
    
    @ViewBuilder
    private func mealCard(meal: Binding<MealDraft>) -> some View {
        let p = Double(meal.wrappedValue.protein) ?? 0.0
        let f = Double(meal.wrappedValue.fat) ?? 0.0
        let c = Double(meal.wrappedValue.carbs) ?? 0.0
        let kcal = (p * 4) + (f * 9) + (c * 4)
        
        VStack(spacing: 10) {
            HStack {
                Text(meal.wrappedValue.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(WotLKTheme.textPrimary)
                Spacer()
                Text("\(Int(kcal)) ккал")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(WotLKTheme.iceBright)
            }
            
            HStack(spacing: 8) {
                macroInputField(label: "Б (г)", text: meal.protein, color: Color(hex: 0xEF4444))
                macroInputField(label: "Ж (г)", text: meal.fat, color: WotLKTheme.gold)
                macroInputField(label: "У (г)", text: meal.carbs, color: WotLKTheme.ice)
            }
        }
        .wotlkCard()
    }
    
    @ViewBuilder
    private func macroInputField(label: String, text: Binding<String>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
            
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(WotLKTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(WotLKTheme.bgCardHover)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(WotLKTheme.border, lineWidth: 1))
        }
    }
    
    // MARK: - Weekly Trend
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("НЕДЕЛЬНАЯ ДИНАМИКА КАЛОРИЙ")
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.iceLight)
                Spacer()
                Text("Цель: \(Int(target.dailyCalories)) ккал")
                    .font(.system(size: 11))
                    .foregroundColor(WotLKTheme.goldLight)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                let values = [2350, 2480, 2550, 2400, 2600, 2510, 2450]
                
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(colors: [WotLKTheme.ice, WotLKTheme.iceBright], startPoint: .bottom, endPoint: .top))
                            .frame(height: CGFloat(values[i]) / 2800.0 * 90.0)
                        
                        Text(days[i])
                            .font(.system(size: 10))
                            .foregroundColor(WotLKTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
            .padding(.top, 8)
        }
        .wotlkCard()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date).capitalized
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// Черновик приёма пищи
struct MealDraft: Identifiable {
    let id = UUID()
    var name: String
    var protein: String
    var fat: String
    var carbs: String
}

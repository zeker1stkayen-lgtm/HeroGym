import Foundation

/// Результат расчёта калорий и БЖУ под конкретную цель
public struct MacroTarget: Identifiable {
    public var id: String { goal.rawValue }
    public let goal: FitnessGoal
    public let dailyCalories: Double
    public let proteinGrams: Double
    public let fatGrams: Double
    public let carbsGrams: Double
    
    public var proteinCalories: Double { proteinGrams * 4.0 }
    public var fatCalories: Double { fatGrams * 9.0 }
    public var carbsCalories: Double { carbsGrams * 4.0 }
}

/// Движок расчёта норм питания
/// Под капотом используется формула Mifflin-St Jeor, но пользователю
/// выводятся только понятные карточки целей без научной перегрузки.
public enum CalorieEngine {
    
    /// Базовый метаболизм (BMR)
    public static func calculateBMR(weightKg: Double, heightCm: Double, age: Int, gender: Gender) -> Double {
        let base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age))
        return gender == .male ? (base + 5.0) : (base - 161.0)
    }
    
    /// Суточный расход энергии (TDEE)
    public static func calculateTDEE(weightKg: Double, heightCm: Double, age: Int, gender: Gender, activity: ActivityLevel) -> Double {
        let bmr = calculateBMR(weightKg: weightKg, heightCm: heightCm, age: age, gender: gender)
        return bmr * activity.multiplier
    }
    
    /// Расчёт рекомендуемого БЖУ под конкретную цель:
    /// - Белки: строго 2.0 г на 1 кг веса
    /// - Жиры: строго 1.0 г на 1 кг веса
    /// - Углеводы: рассчитываются из остатка суточной калорийности
    public static func target(for goal: FitnessGoal, weightKg: Double, heightCm: Double, age: Int, gender: Gender, activity: ActivityLevel) -> MacroTarget {
        let tdee = calculateTDEE(weightKg: weightKg, heightCm: heightCm, age: age, gender: gender, activity: activity)
        let targetCalories = max(1200.0, tdee + goal.calorieDelta)
        
        // 2 г белка на кг, 1 г жира на кг
        let proteinGrams = round(weightKg * 2.0)
        let fatGrams = round(weightKg * 1.0)
        
        let proteinAndFatKcal = (proteinGrams * 4.0) + (fatGrams * 9.0)
        let remainingKcal = max(0.0, targetCalories - proteinAndFatKcal)
        let carbsGrams = round(remainingKcal / 4.0)
        
        return MacroTarget(
            goal: goal,
            dailyCalories: round(targetCalories),
            proteinGrams: proteinGrams,
            fatGrams: fatGrams,
            carbsGrams: carbsGrams
        )
    }
    
    /// Список из 3 карточек (Похудение, Поддержание, Набор)
    public static func allTargets(weightKg: Double, heightCm: Double, age: Int, gender: Gender, activity: ActivityLevel) -> [MacroTarget] {
        return FitnessGoal.allCases.map { goal in
            target(for: goal, weightKg: weightKg, heightCm: heightCm, age: age, gender: gender, activity: activity)
        }
    }
}

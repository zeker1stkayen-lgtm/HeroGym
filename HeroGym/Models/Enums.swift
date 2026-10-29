import Foundation

public enum Gender: String, Codable, CaseIterable {
    case male = "Мужской"
    case female = "Женский"
}

public enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Сидячий (минимум движения)"
    case lightlyActive = "Лёгкая (1-3 тренировки/нед)"
    case moderatelyActive = "Средняя (3-5 тренировок/нед)"
    case veryActive = "Высокая (6-7 тренировок/нед)"
    case extraActive = "Экстра (тяжёлый труд / 2x в день)"
    
    public var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
}

public enum FitnessGoal: String, Codable, CaseIterable {
    case cut = "Похудение (Сушка)"
    case maintain = "Поддержание формы"
    case bulk = "Набор массы"
    
    public var calorieDelta: Double {
        switch self {
        case .cut: return -500.0
        case .maintain: return 0.0
        case .bulk: return 300.0
        }
    }
    
    public var badgeTitle: String {
        switch self {
        case .cut: return "🔻 ПОХУДЕНИЕ"
        case .maintain: return "⚖️ В БАЛАНСЕ"
        case .bulk: return "🔨 НАБОР МАССЫ"
        }
    }
}

public enum WorkoutType: String, Codable, CaseIterable {
    case strength = "Силовая"
    case cardio = "Кардио"
}

public enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Грудь"
    case back = "Спина"
    case shoulders = "Плечи"
    case arms = "Руки"
    case abs = "Пресс"
    case legs = "Ноги"
    
    public var id: String { rawValue }
}

public enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Завтрак"
    case lunch = "Обед"
    case dinner = "Ужин"
    case snack = "Перекус"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .breakfast: return "🍳"
        case .lunch: return "🍲"
        case .dinner: return "🥩"
        case .snack: return "🥪"
        }
    }
}

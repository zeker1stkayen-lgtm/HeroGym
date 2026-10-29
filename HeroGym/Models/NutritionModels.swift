import Foundation
import SwiftData

/// Запись отдельного приёма пищи
@Model
public final class MealEntry {
    public var id: UUID
    public var date: Date
    public var name: String          // Завтрак, Обед, Ужин, Перекус 1...
    public var protein: Double       // граммы
    public var fat: Double           // граммы
    public var carbs: Double         // граммы
    
    public var calories: Double {
        (protein * 4.0) + (fat * 9.0) + (carbs * 4.0)
    }
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String,
        protein: Double = 0.0,
        fat: Double = 0.0,
        carbs: Double = 0.0
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
}

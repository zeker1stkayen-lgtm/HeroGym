import Foundation
import SwiftData

/// Модель замеров тела (в сантиметрах)
@Model
public final class BodyMeasurements {
    public var date: Date
    public var chest: Double?    // Грудь
    public var waist: Double?    // Талия
    public var arms: Double?     // Руки (бицепс)
    public var glutes: Double?   // Ягодицы
    public var hips: Double?     // Бёдра
    public var calves: Double?   // Икры
    public var isTarget: Bool    // true = целевые замеры, false = текущие/исторические
    
    public init(
        date: Date = Date(),
        chest: Double? = nil,
        waist: Double? = nil,
        arms: Double? = nil,
        glutes: Double? = nil,
        hips: Double? = nil,
        calves: Double? = nil,
        isTarget: Bool = false
    ) {
        self.date = date
        self.chest = chest
        self.waist = waist
        self.arms = arms
        self.glutes = glutes
        self.hips = hips
        self.calves = calves
        self.isTarget = isTarget
    }
}

import Foundation
import SwiftData

/// Модель ежедневного взвешивания
@Model
public final class WeightEntry {
    public var id: UUID
    public var date: Date
    public var weight: Double       // кг
    public var isFastState: Bool    // взвешивание утром натощак
    public var note: String
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        isFastState: Bool = true,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.isFastState = isFastState
        self.note = note
    }
}

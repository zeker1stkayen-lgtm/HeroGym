import Foundation
import SwiftData

/// Модель тренировки
@Model
public final class Workout {
    public var id: UUID
    public var date: Date
    public var weekNumber: Int?     // Номер тренировочной недели (например, 5 или 6)
    public var workoutTypeRaw: String
    public var notes: String
    
    @Relationship(deleteRule: .cascade)
    public var exercises: [Exercise]
    
    public var workoutType: WorkoutType {
        get { WorkoutType(rawValue: workoutTypeRaw) ?? .strength }
        set { workoutTypeRaw = newValue.rawValue }
    }
    
    /// Суммарный тоннаж тренировки (кг)
    public var totalTonnage: Double {
        exercises.reduce(0.0) { sum, ex in
            sum + ex.tonnage
        }
    }
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        weekNumber: Int? = nil,
        workoutType: WorkoutType = .strength,
        notes: String = "",
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.date = date
        self.weekNumber = weekNumber
        self.workoutTypeRaw = workoutType.rawValue
        self.notes = notes
        self.exercises = exercises
    }
}

/// Упражнение внутри тренировки
@Model
public final class Exercise {
    public var id: UUID
    public var name: String                  // "Жим лёжа", "Гантели наклон", "Беговая дорожка"
    public var targetMuscleRaw: String       // MuscleGroup
    public var isCardio: Bool
    public var rpe: Int?                     // RPE 1-10 на всё упражнение ("Насколько тебе было тяжело?")
    
    // Поля для кардио:
    public var cardioDurationMinutes: Double? // Время (мин)
    public var cardioSpeed: Double?           // Скорость / Темп (км/ч или темп)
    
    @Relationship(deleteRule: .cascade)
    public var sets: [ExerciseSet]
    
    public var workout: Workout?
    
    public var targetMuscle: MuscleGroup {
        get { MuscleGroup(rawValue: targetMuscleRaw) ?? .chest }
        set { targetMuscleRaw = newValue.rawValue }
    }
    
    /// Тоннаж упражнения = сумма (вес × повторы × подходы)
    public var tonnage: Double {
        sets.reduce(0.0) { sum, set in
            sum + (set.weight * Double(set.reps * set.setsCount))
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        targetMuscle: MuscleGroup = .chest,
        isCardio: Bool = false,
        rpe: Int? = nil,
        cardioDurationMinutes: Double? = nil,
        cardioSpeed: Double? = nil,
        sets: [ExerciseSet] = []
    ) {
        self.id = id
        self.name = name
        self.targetMuscleRaw = targetMuscle.rawValue
        self.isCardio = isCardio
        self.rpe = rpe
        self.cardioDurationMinutes = cardioDurationMinutes
        self.cardioSpeed = cardioSpeed
        self.sets = sets
    }
}

/// Подход в упражнении
/// Поддерживает и одиночный подход (67х4), и пакетный формат из заметок (60х8х4 = вес 60, 8 повторов, 4 подхода)
@Model
public final class ExerciseSet {
    public var id: UUID
    public var setNumber: Int
    public var weight: Double    // кг
    public var reps: Int        // повторений
    public var setsCount: Int   // количество таких подходов (по умолчанию 1)
    
    public var exercise: Exercise?
    
    public init(
        id: UUID = UUID(),
        setNumber: Int = 1,
        weight: Double,
        reps: Int,
        setsCount: Int = 1
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.setsCount = setsCount
    }
}

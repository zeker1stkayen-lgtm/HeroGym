import Foundation
import SwiftData

/// Профиль пользователя и игрового персонажа
@Model
public final class UserProfile {
    public var name: String
    public var genderRaw: String
    public var age: Int
    public var height: Double          // см
    public var currentWeight: Double   // кг
    public var targetWeight: Double    // кг
    public var activityLevelRaw: String
    public var currentGoalRaw: String  // FitnessGoal
    
    // RPG статы:
    public var level: Int
    public var xp: Int
    
    @Relationship(deleteRule: .cascade)
    public var measurements: [BodyMeasurements]
    
    public var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .male }
        set { genderRaw = newValue.rawValue }
    }
    
    public var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelRaw) ?? .lightlyActive }
        set { activityLevelRaw = newValue.rawValue }
    }
    
    public var currentGoal: FitnessGoal {
        get { FitnessGoal(rawValue: currentGoalRaw) ?? .bulk }
        set { currentGoalRaw = newValue.rawValue }
    }
    
    public init(
        name: String = "Юсуп",
        gender: Gender = .male,
        age: Int = 25,
        height: Double = 177.0,
        currentWeight: Double = 67.0,
        targetWeight: Double = 72.0,
        activityLevel: ActivityLevel = .lightlyActive,
        currentGoal: FitnessGoal = .bulk,
        level: Int = 1,
        xp: Int = 0,
        measurements: [BodyMeasurements] = []
    ) {
        self.name = name
        self.genderRaw = gender.rawValue
        self.age = age
        self.height = height
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.activityLevelRaw = activityLevel.rawValue
        self.currentGoalRaw = currentGoal.rawValue
        self.level = level
        self.xp = xp
        self.measurements = measurements
    }
}

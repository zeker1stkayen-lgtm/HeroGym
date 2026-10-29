import SwiftUI

/// Главный TabView контейнер с 4 разделами приложения
public struct MainTabView: View {
    @State private var selectedTab: TabItem = .character
    
    public enum TabItem: Int, CaseIterable {
        case character = 0
        case nutrition = 1
        case workouts = 2
        case profile = 3
        
        var title: String {
            switch self {
            case .character: return "Персонаж"
            case .nutrition: return "Питание"
            case .workouts: return "Тренировки"
            case .profile: return "Профиль"
            }
        }
        
        var icon: String {
            switch self {
            case .character: return "person.crop.circle.badge.checkmark"
            case .nutrition: return "fork.knife"
            case .workouts: return "dumbbell.fill"
            case .profile: return "slider.horizontal.3"
            }
        }
    }
    
    public init() {
        // Настройка стандартного TabBar для тёмной темы WotLK
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(WotLKTheme.bgCard)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            CharacterView()
                .tabItem {
                    Label(TabItem.character.title, systemImage: TabItem.character.icon)
                }
                .tag(TabItem.character)
            
            NutritionView()
                .tabItem {
                    Label(TabItem.nutrition.title, systemImage: TabItem.nutrition.icon)
                }
                .tag(TabItem.nutrition)
            
            WorkoutListView()
                .tabItem {
                    Label(TabItem.workouts.title, systemImage: TabItem.workouts.icon)
                }
                .tag(TabItem.workouts)
            
            ProfileView()
                .tabItem {
                    Label(TabItem.profile.title, systemImage: TabItem.profile.icon)
                }
                .tag(TabItem.profile)
        }
        .tint(WotLKTheme.iceBright)
    }
}

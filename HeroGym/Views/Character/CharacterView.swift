import SwiftUI
import SwiftData

/// Экран «Персонаж» (без временного манекена):
/// - Уровень и шкала опыта
/// - Текущий и целевой вес
/// - Активный режим и план питания
/// - Динамический график веса
/// - Дисциплина режима (Streak)
public struct CharacterView: View {
    @Query private var profiles: [UserProfile]
    @State private var showCalendar = false
    
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
                        
                        // Шапка героя
                        VStack(spacing: 3) {
                            Text("⚔️ LEVEL \(profile.level) · РЫЦАРЬ СИЛЫ")
                                .font(.system(size: 11, weight: .black, design: .serif))
                                .tracking(2)
                                .foregroundColor(WotLKTheme.goldLight)
                            
                            Text(profile.name)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(WotLKTheme.textPrimary)
                        }
                        .padding(.top, 4)
                        
                        // Карточка героя
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [WotLKTheme.border, Color(hex: 0x0F172A)], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 54, height: 54)
                                    .overlay(Circle().stroke(WotLKTheme.gold, lineWidth: 2))
                                Text("⚔️")
                                    .font(.system(size: 24))
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text("\(String(format: "%.1f", profile.currentWeight)) кг")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(WotLKTheme.iceBright)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(WotLKTheme.textMuted)
                                    Text("\(String(format: "%.1f", profile.targetWeight)) кг")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(WotLKTheme.goldLight)
                                    Spacer()
                                    Text(profile.currentGoal.badgeTitle)
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(WotLKTheme.gold.opacity(0.15))
                                        .foregroundColor(WotLKTheme.goldLight)
                                        .cornerRadius(4)
                                }
                                
                                // Шкала XP
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3).fill(WotLKTheme.border)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(LinearGradient(colors: [Color(hex: 0x7C3AED), WotLKTheme.xpPurple], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: geo.size.width * 0.65)
                                    }
                                }
                                .frame(height: 6)
                                .padding(.top, 2)
                            }
                        }
                        .wotlkCard(hasGlow: true)
                        
                        // Блок параметров активной цели
                        VStack(spacing: 8) {
                            HStack {
                                Text("🎯 ТЕКУЩИЙ ПЛАН")
                                    .font(.system(size: 10, weight: .bold, design: .serif))
                                    .foregroundColor(WotLKTheme.iceLight)
                                Spacer()
                                Text("Калории под цель")
                                    .font(.system(size: 10))
                                    .foregroundColor(WotLKTheme.textMuted)
                            }
                            
                            HStack {
                                Text("Суточная норма:")
                                    .font(.system(size: 12))
                                    .foregroundColor(WotLKTheme.textPrimary)
                                Spacer()
                                Text(profile.currentGoal == .cut ? "1,770 ккал" : (profile.currentGoal == .bulk ? "2,570 ккал" : "2,270 ккал"))
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(WotLKTheme.goldLight)
                            }
                        }
                        .wotlkCard()
                        
                        // ДИНАМИЧЕСКИЙ ГРАФИК ВЕСА
                        weightChartSection
                        
                        // Дисциплина режима (Streak)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("🛡 Дисциплина режима (Streak)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(WotLKTheme.textPrimary)
                                Spacer()
                                Text("6 дней подряд 🔥")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(WotLKTheme.iceBright)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3).fill(WotLKTheme.border)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(LinearGradient(colors: [WotLKTheme.ice, WotLKTheme.iceBright], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * 0.85)
                                }
                            }
                            .frame(height: 8)
                        }
                        .wotlkCard()
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Персонаж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCalendar = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("Летопись")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(WotLKTheme.iceBright)
                    }
                }
            }
            .sheet(isPresented: $showCalendar) {
                DaySummaryCalendarView()
            }
        }
    }
    
    // MARK: - Weight Chart Section
    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📈 ДИНАМИКА ВЕСА (КГ)")
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundColor(WotLKTheme.iceLight)
                Spacer()
                Text("Сегодня: \(String(format: "%.1f", profile.currentWeight)) кг")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(WotLKTheme.goldLight)
            }
            
            let samplePoints = [66.4, 66.7, 66.5, 66.9, 66.8, profile.currentWeight]
            let dates = ["24 окт", "25 окт", "26 окт", "27 окт", "28 окт", "Сегодня"]
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<samplePoints.count, id: \.self) { i in
                    VStack(spacing: 3) {
                        Text(String(format: "%.1f", samplePoints[i]))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(WotLKTheme.iceBright)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(colors: [WotLKTheme.ice, WotLKTheme.iceBright], startPoint: .bottom, endPoint: .top))
                            .frame(height: max(20, CGFloat((samplePoints[i] - 65.0) * 35.0)))
                        
                        Text(dates[i])
                            .font(.system(size: 8))
                            .foregroundColor(WotLKTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 95)
            .padding(.top, 4)
        }
        .wotlkCard()
    }
}

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showAdd = false
    @State private var showConfetti = false
    @State private var previousXP = 0
    @State private var isBouncing = false


    var totalHabits: Int { store.habits.count }
    var totalCompletions: Int { store.habits.reduce(0) { $0 + $1.completionCount() } }
    var avgStreak: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(store.habits.reduce(0) { $0 + $1.currentStreak() }) / Double(totalHabits)
    }
    var level: Int { 1 + store.xp / 100 }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBrand
                    quoteCard
                    statsRow
                    insights
                }
                .padding()
            }

            ConfettiView(isActive: $showConfetti)
        }
        .onChange(of: store.xp) { newValue in
            if newValue > previousXP {
                showConfetti = true
                previousXP = newValue
            }
        }
        .onReceive(store.objectWillChange) { _ in }  // live refresh

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddHabitView().environmentObject(store)
        }
    }


    private var headerBrand: some View {
        HStack(spacing: 12) {

            Image("NanoBot_Header")
                .resizable()
                .scaledToFit()
                .font(.system(size: 34))
                .foregroundColor(Color("Ultramarine"))
                .scaleEffect(isBouncing ? 1.3 : 1.0)
                .animation(.spring(response: 0.45, dampingFraction: 0.45), value: isBouncing)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isBouncing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isBouncing = false
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("NanoSteps")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color("Ultramarine"))
                Text("Dashboard")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
                Text("Level \(level) • XP \(store.xp)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.bottom, 6)
    }


    private var quoteCard: some View {
        VStack(alignment: .leading) {
            Text("Quote of the Day").font(.headline)
            Text(dailyQuote())
                .font(.subheadline)
                .padding(.top, 2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color("Ultramarine").opacity(0.08))
        .cornerRadius(12)
    }

    private var statsRow: some View {
        HStack(spacing: 20) {
            XPProgressRing(xp: store.xp)
            VStack(alignment: .leading) {
                Text("XP Progress").font(.caption).foregroundStyle(.secondary)
                Text("Level \(level)").font(.title2.bold())
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("XP Progress Level \(level)")
    }

    private var insights: some View {
        VStack(alignment: .leading) {
            Text("Top Habits").font(.headline)
            let sorted = store.habits.sorted { $0.currentStreak() > $1.currentStreak() }
            if sorted.isEmpty {
                Text("Add habits to see insights here.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(sorted.prefix(3)) { habit in
                    HStack {
                        Text(habit.title).font(.subheadline.bold())
                        Spacer()
                        Text("\(habit.currentStreak()) days")
                            .foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }

    private func dailyQuote() -> String {
        let quotes = [
            "Small steps = big results 🚀",
            "Systems shape success — tiny daily wins.",
            "Make it obvious. Make it easy. Make it fun.",
            "Identity grows from tiny actions 🌱",
            "Consistency beats motivation 🧠"
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return quotes[day % quotes.count]
    }
}

struct XPProgressRing: View {
    var xp: Int
    let levelUpXP = 100

    var progress: Double {
        Double(xp % levelUpXP) / Double(levelUpXP)
    }

    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color("Ultramarine"), .mint]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%").font(.caption.bold())
        }
        .frame(width: 68, height: 68)
        .animation(.easeInOut, value: progress)
    }
}

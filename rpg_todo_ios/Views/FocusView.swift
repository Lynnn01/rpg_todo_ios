import SwiftUI

struct FocusView: View {
    @State private var timeRemaining = 1800 // 30 minutes
    @State private var isActive = false
    @State private var events: [Event] = []
    @State private var totalExp = 0
    @State private var totalGold = 0
    @State private var playerHealth = 100
    @State private var focusPoints = 0
    @State private var showingSetTimeModal = false
    @State private var showingAdventureLog = false
    @State private var showingSummary = false
    @State private var tempTime = 30

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let eventTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        showingAdventureLog.toggle()
                    }) {
                        Text("⚔️")
                            .font(.largeTitle)
                    }
                    
                    Spacer()
                    Text("Focus")
                        .foregroundColor(Color(red: 236.0/255.0, green: 106.0/255.0, blue: 82.0/255.0))
                        .font(.system(size: 34, weight: .bold))
                    + Text("Mode")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title)
                    
                }
                .padding()

                // Countdown Timer and Focus Points
                VStack {
                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Focus Points: \(focusPoints)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding()

                // Main Content
                VStack(spacing: 16) {
                    Button(action: {
                        self.isActive.toggle()
                    }) {
                        Text(isActive ? "Pause" : "Focus +")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isActive ? Color.orange : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        self.resetGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }

                    Button(action: {
                        self.showingSetTimeModal = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text("Set Time")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                }
                .padding()

                Spacer()

                // Status View
                HStack {
                    StatusView(title: "Health", value: playerHealth, color: .red)
                    StatusView(title: "EXP", value: totalExp, color: .green)
                    StatusView(title: "Gold", value: totalGold, color: .yellow)
                }
                .padding()
            }

            // Custom Popup
            if showingSummary {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Adventure Summary")
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        SummaryRow(icon: "🧠", title: "Focus Points", value: "\(focusPoints)")
                        SummaryRow(icon: "📊", title: "Total EXP", value: "\(totalExp)")
                        SummaryRow(icon: "💰", title: "Total Gold", value: "\(totalGold)")
                        SummaryRow(icon: "❤️", title: "Final Health", value: "\(playerHealth)")
                    }
                    
                    Button(action: {
                        showingSummary = false
                    }) {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(30)
            }
        }
        .sheet(isPresented: $showingSetTimeModal) {
            SetTimeView(tempTime: $tempTime, isPresented: $showingSetTimeModal) {
                self.timeRemaining = tempTime * 60
            }
        }
        .sheet(isPresented: $showingAdventureLog) {
            AdventureLogView(events: events)
        }
        .onReceive(timer) { _ in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.focusPoints += 1
            } else {
                self.isActive = false
                self.showSummary()
            }
        }
        .onReceive(eventTimer) { _ in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.generateEvent()
            }
        }
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func generateEvent() {
        var randomEvent = "Enemy"
        let ranNumber = arc4random_uniform(100)
        if ranNumber > 70{
            randomEvent = "Enemy"
        }
        else if ranNumber > 20{
             randomEvent = "Rest"
        }
        else{
            randomEvent = "Treasure"
        }
        
        
        switch randomEvent {
        case "Enemy":
            let enemies = ["Goblin", "Orc", "Dragon", "Skeleton"]
            let enemy = enemies.randomElement()!
            let damage = Int.random(in: 1...10)
            let exp = Int.random(in: 10...50)
            let gold = Int.random(in: 5...30)

            playerHealth = max(0, playerHealth - damage)
            totalExp += exp
            totalGold += gold

            events.insert(Event(icon: "⚔️", title: "Battle", description: "Encountered a \(enemy)! Took \(damage) damage. Gained \(exp) EXP and \(gold) Gold."), at: 0)
        case "Treasure":
            let treasureTypes = ["Potion", "Armor", "Weapon"]
            let treasure = treasureTypes.randomElement()!
            let gold = Int.random(in: 20...100)

            totalGold += gold
            events.insert(Event(icon: "💎", title: "Treasure", description: "Found a \(treasure)! Gained \(gold) Gold."), at: 0)
        case "Rest":
            let healing = Int.random(in: 5...20)
            playerHealth = min(playerHealth + healing, 100)
            events.insert(Event(icon: "🏕️", title: "Rest", description: "Found a safe spot to rest. Healed \(healing) HP."), at: 0)
        default:
            break
        }
    }

    func showSummary() {
        events.insert(Event(icon: "🏁", title: "Summary", description: "Adventure completed!"), at: 0)
        showingSummary = true
    }

    func resetGame() {
        timeRemaining = 1800
        isActive = false
        events = []
        totalExp = 0
        totalGold = 0
        playerHealth = 100
        focusPoints = 0
    }
}

struct StatusView: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 28))
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct SetTimeView: View {
    @Binding var tempTime: Int
    @Binding var isPresented: Bool
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Stepper(value: $tempTime, in: 1...120) {
                    Text("\(tempTime) minutes")
                }
            }
            .navigationBarTitle("Set Time", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    onSave()
                    isPresented = false
                }
            )
        }
    }
}

struct Event: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct AdventureLogView: View {
    let events: [Event]
    var body: some View {
        NavigationView {
            List(events) { event in
                HStack(alignment: .top, spacing: 15) {
                    Text(event.icon)
                        .font(.system(size: 40))
                        .frame(width: 60)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationBarTitle("Adventure Log", displayMode: .inline)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}

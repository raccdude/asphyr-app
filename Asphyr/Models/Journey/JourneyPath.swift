//
//  JourneyPath.swift
//  Asphyr
//

import Foundation

struct JourneyStar {
    let name: String
    let goal: String
    /// Completed quests needed to light this star.
    let questsNeeded: Int
    let iconName: String
}

/// Where the user is on the constellation, worked out from completed quests.
struct JourneyProgress {
    enum State: Equatable {
        case newUser
        case onTheWay
        case starUnlocked
        case welcomeBack
        case allLit
        case chapterComplete
        case chapterStart
    }

    static let welcomeBackDays = 3

    let stars: [JourneyStar]
    let completedQuests: Int
    let litStarsAlreadySeen: Int
    let lastCompletedAt: Date?
    var chapterIndex = 0
    /// True until the user has seen that the previous chapter finished.
    var hasChapterNews = false

    static func stars(aspiration: String?) -> [JourneyStar] {
        JourneyPath.path(for: aspiration).stars
    }

    var litCount: Int {
        stars.filter { completedQuests >= $0.questsNeeded }.count
    }

    /// The next star to light. Nil once they're all lit.
    var currentIndex: Int? {
        litCount < stars.count ? litCount : nil
    }

    var questsUntilNextStar: Int {
        currentIndex.map { stars[$0].questsNeeded - completedQuests } ?? 0
    }

    func state(at date: Date = .now) -> State {
        if completedQuests == 0 {
            if chapterIndex == 0 { return .newUser }
            return hasChapterNews ? .chapterComplete : .chapterStart
        }
        if litCount > litStarsAlreadySeen { return .starUnlocked }
        if currentIndex == nil { return .allLit }

        if let lastCompletedAt,
           let days = Calendar.current.dateComponents([.day], from: lastCompletedAt, to: date).day,
           days >= Self.welcomeBackDays {
            return .welcomeBack
        }
        return .onTheWay
    }
}

/// How the journey's quests divide into chapters. Each takes 20 quests, and the
/// quests finished in one chapter carry straight on into the next.
enum JourneyChapters {
    static let count = 5
    static let questsPerChapter = 20

    static func currentIndex(completedQuests: Int) -> Int {
        min(completedQuests / questsPerChapter, count - 1)
    }

    static func quests(completedQuests: Int, inChapter chapter: Int) -> Int {
        min(questsPerChapter, max(0, completedQuests - chapter * questsPerChapter))
    }
}

/// The stars for one aspiration: a real constellation that represents it, with
/// names and goals for each star. The last star masters one skill, never the
/// aspiration itself, because no one reaches a dream in 20 quests.
struct JourneyPath {
    private static let totalQuests = 20

    let constellation: Constellation
    let stars: [JourneyStar]

    /// Spreads the same 20 quests evenly, however many stars there are.
    static func questThresholds(starCount: Int) -> [Int] {
        (0..<starCount).map { index in
            Int((1 + Double(totalQuests - 1) * Double(index) / Double(starCount - 1)).rounded())
        }
    }

    /// Star names and goals in order. The third star uses the aspiration's icon,
    /// and the last is always the crown.
    private init(constellationID: String, iconName: String, _ steps: [(name: String, goal: String)]) {
        guard let constellation = Constellation.all[constellationID] else {
            preconditionFailure("Unknown constellation \(constellationID)")
        }
        let generalIcons = ["iconJourneyCompass", "iconAttributeProblemSolving", "iconQuestBook"]
        let thresholds = Self.questThresholds(starCount: steps.count)

        self.constellation = constellation
        stars = steps.indices.map { index in
            let icon: String
            switch index {
            case 0: icon = "iconJourneyFlag"
            case 1: icon = "iconJourneyTarget"
            case 2: icon = iconName
            case steps.count - 1: icon = "iconJourneyCrown"
            default: icon = generalIcons[(index - 3) % generalIcons.count]
            }

            return JourneyStar(
                name: steps[index].name,
                goal: steps[index].goal,
                questsNeeded: thresholds[index],
                iconName: icon
            )
        }
    }

    /// The five chapters: the aspiration's own path, then four more constellations
    /// that suit it. Each is written for the aspiration, except custom aspirations,
    /// which use themed stars about how the journey grows.
    static func chapters(for aspiration: String?) -> [JourneyPath] {
        let name = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let order = chapterOrder[name] ?? ["Her", "Aur", "Peg", "Lyr"]

        let written = laterChapters[name]

        return [path(for: aspiration)] + order.enumerated().map { index, id in
            guard let lines = written?[index] else {
                return themed(constellationID: id, theme: themes[index])
            }

            let steps = lines.map { line -> (name: String, goal: String) in
                let parts = line.split(separator: "|")
                return (String(parts[0]), String(parts[1]))
            }
            return JourneyPath(constellationID: id, iconName: themes[index].iconName, steps)
        }
    }

    private static func themed(constellationID: String, theme: Theme) -> JourneyPath {
        let starCount = Constellation.all[constellationID]?.stars.count ?? theme.steps.count + 1
        return JourneyPath(
            constellationID: constellationID,
            iconName: theme.iconName,
            Array(theme.steps.prefix(starCount - 1)) + [theme.destination]
        )
    }

    private typealias Theme = (iconName: String, steps: [(name: String, goal: String)], destination: (name: String, goal: String))

    private static let chapterOrder: [String: [String]] = [
        "game developer": ["Her", "Per", "Peg", "UMi"],
        "mechanical engineer": ["Aur", "Vel", "Her", "UMi"],
        "psychologist": ["Cen", "Oph", "Cyg", "UMi"],
        "doctor": ["Cen", "Her", "Per", "UMi"],
        "writer": ["Lyr", "Peg", "Per", "UMi"],
        "artist": ["CrB", "Lyr", "Cyg", "UMi"],
        "entrepreneur": ["UMi", "Aur", "Her", "Dra"],
        "musician": ["Cyg", "Peg", "Cen", "UMi"],
        "athlete": ["Per", "Dra", "Cen", "UMi"],
        "teacher": ["Oph", "UMi", "Lyr", "Her"],
        "designer": ["Peg", "Lyr", "Aur", "UMi"],
        "engineer": ["Hor", "Vel", "Her", "UMi"]
    ]

    private static let themes: [Theme] = [
        ("iconQuestHammer", [
            ("Steady Start", "Show up again"),
            ("Daily Rhythm", "Make it part of your day"),
            ("Skill Builder", "Practice what’s hard"),
            ("Second Wind", "Keep going when it’s dull"),
            ("Quick Learner", "Learn from a mistake"),
            ("Habit Keeper", "Hold a steady streak"),
            ("Fine Tuner", "Polish one small skill"),
            ("Reliable Hand", "Get it right every time"),
            ("Dedicated", "Choose practice over mood")
        ], ("Practice Keeper", "Make practice a habit")),
        ("iconBulb", [
            ("Deep Diver", "Go past the basics"),
            ("Question Asker", "Ask why it works"),
            ("Pattern Finder", "Spot what connects"),
            ("Careful Thinker", "Slow down and check"),
            ("Note Taker", "Write down what you learn"),
            ("Puzzle Solver", "Crack a hard problem"),
            ("Second Reader", "Revisit something hard"),
            ("Clear Explainer", "Explain it simply"),
            ("Expert in Training", "Learn from the best")
        ], ("Depth Keeper", "Understand it deeply")),
        ("iconSparklesSmall", [
            ("Risk Taker", "Try the harder way"),
            ("Own Voice", "Do it your own way"),
            ("Project Starter", "Begin something real"),
            ("Finisher", "See a project through"),
            ("Sharer", "Show your work"),
            ("Feedback Seeker", "Ask for honest notes"),
            ("Comeback", "Recover from a setback"),
            ("Bold Mover", "Take on a real challenge"),
            ("Standout", "Make something you love")
        ], ("Craft Keeper", "Make work you’re proud of")),
        ("iconQuestBook", [
            ("Guide", "Help someone starting out"),
            ("Mentor", "Share what you know"),
            ("Team Player", "Build something together"),
            ("Steady Leader", "Keep others going"),
            ("Big Picture", "See how it all connects"),
            ("Long Hauler", "Think in years"),
            ("Pathfinder", "Go where few have gone"),
            ("Trusted Voice", "Be someone others ask"),
            ("Lifelong Student", "Stay curious")
        ], ("Trailblazer", "Keep going beyond the map"))
    ]

    /// Matches listed and popular aspirations whatever their capitals or spacing.
    /// Anything else is a custom aspiration, which gets the general path.
    static func path(for aspiration: String?) -> JourneyPath {
        let name = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return paths[name] ?? general
    }

    private static let general = JourneyPath(constellationID: "UMi", iconName: "iconSparklesSmall", [
        ("First Steps", "Complete your first quest"),
        ("Consistency", "Keep showing up"),
        ("Apprentice", "Learn the basics"),
        ("Practitioner", "Put your skills to use"),
        ("Problem Solver", "Solve something hard"),
        ("Expert", "Go deeper than before"),
        ("Foundations Master", "Master the basics")
    ])

    private static let paths: [String: JourneyPath] = [
        "game developer": JourneyPath(constellationID: "Dra", iconName: "iconLaptop", [
            ("First Prototype", "Make something playable"),
            ("Game Jammer", "Finish small games often"),
            ("Mechanics Coder", "Make a mechanic feel good"),
            ("Level Designer", "Design a replayable level"),
            ("Art Tinkerer", "Give the game your look"),
            ("Sound Tinkerer", "Give the game its sound"),
            ("Bug Hunter", "Track down a tricky bug"),
            ("Playtester", "Watch people play it"),
            ("Polisher", "Polish the small details"),
            ("Prototype Master", "Finish a small game")
        ]),
        "mechanical engineer": JourneyPath(constellationID: "Hor", iconName: "iconWrench", [
            ("First Sketch", "Draw your first design"),
            ("Tinkerer", "Take things apart and learn"),
            ("Drafter", "Model a part in detail"),
            ("Prototyper", "Build something that moves"),
            ("Workshop Master", "Build a working model")
        ]),
        "psychologist": JourneyPath(constellationID: "Per", iconName: "iconBulb", [
            ("First Question", "Get curious about the mind"),
            ("Observer", "Notice how people behave"),
            ("Note Taker", "Track what you notice"),
            ("Student of Mind", "Learn the core theories"),
            ("Researcher", "Read a study closely"),
            ("Listener", "Listen with care"),
            ("Empath", "See another side"),
            ("Case Thinker", "Link theory to people"),
            ("Observation Master", "Understand behavior")
        ]),
        "doctor": JourneyPath(constellationID: "Oph", iconName: "iconStethoscope", [
            ("First Lesson", "Begin your medical studies"),
            ("Study Habit", "Study a little every day"),
            ("Anatomy Student", "Learn how the body works"),
            ("Clinical Mind", "Reason through cases"),
            ("Case Reader", "Study real cases"),
            ("Diagnostician", "Solve a hard diagnosis"),
            ("Good Listener", "Talk with patients"),
            ("Caregiver", "Learn to care for people"),
            ("Anatomy Master", "Master the body’s basics")
        ]),
        "writer": JourneyPath(constellationID: "Cyg", iconName: "iconPen", [
            ("First Page", "Write your first page"),
            ("Daily Writer", "Write a little every day"),
            ("Close Reader", "Study writers you admire"),
            ("Storyteller", "Finish a short piece"),
            ("Drafter", "Complete a full draft"),
            ("Editor", "Rewrite until it reads right"),
            ("Feedback Seeker", "Get someone to read it"),
            ("Stylist", "Find your own voice"),
            ("Story Master", "Finish a story you love")
        ]),
        "artist": JourneyPath(constellationID: "Peg", iconName: "iconCreator", [
            ("First Sketch", "Make your first piece"),
            ("Daily Sketcher", "Draw a little every day"),
            ("Line Student", "Learn to see and draw form"),
            ("Color Student", "Study color and light"),
            ("Composer", "Plan a piece with intention"),
            ("Experimenter", "Try a new medium"),
            ("Studio Critic", "Learn from your own work"),
            ("Visionary", "Develop your own style"),
            ("Sketch Master", "Fill a sketchbook")
        ]),
        "entrepreneur": JourneyPath(constellationID: "Vel", iconName: "iconStrategist", [
            ("First Idea", "Name a problem worth solving"),
            ("Validator", "Talk to people who have it"),
            ("Planner", "Shape the idea into a plan"),
            ("Builder", "Make a first version"),
            ("Problem Solver", "Get past a real setback"),
            ("Pitcher", "Explain your idea simply"),
            ("Seller", "Win your first customers"),
            ("Idea Master", "Prove people want your idea")
        ]),
        "musician": JourneyPath(constellationID: "Lyr", iconName: "iconSparklesSmall", [
            ("First Notes", "Play your first notes"),
            ("Daily Practice", "Practice a little every day"),
            ("Ear Trainer", "Hear what you play"),
            ("Improviser", "Play without the page"),
            ("Songwriter", "Write your own piece"),
            ("Practice Master", "Play for someone")
        ]),
        "athlete": JourneyPath(constellationID: "Her", iconName: "iconExplorer", [
            ("First Session", "Finish your first workout"),
            ("Regular", "Train on a steady schedule"),
            ("Trainee", "Learn the right technique"),
            ("Endurance", "Go further than last time"),
            ("Competitor", "Test yourself"),
            ("Comeback", "Push through a hard stretch"),
            ("Strategist", "Train with a plan"),
            ("Training Master", "Finish a training block")
        ]),
        "teacher": JourneyPath(constellationID: "Cen", iconName: "iconScholar", [
            ("First Lesson", "Explain something to someone"),
            ("Lifelong Learner", "Study every day"),
            ("Lesson Planner", "Plan a complete lesson"),
            ("Explainer", "Make a hard idea simple"),
            ("Classroom Guide", "Teach a group"),
            ("Question Asker", "Ask questions that matter"),
            ("Problem Solver", "Help a struggling learner"),
            ("Mentor", "Guide someone over time"),
            ("Lesson Master", "Teach a lesson that lands")
        ]),
        "designer": JourneyPath(constellationID: "CrB", iconName: "iconCreator", [
            ("First Draft", "Design your first page"),
            ("Daily Designer", "Design a little every day"),
            ("Layout Student", "Learn type, color and layout"),
            ("Prototyper", "Make an idea you can try"),
            ("User Tester", "Watch people use it"),
            ("Systems Designer", "Make a design consistent"),
            ("Layout Master", "Finish a design you love")
        ]),
        "engineer": JourneyPath(constellationID: "Aur", iconName: "iconWrench", [
            ("First Build", "Build something small"),
            ("Tinkerer", "Learn how things work"),
            ("Apprentice", "Learn the fundamentals"),
            ("Maker", "Build something useful"),
            ("Debugger", "Fix a hard problem"),
            ("Systems Thinker", "See the whole system"),
            ("Build Master", "Finish a working build")
        ])
    ]
}

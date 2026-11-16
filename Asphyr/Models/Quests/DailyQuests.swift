//
//  DailyQuests.swift
//  Asphyr
//

import Foundation

/// The system's daily quests, written for each aspiration and archetype, with a
/// different one each day. Custom aspirations and Login use the general set.
enum DailyQuests {
    private typealias Entry = (title: String, description: String)
    private typealias Pool = (category: String, quests: [Archetype: [Entry]])

    /// A new daily quest for that day. The archetype shapes the objective and
    /// its main attribute, and the aspiration's category gives the second.
    static func quest(aspiration: String?, archetype: Archetype?, on date: Date) -> Quest {
        let archetype = archetype ?? .explorer
        let key = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let pool = pools[key] ?? general
        let entries = pool.quests[archetype] ?? []
        let day = Int(Calendar.current.startOfDay(for: date).timeIntervalSinceReferenceDate / 86_400)
        let entry = entries[((day % entries.count) + entries.count) % entries.count]

        return Quest(
            type: .dailyQuest,
            title: entry.title,
            description: entry.description,
            objective: objective(for: archetype),
            iconName: JourneyPath.path(for: aspiration).stars[2].iconName,
            category: pool.category.uppercased(),
            difficulty: .moderate,
            durationMinutes: 30,
            xpReward: RewardRules.xp(minutes: 30, difficulty: .moderate),
            attributeRewards: attributes(archetype: archetype, category: pool.category),
            status: .available,
            generatedOn: date
        )
    }

    private static func objective(for archetype: Archetype) -> String {
        switch archetype {
        case .strategist: "Decide your approach first, then follow your plan."
        case .scholar: "Learn it well enough to explain it to someone."
        case .creator: "Finish with something you can show."
        case .explorer: "Try an approach you haven’t used before."
        }
    }

    private static func attributes(archetype: Archetype, category: String) -> [AttributeReward] {
        let main: String
        switch archetype {
        case .strategist: main = "PROBLEM SOLVING"
        case .scholar: main = "KNOWLEDGE"
        case .creator: main = "CREATIVITY"
        case .explorer: main = "DISCIPLINE"
        }

        let fromCategory = RewardRules.attributes(category: category, difficulty: .moderate).map(\.name)
        let second = fromCategory.first { $0 != main } ?? (main == "DISCIPLINE" ? "KNOWLEDGE" : "DISCIPLINE")
        return [AttributeReward(name: main, value: 5), AttributeReward(name: second, value: 2)]
    }

    private static let general: Pool = ("Other", [
        .strategist: [
            ("Map your next month", "Choose one goal and the steps to reach it."),
            ("Find your bottleneck", "Work out what’s slowing your progress most."),
            ("Review your week", "See what worked and what to change.")
        ],
        .scholar: [
            ("Learn one new concept", "Pick something in your field you can’t explain yet."),
            ("Read an expert’s advice", "Note the three most useful points."),
            ("Teach yourself a basic", "Go back to a fundamental you skipped.")
        ],
        .creator: [
            ("Make a small thing", "Create something related to your goal."),
            ("Sketch your idea", "Get a rough version out of your head."),
            ("Improve past work", "Take something old and make it better.")
        ],
        .explorer: [
            ("Try a new method", "Do a familiar task in an unfamiliar way."),
            ("Ask someone ahead of you", "Find out what they wish they’d known."),
            ("Sample a new corner", "Explore a part of your field you’ve never tried.")
        ]
    ])

    private static let pools: [String: Pool] = [
        "game developer": ("Development", [
            .strategist: [
                ("Plan a core loop", "Map what players do again and again."),
                ("Scope a tiny game", "Cut an idea down to one week of work."),
                ("Balance one mechanic", "Decide the numbers that make it fair.")
            ],
            .scholar: [
                ("Study a favorite game", "Work out why one mechanic feels good."),
                ("Learn a game pattern", "Read about one common code pattern."),
                ("Break down a level", "Note how a great level teaches its player.")
            ],
            .creator: [
                ("Build a small mechanic", "Turn a simple idea into a working feature."),
                ("Design one character", "Give it a look and a way to move."),
                ("Make a one-room level", "Build one small space worth playing.")
            ],
            .explorer: [
                ("Try a new genre", "Play something unlike what you usually make."),
                ("Test a strange idea", "Prototype a rule no game you know uses."),
                ("Try a new engine feature", "Use a tool you’ve never opened.")
            ]
        ]),
        "mechanical engineer": ("Development", [
            .strategist: [
                ("Plan a simple assembly", "List its parts and the build order."),
                ("Compare two materials", "Choose one for a job and explain why."),
                ("Find a weak point", "Work out where a design would fail first.")
            ],
            .scholar: [
                ("Study how gears work", "Learn how ratios change speed and force."),
                ("Review stress and strain", "Work through one example by hand."),
                ("Learn a mechanism", "Find out how a common machine moves.")
            ],
            .creator: [
                ("Sketch a mechanism", "Draw a part that turns motion into work."),
                ("Model a simple part", "Draft a bracket or hinge in detail."),
                ("Build a paper prototype", "Test a moving idea with card and pins.")
            ],
            .explorer: [
                ("Take something apart", "Open an old object and see how it works."),
                ("Spot machines around you", "Work out how one everyday device moves."),
                ("Try a new CAD tool", "Use a feature you’ve never touched.")
            ]
        ]),
        "psychologist": ("Learning", [
            .strategist: [
                ("Design a small study", "Choose a question and how you’d test it."),
                ("Map a thought pattern", "Trace how one belief shapes a behavior."),
                ("Plan a habit change", "Use a known technique on one habit.")
            ],
            .scholar: [
                ("Read about a bias", "Learn one cognitive bias and an example."),
                ("Summarize a classic study", "Note what it found and its limits."),
                ("Compare two theories", "See where they agree and disagree.")
            ],
            .creator: [
                ("Write a case vignette", "Describe a fictional person and their struggle."),
                ("Explain a concept simply", "Make one idea clear for a friend."),
                ("Keep a mood journal", "Record what shifted your mood today.")
            ],
            .explorer: [
                ("Watch behavior in public", "Notice one pattern in how people act."),
                ("Practice active listening", "Try it in one real conversation."),
                ("Try a mindfulness exercise", "Note what you notice in yourself.")
            ]
        ]),
        "doctor": ("Learning", [
            .strategist: [
                ("Plan your study week", "Divide one topic into daily sessions."),
                ("Work through a case", "Reason from symptoms to a likely cause."),
                ("Build a diagnosis chart", "Compare conditions with similar symptoms.")
            ],
            .scholar: [
                ("Study one body system", "Learn how its main parts work together."),
                ("Learn ten terms", "Master ten medical terms from one topic."),
                ("Review one condition", "Learn its causes, signs and treatment.")
            ],
            .creator: [
                ("Draw an anatomy diagram", "Sketch and label one system from memory."),
                ("Make flashcards", "Create a set for a topic you find hard."),
                ("Write a patient explanation", "Explain a condition in plain language.")
            ],
            .explorer: [
                ("Read about a specialty", "Learn what a day in it looks like."),
                ("Learn a first aid skill", "Pick one you don’t already know."),
                ("Talk with a health worker", "Ask what surprised them about the job.")
            ]
        ]),
        "writer": ("Creative", [
            .strategist: [
                ("Outline a short story", "Plan its beginning, middle and end."),
                ("Map a character arc", "Decide how someone changes and why."),
                ("Plan a revision", "List what one draft needs most.")
            ],
            .scholar: [
                ("Study a great opening", "Work out why one first page hooks you."),
                ("Learn a structure", "Read about one way stories are built."),
                ("Analyze a scene", "Note how a writer builds its tension.")
            ],
            .creator: [
                ("Write one scene", "Put two characters in a tense moment."),
                ("Write 300 words", "Draft without stopping to edit."),
                ("Rewrite a paragraph", "Make one of your own passages sharper.")
            ],
            .explorer: [
                ("Write in a new genre", "Draft a short piece outside your usual style."),
                ("Write from a stranger’s view", "Imagine someone you noticed today."),
                ("Use a random prompt", "Start from a word you didn’t choose.")
            ]
        ]),
        "artist": ("Creative", [
            .strategist: [
                ("Plan a composition", "Make three thumbnails and choose one."),
                ("Build a color palette", "Pick colors for a mood and test them."),
                ("Set a series theme", "Plan three pieces that belong together.")
            ],
            .scholar: [
                ("Study an artist you love", "Note how they use light and color."),
                ("Learn a shading technique", "Practice it on one simple object."),
                ("Copy a master’s detail", "Learn by redrawing one small section.")
            ],
            .creator: [
                ("Draw from life", "Sketch one object in front of you."),
                ("Finish a small piece", "Take one idea from start to done."),
                ("Paint a mood", "Show one feeling using only color.")
            ],
            .explorer: [
                ("Try a new medium", "Use a material you’ve never worked with."),
                ("Draw without looking", "See what your hand does on its own."),
                ("Sketch outdoors", "Capture something outside your usual space.")
            ]
        ]),
        "entrepreneur": ("Career", [
            .strategist: [
                ("Map your competitors", "Compare three and find what’s missing."),
                ("Work out your pricing", "Estimate your costs and a fair price."),
                ("Set one quarterly goal", "Choose the number that matters most.")
            ],
            .scholar: [
                ("Study a founder’s story", "Note one decision that changed everything."),
                ("Learn one business model", "See how a company you use makes money."),
                ("Learn a finance basic", "Understand cash flow or margin.")
            ],
            .creator: [
                ("Write a one-line pitch", "Say who it’s for and why it matters."),
                ("Mock up your offer", "Make a simple page describing your idea."),
                ("Draft a customer email", "Write to someone who has the problem.")
            ],
            .explorer: [
                ("Talk to a customer", "Ask one person about their problem."),
                ("Find a new problem", "List three annoyances you noticed today."),
                ("Test an idea cheaply", "Find the smallest way to learn if it works.")
            ]
        ]),
        "musician": ("Creative", [
            .strategist: [
                ("Plan a practice routine", "Split your time across three skills."),
                ("Break down a hard passage", "Find the exact bars holding you back."),
                ("Map a song’s structure", "Chart its sections and changes.")
            ],
            .scholar: [
                ("Learn a scale", "Master one scale slowly and evenly."),
                ("Study a chord progression", "Find out why it sounds the way it does."),
                ("Listen closely to a song", "Follow one instrument from start to end.")
            ],
            .creator: [
                ("Write a short melody", "Compose eight bars you can hum."),
                ("Arrange a favorite song", "Make it your own with one big change."),
                ("Record a short take", "Play something and keep the recording.")
            ],
            .explorer: [
                ("Play a new genre", "Learn a groove from unfamiliar music."),
                ("Improvise for a while", "Play with no plan and no page."),
                ("Try a new sound", "Experiment with a technique you’ve avoided.")
            ]
        ]),
        "athlete": ("Health", [
            .strategist: [
                ("Plan your training week", "Balance hard days, easy days and rest."),
                ("Set a measurable goal", "Choose a target and test it today."),
                ("Review your recovery", "Check your sleep, food and rest.")
            ],
            .scholar: [
                ("Study your technique", "Watch an expert and note one difference."),
                ("Learn one muscle group", "Find out how it works and trains."),
                ("Read about recovery", "Learn one thing that speeds it up.")
            ],
            .creator: [
                ("Design a workout", "Build your own 30-minute session."),
                ("Film your form", "Record a movement and review it."),
                ("Make a warm-up routine", "Create one you’ll want to repeat.")
            ],
            .explorer: [
                ("Try a new exercise", "Add one movement you’ve never done."),
                ("Train somewhere new", "Take your session to a different place."),
                ("Try another sport’s drill", "See what it teaches you about yours.")
            ]
        ]),
        "teacher": ("Career", [
            .strategist: [
                ("Plan a lesson", "Set one goal and a way to check it."),
                ("Map a unit", "Order five lessons so each builds on the last."),
                ("Design a short quiz", "Write questions that reveal understanding.")
            ],
            .scholar: [
                ("Study a teaching method", "Learn one way to help ideas stick."),
                ("Deepen your subject", "Learn something beyond what you’d teach."),
                ("Read how people learn", "Note one idea you can use.")
            ],
            .creator: [
                ("Make a class activity", "Turn one idea into something hands-on."),
                ("Draw a teaching diagram", "Explain a hard idea with a picture."),
                ("Write a good analogy", "Connect a hard concept to everyday life.")
            ],
            .explorer: [
                ("Explain something to a friend", "See where they get confused."),
                ("Watch another teacher", "Note one thing they do differently."),
                ("Try a new format", "Teach an idea through a game or story.")
            ]
        ]),
        "designer": ("Creative", [
            .strategist: [
                ("Map a user flow", "Plan every step of one simple task."),
                ("Audit a screen", "List what makes it hard to use."),
                ("Set a type scale", "Choose sizes that work together.")
            ],
            .scholar: [
                ("Study a design you love", "Work out why its layout feels right."),
                ("Learn a type principle", "Practice one rule on a real example."),
                ("Read about color contrast", "Check one design against what you learn.")
            ],
            .creator: [
                ("Redesign a small screen", "Improve one app screen you use daily."),
                ("Make a button set", "Design every state of one button."),
                ("Design a poster", "Say one thing with type alone.")
            ],
            .explorer: [
                ("Try an unfamiliar style", "Design in a look you’d never choose."),
                ("Watch someone use an app", "Note where they hesitate."),
                ("Try a new design tool", "Use a feature you’ve never opened.")
            ]
        ]),
        "engineer": ("Development", [
            .strategist: [
                ("Break down a problem", "Split one big task into small parts."),
                ("Weigh two solutions", "List the tradeoffs and choose one."),
                ("Plan a small system", "Draw its parts and how they connect.")
            ],
            .scholar: [
                ("Learn one core concept", "Pick a fundamental you’ve been avoiding."),
                ("Study how something works", "Trace one everyday system end to end."),
                ("Work a practice problem", "Solve one by hand before checking.")
            ],
            .creator: [
                ("Build a small tool", "Make something that saves you a step."),
                ("Improve an old project", "Fix one thing you’ve been meaning to."),
                ("Make a working model", "Test an idea with something real.")
            ],
            .explorer: [
                ("Try a new tool", "Use something unfamiliar for a small job."),
                ("Investigate a failure", "Find out why something broke."),
                ("Explore another field", "See how a different kind of engineer works.")
            ]
        ])
    ]
}

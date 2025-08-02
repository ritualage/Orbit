//
//  ADHDTask.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


// TaskDefinitions.swift
import Foundation

enum ADHDTask: String, CaseIterable, Identifiable {
    case dopamineMenu = "🍭 Dopamine menu builder"
    case taskParalysis = "💥 Task paralysis breaker"
    case hyperfocusHijacker = "🧲 Hyperfocus hijacker"
    case timeBlindness = "⏰ Time blindness fixer"
    case executiveDysfunction = "⚙️ Executive dysfunction "
    case memoryProsthetic = "🗂️ Memory prosthetic system"
    case rsdShield = "🛡️ RSD shield builder"

    var id: String { rawValue }

    // Fields needed per task (ALL CAPS from images)
    struct Field: Identifiable {
        var id: String { key }
        let key: String       // identifier
        let label: String     // UI label
        let placeholder: String
        let isMultiline: Bool
    }
    var fields: [Field] {
        switch self {
        case .dopamineMenu:
            return [
                .init(key: "tasks", label: "Tasks", placeholder: "List tasks you have today...", isMultiline: true)
            ]
        case .taskParalysis:
            return [
                .init(key: "task", label: "Task", placeholder: "What task are you staring at?", isMultiline: false),
                .init(key: "time", label: "Time staring", placeholder: "e.g., 45 minutes", isMultiline: false)
            ]
        case .hyperfocusHijacker:
            return [
                .init(key: "wrongThing", label: "Current hyperfocus (wrong thing)", placeholder: "What are you stuck focusing on?", isMultiline: true),
                .init(key: "importantThing", label: "Important thing", placeholder: "What should you be doing instead?", isMultiline: true)
            ]
        case .timeBlindness:
            return [
                .init(key: "taskList", label: "Task list", placeholder: "List tasks you think take 'a few hours'...", isMultiline: true)
            ]
        case .executiveDysfunction:
            return [
                .init(key: "task", label: "Task", placeholder: "Task you know you should do but can't start", isMultiline: true)
            ]
        case .memoryProsthetic:
            return [
                .init(key: "importantThings", label: "Important things you keep forgetting", placeholder: "Birthdays, bills, medications, etc.", isMultiline: true)
            ]
        case .rsdShield:
            return [
                .init(key: "task", label: "Task you're avoiding", placeholder: "e.g., email boss, publish post", isMultiline: false),
                .init(key: "fears", label: "Fears (rejection, criticism)", placeholder: "What reactions are you scared of?", isMultiline: true)
            ]
        }
    }

    // Prompt template
    func prompt(with values: [String: String]) -> String {
        switch self {
        case .dopamineMenu:
            let tasks = values["tasks", default: ""]
            return """
            I have \(tasks). Create a "dopamine sandwich" schedule where boring tasks are wrapped in rewarding ones. Include specific rewards and short breaks. Present as a time-blocked list.
            """
        case .taskParalysis:
            let task = values["task", default: ""]
            let time = values["time", default: ""]
            return """
            Been staring at \(task) for \(time). Break it into steps so tiny my ADHD brain can't argue. The first step must take under 2 minutes. Include momentum hacks and optional body-doubling ideas.
            """
        case .hyperfocusHijacker:
            let wrong = values["wrongThing", default: ""]
            let important = values["importantThing", default: ""]
            return """
            Currently hyperfocusing on \(wrong) but need to do \(important). Design a bridge activity that redirects this energy without losing momentum. Give 3 graded bridge options and a 30–60 minute execution plan.
            """
        case .timeBlindness:
            let list = values["taskList", default: ""]
            return """
            I think \(list) will take "a few hours." Calculate realistic time including ADHD tax, transitions, and distractions. Then create a visual schedule with buffers and alarms. Mention break timing and contingency.
            """
        case .executiveDysfunction:
            let task = values["task", default: ""]
            return """
            I know I should \(task) but physically can't start. Create a "background process" method to trick my brain into starting without deciding to. Include micro-steps, environmental tweaks, and a 10-minute warm start.
            """
        case .memoryProsthetic:
            let things = values["importantThings", default: ""]
            return """
            I keep forgetting \(things). Design an external memory system that doesn't rely on me remembering to check it. Use push-based cues, placement, automation, and redundancy. Include setup checklist and defaults for iPhone/Mac.
            """
        case .rsdShield:
            let task = values["task", default: ""]
            let fears = values["fears", default: ""]
            return """
            I'm avoiding \(task) because I'm scared of \(fears). Write a self-talk script and protective protocol that reduces rejection sensitivity while doing it. Include pre-brief, during-task prompts, and aftercare.
            """
        }
    }
}

extension ADHDTask {
    var idString: String { String(describing: self) }
    
    
    var emoji: String {
        // rawValue starts with "🍭 Dopamine..." — take the first grapheme
        String(rawValue.split(separator: " ").first ?? "")
    }
    
    var displayTitle: String {
        // remove the leading emoji and space
        let parts = rawValue.split(separator: " ")
        _ = parts.first // emoji
        return parts.dropFirst().joined(separator: " ")
    }
}


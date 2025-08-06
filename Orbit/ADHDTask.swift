//
//  ADHDTask.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


import Foundation

enum ADHDTask: String, CaseIterable, Identifiable {
    case dopamineMenu = "🍭 Dopamine menu builder"
    case taskParalysis = "💥 Task paralysis breaker"
    case hyperfocusHijacker = "🧲 Hyperfocus hijacker"
    case timeBlindness = "⏰ Time blindness fixer"
    case executiveDysfunction = "⚙️ Executive dysfunction "
    case rsdShield = "🛡️ RSD shield builder" // rejection sensitivity dysphoria
    
    var id: String { rawValue }
    
    // Fields needed per task (ALL CAPS from images)
    struct Field: Identifiable {
        var id: String { key }
        let key: String
        let label: String
        let placeholder: String
        let isMultiline: Bool
        var preferredHeight: CGFloat? = nil // new
    }
    
    var fields: [Field] {
        switch self {
        case .dopamineMenu:
            return [
                .init(
                    key: "tasks",
                    label: "Tasks",
                    placeholder: "List tasks you have today...",
                    isMultiline: true,
                    preferredHeight: 150 // about half of what you have now
                )
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
                .init(
                    key: "taskList",
                    label: "Task list",
                    placeholder: "List tasks you think take 'a few hours'...",
                    isMultiline: true,
                    preferredHeight: 150
                )
            ]
        case .executiveDysfunction:
            return [
                .init(
                    key: "task",
                    label: "Task",
                    placeholder: "Task you know you should do but can't start",
                    isMultiline: true,
                    preferredHeight: 150
                )
            ]
        case .rsdShield:
            return [
                .init(
                    key: "task",
                    label: "Task you're avoiding",
                    placeholder: "e.g., email boss, publish post",
                    isMultiline: false
                ),
                .init(
                    key: "fears",
                    label: "Fears (rejection, criticism)",
                    placeholder: "What reactions are you scared of?",
                    isMultiline: true,
                    preferredHeight: 150
                )
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
        String(rawValue.split(separator: " ").first ?? "")
    }
    
    var displayTitle: String {
        let parts = rawValue.split(separator: " ")
        return parts.dropFirst().joined(separator: " ")
    }
    
    var description: String {
        switch self {
        case .dopamineMenu:
            return "Wrap low-dopamine tasks with small rewards and breaks so they actually get done."
        case .taskParalysis:
            return "Turn a scary task into tiny, obvious steps with a 2‑minute starter and momentum boosters."
        case .hyperfocusHijacker:
            return "Redirect current hyperfocus into the important thing using bridge activities."
        case .timeBlindness:
            return "Estimate realistic durations with buffers/alarms and build a visual schedule."
        case .executiveDysfunction:
            return "Sneak past the 'start wall' with micro-steps, environment tweaks, and a warm start."
        case .rsdShield:
            return "Reduce rejection sensitivity while acting with a self-talk script and protective protocol."
        }
    }
    
    // Short note explaining what the right panel does for this task
    var panelHelp: String {
        switch self {
        case .dopamineMenu:
            return "Enter today’s tasks. The panel will generate a time‑blocked plan where boring items are sandwiched between rewards."
        case .taskParalysis:
            return "Enter the task and how long you’ve been staring at it. The panel will break it into tiny first steps and momentum hacks."
        case .hyperfocusHijacker:
            return "Enter what you’re hyperfocused on and what actually matters. The panel creates 3 bridge options and a 30–60 min plan."
        case .timeBlindness:
            return "Paste your task list. The panel adds realistic time + buffers and a schedule with alarms."
        case .executiveDysfunction:
            return "Enter the stuck task. The panel builds a background-process start method with micro-steps and a 10‑minute warm start."
        case .rsdShield:
            return "Enter the avoided task and fears. The panel outputs a self‑talk script, during‑task prompts, and aftercare."
        }
    }
}


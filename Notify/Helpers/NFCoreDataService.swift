//
//  NFCoreDataService.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import CoreData

enum NFCDError: Error {
    case notFound
}

final class NFCoreDataService {
    static let shared = NFCoreDataService()
    private init() { }
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotifyDB")
        container.loadPersistentStores { description, error in
            guard let error = error else { return }
            fatalError("Failed to load the persistent stores from model \"NotifyDB\"")
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension NFCoreDataService {
    func fetchGroups(completionHandler: @escaping (_ result: Result<[NFGroup], Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            let savedGroups = try viewContext.fetch(fetchRequest)
            let groupsToDisplay: [NFGroup] = savedGroups.compactMap { savedGroup in
                guard let id = savedGroup.groupId, let title = savedGroup.title, let date = savedGroup.date else { return nil }
                let items: [NFGroupItem] = (savedGroup.items?.array as? [NFCDGroupItem] ?? []).compactMap({ savedItem in
                    guard let id = savedItem.itemId, let title = savedItem.title else { return nil }
                    return NFGroupItem(id: id, title: title)
                })
                return NFGroup(id: id, title: title, date: date, alerts: savedGroup.alerts, items: items)
            }
            completionHandler(.success(groupsToDisplay))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func fetchGroup(havingId id: String, completionHandler: @escaping (_ result: Result<NFGroup, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), id)
            guard let savedGroup = try viewContext.fetch(fetchRequest).first,
                  let id = savedGroup.groupId, let title = savedGroup.title, let date = savedGroup.date
            else { throw NFCDError.notFound }
            let items: [NFGroupItem] = (savedGroup.items?.array as? [NFCDGroupItem] ?? []).compactMap({ savedItem in
                guard let id = savedItem.itemId, let title = savedItem.title else { return nil }
                return NFGroupItem(id: id, title: title)
            })
            let groupToDisplay = NFGroup(id: id, title: title, date: date, alerts: savedGroup.alerts, items: items)
            completionHandler(.success(groupToDisplay))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func fetchGroup(havingId id: String, completionHandler: @escaping (_ result: Result<NFCDGroup, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), id)
            guard let savedGroup = try viewContext.fetch(fetchRequest).first else { throw NFCDError.notFound }
            completionHandler(.success(savedGroup))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func saveData(completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        do {
            if viewContext.hasChanges {
                try viewContext.save()
                completionHandler(.success(true))
            } else {
                completionHandler(.success(false))
            }
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func createNewGroup() -> NFCDGroup {
        let group = NFCDGroup(context: viewContext)
        group.groupId = UUID().uuidString
        group.title = "Untitled Group"
        group.alerts = false
        group.date = .now
        return group
    }
    func createNewGroupItem() -> NFCDGroupItem {
        let item = NFCDGroupItem(context: viewContext)
        item.itemId = UUID().uuidString
        item.title = ""
        return item
    }
    func insertGroup(_ group: NFGroup, completionHandler: @escaping (_ result: Result<NFGroup, Error>) -> Void) {
        do {
            viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let newGroup = NFCDGroup(context: viewContext)
            newGroup.groupId = group.id
            newGroup.title = group.title
            newGroup.date = group.date
            newGroup.alerts = group.alerts
            for item in group.items {
                let newItem = NFCDGroupItem(context: viewContext)
                newItem.itemId = item.id
                newItem.title = item.title
                newGroup.addToItems(newItem)
            }
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(group))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func insertGroupItem(_ item: NFGroupItem, inGroupHavingId groupId: String, completionHandler: @escaping (_ result: Result<NFGroupItem, Error>) -> Void) {
        do {
            viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), groupId)
            guard let savedGroup = try viewContext.fetch(fetchRequest).first else { throw NFCDError.notFound }
            let newItem = NFCDGroupItem(context: viewContext)
            newItem.itemId = item.id
            newItem.title = item.title
            savedGroup.addToItems(newItem)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(item))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func deleteGroup(_ group: NFGroup, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroup.groupId), group.id)
            guard let groupToDelete = try viewContext.fetch(fetchRequest).first else {
                throw NFCDError.notFound
            }
            viewContext.delete(groupToDelete)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(true))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    func deleteGroupItem(_ item: NFGroupItem, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        do {
            let fetchRequest = NFCDGroupItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NFCDGroupItem.itemId), item.id)
            guard let itemToDelete = try viewContext.fetch(fetchRequest).first else {
                throw NFCDError.notFound
            }
            viewContext.delete(itemToDelete)
            if viewContext.hasChanges {
                try viewContext.save()
            }
            completionHandler(.success(true))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
}


// MARK: - AtomicHabits
extension NFCoreDataService {
    func saveAtomicHabits(completionHandler: @escaping (_ result: Result<NFGroup, Error>) -> Void) {
        let atomicHabits = NFGroup(id: "14B8239B-394F-4BCD-ADD3-22CF9933C15E", title: "Atomic Habits", date: .now, alerts: true, items: [
            NFGroupItem(id: "8F66B564-ED25-49E8-BF27-A5DCBB9E67E6", title: "Habits are the compound interest of self-improvement. Getting 1 percent better everyday counts for a lot in the long-run."),
            NFGroupItem(id: "67849067-F8BB-4F22-94FF-D94BED780841", title: "Habits are a double-edged sword. They can work for you or against you, which is why understanding the details is essential."),
            NFGroupItem(id: "75B45699-9CEF-4850-88E3-FAF6C291EB85", title: "Small changes often appear to make no difference until you cross a critical threshold. The most powerful outcomes of any compounding process are delayed. You need to be patient."),
            NFGroupItem(id: "AEE9DF34-3462-42BA-BE30-F77EB72C5B0B", title: "You do not rise to the level of your goals. You fall to the level of your systems."),
            NFGroupItem(id: "4B7ACA57-54F4-48EA-A6AF-8B3EAEA4E2BB", title: "There are three levels of change: outcome change, process change, and identity change."),
            NFGroupItem(id: "6C53FEC7-A5FC-4E25-846B-C8F20AE2C35A", title: "The most effective way to change your habits is to focus not on what you want to achieve, but on who you wish to become."),
            NFGroupItem(id: "8D7874AF-264B-42E9-A56F-63F933FB342F", title: "Your identity emerges out of your habits. Every action is a vote for the type of person you wish to become."),
            NFGroupItem(id: "80998F21-E88E-4057-9EE2-47C83F44F74B", title: "Becoming the best version of yourself requires you to continuously edit your beliefs, and to upgrade and expand your identity."),
            NFGroupItem(id: "59303B84-AA48-4507-AC94-F455C6A8DAA5", title: "Any habit can be broken down into a feedback loop that involves four steps: cue, cravings, response, and reward."),
            NFGroupItem(id: "EC9E1F0B-72E1-4A37-B4A5-9B786613F4C5", title: "The fours laws of Behaviour Change are: make it obvious, make it attractive, make it easy, and make it satisfying."),
            NFGroupItem(id: "165D74FE-D2E5-41C0-9AA9-4223C4DC707A", title: "Until you make the unconscious conscious, it will direct your life and you will call it fate."),
            NFGroupItem(id: "704FC5A3-5BF2-415B-ADE1-A8B0BC374CE4", title: "Once our habits become automatic, we stop paying attentions to what we are doing."),
            NFGroupItem(id: "FE22D260-017C-41EB-BDD4-DC917AAE5D52", title: "The process of behaviour change always starts with awareness. You need to be aware of your habits before you can change them."),
            NFGroupItem(id: "FBE11B7E-3816-4653-838E-3DE4CBDCF1D1", title: "Pointing-and-Calling raises your level of awareness from a unconscious habit to a more conscious level by verbalising your actions."),
            NFGroupItem(id: "1E5ECA48-D47F-4843-AB8C-6FD46098030D", title: "The Diderot Effect states that obtaining a new possession often creates a spiral of consumption that leads to additional purchases."),
            NFGroupItem(id: "830DBDA2-6C0C-4167-B61D-6E6F0B3740AE", title: "No behaviour happens in isolation. Each action becomes a cure that triggers the next behaviour."),
            NFGroupItem(id: "1D5D3DB9-D0F5-49C7-BFB4-6B4C91371C00", title: "Creating an implementation intention is a strategy you can use to pair a new habit with a specific time and location."),
            NFGroupItem(id: "BEA46185-0F58-4768-9042-5FCA7B4EF662", title: "Habit Stacking is a strategy you can use to pair a new habit with a current habit."),
            NFGroupItem(id: "D8300555-1D75-4CE4-B391-3F60EE36E5A4", title: "A stable environment where everything has a place and a purpose is an environment where habits can easily form."),
            NFGroupItem(id: "42CDC94C-E456-4712-B73B-909E8E449FDE", title: "Small changes in context can lead to large changes in behaviour over time."),
            NFGroupItem(id: "78FBCCF4-CA2B-49AC-8BED-2238527979C3", title: "Gradually, your habits become associated not with a single trigger but with the entire context surrounding the behaviour. The context becomes the cue."),
            NFGroupItem(id: "1CC5ED24-711F-42F5-B81B-FAE7308A6372", title: "The inversion of the 1st Law of Behaviour Change is “make it invisible”."),
            NFGroupItem(id: "7B193971-0853-456B-AAD0-8C048715726B", title: "Once a habit is formed, it is unlikely to be forgotten."),
            NFGroupItem(id: "B867E86F-FB47-43B9-BC50-21E9A238974D", title: "Self-control is a short-term strategy, not a long-term one."),
            NFGroupItem(id: "42BCFDC8-6B11-446A-BCE6-0A31BF057EEF", title: "People with high self-control tend to spend less time in tempting situations. It’s easier to avoid temptation than resist it."),
            NFGroupItem(id: "514247FD-EC2F-4233-8FEA-5F6F3F735332", title: "One of the most practical ways to eliminate a bad habit is to reduce to the cue that causes it."),
            NFGroupItem(id: "C53DCA8F-EA3E-464B-A93E-055335DCBB41", title: "The more attractive an opportunity is, the more likely it is to become habit-forming."),
            NFGroupItem(id: "2A614B73-2290-4CCE-9F4E-470D58118AF3", title: "Habits are a dopamine-driven feedback loop. When dopamine rises, so does our motivation to act."),
            NFGroupItem(id: "BC3A9F9D-9E56-43EA-B620-96583B179C5E", title: "It is the anticipation of a reward - not the fulfilment of it - that gets us to take action. The greater the anticipation, the greater the dopamine strike."),
            NFGroupItem(id: "4C640504-F573-43BC-B399-EDDCCCF4C877", title: "Temptation bundling is one way to make your habits more attractive. The strategy is to pair an action you want to do with an action you need to do."),
            NFGroupItem(id: "8CE86503-42C5-4A14-9CA8-41CC3C45F6B3", title: "We tend to imitate the habits of three social groups: the close (family and friends), the many (the tribe), and the powerful (those with status and prestige)."),
            NFGroupItem(id: "884B5990-83F1-4971-AA39-F94A2072FE53", title: "One of the most effective things you can do to build better habits is to join a culture where (1) your desired behaviour is the normal behaviour and (2) you already have something in common with the group."),
            NFGroupItem(id: "12749C80-30AF-4E75-B773-C7205DAB0004", title: "The inversion of the 2nd Law of Behaviour Change is “make it unattractive”."),
            NFGroupItem(id: "4CEBFF3F-2EF4-4E56-AD4E-D5230083ECA4", title: " Every behaviour has a surface level craving and a deeper underlying motive."),
            NFGroupItem(id: "549A6F87-A3D3-4462-A6A4-B2F3D1B177E1", title: "The cause of your habits is actually the prediction that precedes them. The prediction leads to a feeling."),
            NFGroupItem(id: "425BB257-E158-4FED-84D3-05A3FD5ED872", title: "Habits are attractive when we associate them with positive feelings and unattractive when we associate them with negative feelings."),
            NFGroupItem(id: "456D6BAC-493A-489B-B722-95D026FA9780", title: "The most effective form of learning is practice, not planning."),
            NFGroupItem(id: "B3FD340C-7640-457A-B950-64332078121D", title: "Focus on taking action, not being in motion."),
            NFGroupItem(id: "47E5257C-C4D1-4A59-917C-D2C8A36E551A", title: "Habit formation is the process by which a behaviour becomes progressively more automatic through repetition."),
            NFGroupItem(id: "200D0518-D13C-4A12-94BE-AEAED07C27F5", title: "The amount of time you have been performing a habit is not as important as the number of times you have performed it."),
            NFGroupItem(id: "A8E9C9FE-5384-4091-93A2-7845B972AB80", title: "Walk Slowly, but Never Backward."),
            NFGroupItem(id: "0D6EDF0D-8C78-4088-B6D0-18081004A2B1", title: "Human behaviour follows the Law of Least Effort. We will naturally gravitate toward the option that requires the least amount of work."),
            NFGroupItem(id: "A638FAEE-27DB-4FDE-A80D-93C878534825", title: "Create an environment where doing the right thing is as easy as possible."),
            NFGroupItem(id: "85E2630D-C3A7-40CB-97FB-F62B0F4061C9", title: "Reduce the friction associated with good behaviours. When friction is low, habits are easy."),
            NFGroupItem(id: "69608DA3-FE13-4C50-B53C-DFAFEE1C8964", title: "Increase the friction associated with bad behaviours. When friction is high, habits are difficult."),
            NFGroupItem(id: "53301E30-EB73-44B2-A05D-147AD5681691", title: "Prime your environment to make future actions easier."),
            NFGroupItem(id: "2688AC52-1334-4969-A0C6-FB1D54D390FF", title: "Habits can be completed in a few seconds but continue to impact your behaviour for minutes or hours afterward."),
            NFGroupItem(id: "1F0F014D-E5BC-4EB1-AB70-9D18ABBDA32C", title: "Many habits occur at decisive moments - choices that are like a fork in the road - and either send you in the direction of a productive day or an unproductive one."),
            NFGroupItem(id: "34F30F8F-75CB-47FE-8121-E64BF7F0113D", title: "The Two-Minute Rule states, “When you start a new habit, it should take less than two minutes to do”."),
            NFGroupItem(id: "8114DE0D-6968-477B-98CD-FDB286B8A003", title: "The more you ritualise the beginning of a process, the more likely it becomes that you can slip into the state of deep focus that is required to do great things."),
            NFGroupItem(id: "806F09D7-594E-456D-A672-8AE2372A9308", title: "Standardise before you optimise. You can’t improve a habit that doesn’t exist."),
            NFGroupItem(id: "576C9F73-B9DF-40EB-BF72-896499B8CBCF", title: "The inversion of the 3rd Law of Behaviour Change is “make it difficult”."),
            NFGroupItem(id: "591797C0-E8A3-49AC-AC1A-8F7A1B7036F9", title: "A commitment device is a choice you make in the present that locks in better behaviour in the future."),
            NFGroupItem(id: "308FB3A1-0140-4B54-A225-FE7360DD5723", title: "We are more likely to repeat a behaviour when the experience is satisfying."),
            NFGroupItem(id: "16744BE0-907B-4BFB-80E1-21C1A1AF8C0A", title: "The human brain evolved to prioritise immediate rewards over delayed rewards."),
            NFGroupItem(id: "382C9157-C7C0-4818-833E-0CAC0C3A1BDB", title: "The Cardinal Rule of Behaviour Change: What is immediately rewarded is repeated. What is immediately punished is avoided."),
            NFGroupItem(id: "B39E24F6-BD48-4590-BFCC-BA6242C95CAD", title: "To get a habit to stick you need to feel immediately successful - even if it’s in a small way."),
            NFGroupItem(id: "45E4CD04-FD08-422B-9D47-D61670FB6F2A", title: "The first mistake is never the one that ruins you. It is the spiral of repeated mistakes that follows. Missing once is an accident. Missing twice is the start of a new habit."),
            NFGroupItem(id: "76645680-7E28-4A8F-A0C1-59E1A4C3B044", title: "One of the most satisfying feelings is the feeling of making progress."),
            NFGroupItem(id: "96B0DE2B-3282-4018-B6EC-6E2DB8D7569C", title: "A Habit Tracker is a simple way to measure whether you did a habit - like marking an X on a calendar."),
            NFGroupItem(id: "5C0CEAD9-1E91-496E-8021-72187E72E599", title: "Habit Trackers and other visual forms of measurement can make your habits satisfying by providing clear evidence of your progress."),
            NFGroupItem(id: "FFC47171-3592-44FD-BC9C-288D4F3983B2", title: "Don’t break the chain. Try to keep your habit streak alive."),
            NFGroupItem(id: "B5BBFF4A-6C9E-46E9-B642-FB332077A8C4", title: "Just because you can measure something doesn’t mean it’s the most important thing."),
            NFGroupItem(id: "DC4EC4F5-B23A-4B94-A3FC-934F8B791191", title: "The inversion of the 4th Law of Behaviour Change is “make it unsatisfying”."),
            NFGroupItem(id: "059B40E8-49D1-47B0-AA42-0ED43CF457A3", title: "We are less likely to repeat a bad habit if it is painful or unsatisfying."),
            NFGroupItem(id: "346187C1-32DA-4E97-9AB6-3A52A8F9CBF2", title: "An accountability partner can create an immediate cost to inaction. We care deeply about what others think of us, and we do not want others to have a lesser opinion of us."),
            NFGroupItem(id: "2A8022FD-00DD-4490-BE53-BCB3A2C36ABB", title: "A habit contract can be used to add a social cost to any behaviour. It makes the costs of violating your promises public and painful."),
            NFGroupItem(id: "4BA7832A-B5F7-466F-A2C5-CB0448BD5040", title: "Knowing that someone else is watching you can be a powerful motivator."),
            NFGroupItem(id: "395C267C-58AE-420D-BB8B-F5959F4D8DE2", title: "The secret to maximising your odds of success is to choose the right field of competition."),
            NFGroupItem(id: "42C9E1B6-AD1D-4203-A2D8-E100DEE24FEF", title: "Habits are easier when they align with your natural abilities. Choose the habits that best suit you."),
            NFGroupItem(id: "3F53A53C-B89A-4717-AE0D-B0A45CA471D8", title: "Play a game that favours your strengths. If you can’t find a game that favours you, create one."),
            NFGroupItem(id: "D5F1CDE9-4458-42F8-B9F6-CF4DA090E732", title: "The Goldilocks Rule states that humans experience peak motivation when working on tasks that are right on the edge of their current abilities. Not too hard. Not too easy. Just right."),
            NFGroupItem(id: "E4DA8020-7A2C-4C55-946F-6E4F33A248F5", title: "The greatest threat to success is not failure but boredom."),
            NFGroupItem(id: "088ABC29-216D-462C-895F-16F76753043E", title: "As habits become routine, they become less interesting and less satisfying. We get bored."),
            NFGroupItem(id: "B65DD655-E5C2-4735-85B7-E7D42C8B1129", title: "Anyone can work hard when they feel motivated. It’s the ability to keep going when work isn’t exciting that makes the difference."),
            NFGroupItem(id: "96BB17E0-0193-40C8-BC36-A35A9B23DD2A", title: "Professionals stick to the schedule; amateurs let life get in the way."),
            NFGroupItem(id: "6BD77E01-81E3-4002-85E8-7AECA41A761C", title: "A lack of self-awareness is poison. Reflection and review is the antidote."),
            NFGroupItem(id: "99F089FC-9F03-43AC-A1E1-36103E64288C", title: "The tighter we cling to an identity, the harder it becomes to grow beyond it.")
        ])
        insertGroup(atomicHabits, completionHandler: completionHandler)
    }
}

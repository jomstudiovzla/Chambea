import Foundation
import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleAlertNotification(alert: JobAlert, matchingJobsCount: Int) async throws
    func cancelNotifications(for alertId: UUID) async
}

final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleAlertNotification(alert: JobAlert, matchingJobsCount: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.alert.title")
        content.body = String(localized: "notification.alert.body \(matchingJobsCount) \(alert.name)")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelNotifications(for alertId: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [alertId.uuidString])
    }
}
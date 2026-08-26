//
//  NotificationManager.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 26/08/26.
//

import UserNotifications
import SwiftUI

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func permissionRequest() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Erro ao solicitar permissão: \(error.localizedDescription)")
            return false
        }
    }
    

    func scheduleIfNeededToday(
        identificador: String,
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        jaUtilizouHoje: Bool
    ) {
        guard jaUtilizouHoje == false else { return }

        let now = Date()
        guard let triggerDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identificador, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Erro ao agendar: \(error.localizedDescription)")
            } else {
                print("Notificação de hoje agendada para \(hour):\(minute)")
            }
        }
    }

    func notificationSet(jaUtilizouHoje: Bool) {
        let dateSuffix = Date().formatted(.dateTime.year().month().day())

        scheduleIfNeededToday(
            identificador: "notificacao-manha-\(dateSuffix)",
            hour: 8,
            minute: 0,
            title: "Bom dia!",
            body: "Você ganhou uma obra diária. Venha conferir!.",
            jaUtilizouHoje: jaUtilizouHoje
        )

        scheduleIfNeededToday(
            identificador: "notificacao-tarde-\(dateSuffix)",
            hour: 14,
            minute: 0,
            title: "Nova arte disponível!",
            body: "Não se esqueça de conferir a sua obra diária, e realizar uma reflexão.",
            jaUtilizouHoje: jaUtilizouHoje
        )

        scheduleIfNeededToday(
            identificador: "notificacao-noite-\(dateSuffix)",
            hour: 19,
            minute: 0,
            title: "Boa noite!",
            body: "Você ainda não abriu sua obra diária hoje. Não perca a chance de realizar uma reflexão.",
            jaUtilizouHoje: jaUtilizouHoje
        )
    }
}

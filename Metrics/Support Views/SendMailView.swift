//
//  SendMailView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/8/22.
//

import Foundation
import SwiftUI
import MessageUI

/// A SwiftUI view for sending an email via the system Mail interface.
struct MailSenderView: UIViewControllerRepresentable {
    
    // MARK: View Controller Variables
    var recipients: [String]
    var subject: String
    var body: String
    
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        // MARK: Mail Sender Settings
        let mailSenderViewController = MFMailComposeViewController()
        mailSenderViewController.mailComposeDelegate = context.coordinator
        
        mailSenderViewController.setToRecipients(recipients)
        mailSenderViewController.setSubject(subject)
        mailSenderViewController.setMessageBody(body, isHTML: false)
        
        return mailSenderViewController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailSenderView
        
        init(_ mailSenderViewController: MailSenderView) {
            self.parent = mailSenderViewController
        }
        
        // MARK: Mail Sender Delegate Functions
        func mailComposeController(_ mailSenderViewController: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            mailSenderViewController.dismiss(animated: true)
        }
    }
    
}

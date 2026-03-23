import Foundation
import AppKit
import Combine

class CLIInstaller: ObservableObject {
    static let shared = CLIInstaller()
    
    private let installPath = "/usr/local/bin/semafor"
    private let cliScriptName = "semafor"
    
    @Published var isInstalled: Bool = false
    
    private init() {
        refreshInstallationStatus()
    }
    
    func refreshInstallationStatus() {
        isInstalled = FileManager.default.fileExists(atPath: installPath)
    }
    
    func checkAndPromptInstallation() {
        // Check if already installed
        if isInstalled {
            print("✅ CLI tool already installed at \(installPath)")
            return
        }
        
        // Show installation prompt
        DispatchQueue.main.async {
            self.showInstallPrompt()
        }
    }
    
    private func showInstallPrompt() {
        let alert = NSAlert()
        alert.messageText = "Install Semafor CLI Tool?"
        alert.informativeText = """
        To use Semafor from the command line, we need to install the 'semafor' command.
        
        This will allow you to run commands like:
        • semafor red "reason"
        • semafor green
        • semafor status
        
        Installation requires administrator privileges.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Not Now")
        alert.addButton(withTitle: "Copy Manual Instructions")
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:
            // Install
            installCLI()
        case .alertThirdButtonReturn:
            // Copy manual instructions
            copyManualInstructions()
        default:
            // Not now
            break
        }
    }
    
    func installCLI() {
        guard let cliSource = Bundle.main.path(forResource: cliScriptName, ofType: nil) else {
            showError("CLI script not found in app bundle")
            return
        }
        
        // Create AppleScript to run installation with sudo
        let script = """
        do shell script "mkdir -p /usr/local/bin && cp '\(cliSource)' '\(installPath)' && chmod +x '\(installPath)'" with administrator privileges
        """
        
        // Create NSAppleScript on main thread to avoid FSFindFolder errors
        guard let scriptObject = NSAppleScript(source: script) else {
            showError("Failed to create install script")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            
            DispatchQueue.main.async {
                if let error = error {
                    // Check if user cancelled (error -128)
                    if let errorNumber = error[NSAppleScript.errorNumber] as? Int {
                        if errorNumber == -128 {
                            // User cancelled, do nothing
                            return
                        }
                    }
                    self.showError("Installation failed: \(error)")
                } else {
                    self.refreshInstallationStatus()
                    self.showSuccess()
                }
            }
        }
    }
    
    private func showSuccess() {
        let alert = NSAlert()
        alert.messageText = "Installation Successful! 🚦"
        alert.informativeText = """
        The 'semafor' command is now available.
        
        Open Terminal and try:
        semafor red "Test notification"
        
        See Settings → Help for all available commands.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Installation Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func copyManualInstructions() {
        guard let cliSource = Bundle.main.path(forResource: cliScriptName, ofType: nil) else {
            return
        }
        
        let instructions = """
        # Manual Installation Instructions for Semafor CLI
        
        # 1. Copy the CLI script to /usr/local/bin
        sudo cp "\(cliSource)" /usr/local/bin/semafor
        
        # 2. Make it executable
        sudo chmod +x /usr/local/bin/semafor
        
        # 3. Verify installation
        which semafor
        
        # 4. Test it
        semafor status
        """
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        
        let alert = NSAlert()
        alert.messageText = "Instructions Copied!"
        alert.informativeText = "Manual installation instructions have been copied to your clipboard. Paste them into Terminal."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func uninstall() {
        let script = """
        do shell script "rm -f '\(installPath)'" with administrator privileges
        """
        
        // Create NSAppleScript on main thread to avoid FSFindFolder errors
        guard let scriptObject = NSAppleScript(source: script) else {
            showError("Failed to create uninstall script")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            
            DispatchQueue.main.async {
                if let error = error {
                    // Check if user cancelled (error -128)
                    if let errorNumber = error[NSAppleScript.errorNumber] as? Int {
                        if errorNumber == -128 {
                            // User cancelled, do nothing
                            return
                        }
                    }
                    self.showError("Uninstallation failed: \(error)")
                } else {
                    self.refreshInstallationStatus()
                    let alert = NSAlert()
                    alert.messageText = "Uninstalled"
                    alert.informativeText = "The 'semafor' CLI tool has been removed."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }
}

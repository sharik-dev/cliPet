import AppKit
import Sparkle

// MARK: - Shared state

enum PixelUpdatePhase {
    case checking
    case found(item: SUAppcastItem, state: SPUUserUpdateState, reply: (SPUUserUpdateChoice) -> Void)
    case notFound
    case downloading(total: UInt64, received: UInt64)
    case extracting(progress: Double)
    case readyToInstall(reply: (SPUUserUpdateChoice) -> Void)
    case installing
    case done
    case error(String)
}

@MainActor
final class PixelUpdateState: ObservableObject {
    @Published var phase: PixelUpdatePhase = .checking
    @Published var tick: Int = 0
    private var timer: Timer?

    func startTick() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick += 1 }
        }
    }

    func stopTick() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Custom Sparkle user driver

final class PixelUpdateDriver: NSObject, SPUUserDriver {

    let state = PixelUpdateState()
    private var windowController: PixelUpdateWindowController?

    // MARK: Permission

    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        reply(SUUpdatePermissionResponse(automaticUpdateChecks: true, sendSystemProfile: false))
    }

    // MARK: Checking

    func showUserInitiatedUpdateCheck(cancellation: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .checking
            self.showWindow()
        }
    }

    // MARK: Update found ⭐

    func showUpdateFound(with item: SUAppcastItem, state: SPUUserUpdateState,
                         reply: @escaping (SPUUserUpdateChoice) -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .found(item: item, state: state, reply: reply)
            self.showWindow()
        }
    }

    // MARK: Release notes

    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {}
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {}

    // MARK: No update

    func showUpdateNotFoundWithError(_ error: Error, acknowledgement: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .notFound
            self.showWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                acknowledgement()
                self.dismissUpdateInstallation()
            }
        }
    }

    // MARK: Error

    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .error(error.localizedDescription)
            self.showWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                acknowledgement()
                self.dismissUpdateInstallation()
            }
        }
    }

    // MARK: Download progress

    func showDownloadInitiated(cancellation: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .downloading(total: 0, received: 0)
        }
    }

    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        DispatchQueue.main.async {
            if case .downloading(_, let received) = self.state.phase {
                self.state.phase = .downloading(total: expectedContentLength, received: received)
            } else {
                self.state.phase = .downloading(total: expectedContentLength, received: 0)
            }
        }
    }

    func showDownloadDidReceiveData(ofLength length: UInt64) {
        DispatchQueue.main.async {
            if case .downloading(let total, let received) = self.state.phase {
                self.state.phase = .downloading(total: total, received: received + length)
            }
        }
    }

    // MARK: Extraction

    func showDownloadDidStartExtractingUpdate() {
        DispatchQueue.main.async { self.state.phase = .extracting(progress: 0) }
    }

    func showExtractionReceivedProgress(_ progress: Double) {
        DispatchQueue.main.async { self.state.phase = .extracting(progress: progress) }
    }

    // MARK: Ready to install

    func showReady(toInstallAndRelaunch reply: @escaping (SPUUserUpdateChoice) -> Void) {
        DispatchQueue.main.async { self.state.phase = .readyToInstall(reply: reply) }
    }

    // MARK: Installing

    func showInstallingUpdate(withApplicationTerminated applicationTerminated: Bool,
                               retryTerminatingApplication: @escaping () -> Void) {
        DispatchQueue.main.async { self.state.phase = .installing }
    }

    // MARK: Done

    func showUpdateInstalledAndRelaunched(_ relaunched: Bool,
                                          acknowledgement: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.state.phase = .done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                acknowledgement()
                self.dismissUpdateInstallation()
            }
        }
    }

    // MARK: Dismiss

    func dismissUpdateInstallation() {
        DispatchQueue.main.async {
            self.windowController?.close()
            self.windowController = nil
            self.state.stopTick()
        }
    }

    // MARK: Focus (optional)

    func showUpdateInFocus() {
        DispatchQueue.main.async {
            self.windowController?.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: Private

    private func showWindow() {
        if windowController == nil {
            windowController = PixelUpdateWindowController(state: state)
            state.startTick()
        }
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

import Cocoa
import AVFoundation
import CoreGraphics

final class WallpaperApp: NSObject, NSApplicationDelegate {
    private var windows: [NSWindow] = []
    private var players: [AVQueuePlayer] = []
    private var loopers: [AVPlayerLooper] = []
    private var statusItem: NSStatusItem!
    private var paused = false
    private var currentURL: URL?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🏏"
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Choose Video…", action: #selector(chooseVideo), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Pause / Resume", action: #selector(togglePause), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Wallpaper", action: #selector(quit), keyEquivalent: "q"))
        for item in menu.items { item.target = self }
        statusItem.menu = menu
        NotificationCenter.default.addObserver(self, selector: #selector(rebuild), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        let bundled = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4")
        let saved = UserDefaults.standard.string(forKey: "wallpaperPath").map { URL(fileURLWithPath: $0) }
        if let url = saved, FileManager.default.fileExists(atPath: url.path) { currentURL = url }
        else { currentURL = bundled }
        rebuild()
    }

    @objc private func rebuild() {
        for player in players { player.pause() }
        for window in windows { window.orderOut(nil); window.close() }
        windows.removeAll(); players.removeAll(); loopers.removeAll()
        guard let url = currentURL else { return }
        for screen in NSScreen.screens {
            let window = NSWindow(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
            window.isOpaque = true
            window.backgroundColor = .black
            window.ignoresMouseEvents = true
            window.hasShadow = false
            let player = AVQueuePlayer()
            player.isMuted = true
            let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
            view.wantsLayer = true
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            view.layer = layer
            window.contentView = view
            window.orderBack(nil)
            if !paused { player.play() }
            windows.append(window); players.append(player); loopers.append(looper)
        }
    }

    @objc private func chooseVideo() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp4", "mov", "m4v"]
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            currentURL = url
            UserDefaults.standard.set(url.path, forKey: "wallpaperPath")
            rebuild()
        }
    }
    @objc private func togglePause() {
        paused.toggle()
        for player in players { paused ? player.pause() : player.play() }
    }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = WallpaperApp()
app.delegate = delegate
app.run()

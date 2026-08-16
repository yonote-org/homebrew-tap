cask "adb-fs-tc-plugin" do
  arch arm: "arm64", intel: "x86_64"

  version "1.1.0"
  sha256 arm:   "6fcef0cf25332df48f030a0c39b73ff8b34f5f4596d53029168a4483e1389486",
         intel: "c3ac5267e1cc337926cb993d56e34e875166c5fe6aa1523bd46adca04c9d3667"

  url "https://github.com/yonote-org/adb-fs-tc-plugin/releases/download/v#{version}/adb-fs-tc-plugin-#{version}-macos-#{arch}.zip"
  name "ADB Filesystem DoubleCommander plugin"
  desc "ADB filesystem (WFX) plugin for Double Commander"
  homepage "https://github.com/yonote-org/adb-fs-tc-plugin"

  livecheck do
    url "https://github.com/yonote-org/adb-fs-tc-plugin"
    strategy :github_latest
  end

  artifact "adb-fs-tc-plugin.wfx",
           target: "#{HOMEBREW_PREFIX}/share/adb-fs-tc-plugin/adb-fs-tc-plugin.wfx"
  artifact "LICENCE",
           target: "#{HOMEBREW_PREFIX}/share/adb-fs-tc-plugin/LICENCE"

  # Registers the plugin in Double Commander's config. Runs unsandboxed on
  # every install/upgrade; re-runnable with `brew reinstall --cask`.
  # DC saves its config on quit, so when it is running it is asked to quit
  # (gracefully, via AppleScript - equivalent to Cmd+Q) before the edit and
  # relaunched afterwards. If it will not quit (unsaved editor prompt, denied
  # automation permission), the edit is skipped with instructions.
  postflight do
    require "fileutils"
    dc_running = proc { system("/usr/bin/pgrep", "-q", "-x", "doublecmd") }
    config = File.join(Dir.home, "Library/Preferences/doublecmd/doublecmd.xml")
    wfx = "#{HOMEBREW_PREFIX}/share/adb-fs-tc-plugin/adb-fs-tc-plugin.wfx"
    # matches this cask's older names too, so upgrades repoint cleanly
    any_wfx = %r{<Path>[^<]*(?:adbfsplugin|adb-fs-tc-plugin)\.wfx</Path>}
    if !File.exist?(config)
      puts "Double Commander has no config yet. Start it once, quit it, then run:"
      puts "  brew reinstall --cask adb-fs-tc-plugin"
    elsif File.read(config).include?(wfx)
      puts "Plugin already registered in Double Commander."
    else
      was_running = dc_running.call
      if was_running
        puts "Quitting Double Commander to update its plugin registration..."
        system("/usr/bin/osascript", "-e", 'tell application id "com.company.doublecmd" to quit')
        30.times do
          break unless dc_running.call
          sleep 0.5
        end
      end
      if dc_running.call
        puts "Double Commander did not quit - registration was skipped."
        puts "Quit it, then run: brew reinstall --cask adb-fs-tc-plugin"
      else
        content = File.read(config)
        entry = "<WfxPlugin Enabled=\"True\">\n" \
                "        <Name>Android</Name>\n" \
                "        <Path>#{wfx}</Path>\n" \
                "      </WfxPlugin>"
        updated =
          if content =~ any_wfx
            # an older registration exists - repoint it at this install
            content.sub(any_wfx, "<Path>#{wfx}</Path>")
          elsif content.include?("</WfxPlugins>")
            content.sub("</WfxPlugins>", "  #{entry}\n    </WfxPlugins>")
          elsif content.include?("<WfxPlugins/>")
            content.sub("<WfxPlugins/>", "<WfxPlugins>\n      #{entry}\n    </WfxPlugins>")
          end
        if updated.nil? || updated == content
          puts "Could not update #{config} - register the plugin manually (see caveats)."
        else
          FileUtils.cp(config, "#{config}.bak")
          File.write(config, updated)
          puts "Registered the plugin in Double Commander (backup: doublecmd.xml.bak)."
        end
        if was_running
          system("/usr/bin/open", "-b", "com.company.doublecmd")
          puts "Double Commander restarted."
        else
          puts "Start Double Commander and enter the Android entry in the drive list."
        end
      end
    end
  end

  # Deregisters the plugin from Double Commander's config on uninstall,
  # with the same quit-edit-relaunch dance as postflight.
  uninstall_postflight do
    require "fileutils"
    dc_running = proc { system("/usr/bin/pgrep", "-q", "-x", "doublecmd") }
    config = File.join(Dir.home, "Library/Preferences/doublecmd/doublecmd.xml")
    wfx = "#{HOMEBREW_PREFIX}/share/adb-fs-tc-plugin/adb-fs-tc-plugin.wfx"
    if File.exist?(config) && File.read(config).include?(wfx)
      was_running = dc_running.call
      if was_running
        puts "Quitting Double Commander to remove its plugin registration..."
        system("/usr/bin/osascript", "-e", 'tell application id "com.company.doublecmd" to quit')
        30.times do
          break unless dc_running.call
          sleep 0.5
        end
      end
      if dc_running.call
        puts "Double Commander did not quit - its plugin registration was left in place."
        puts "Remove it via Configuration -> Options... -> Plugins -> File System Plugins (WFX)."
      else
        content = File.read(config)
        updated = content.sub(
          %r{\s*<WfxPlugin[^>]*>\s*<Name>[^<]*</Name>\s*<Path>#{Regexp.escape(wfx)}</Path>\s*</WfxPlugin>},
          "",
        )
        if updated != content
          FileUtils.cp(config, "#{config}.bak")
          File.write(config, updated)
          puts "Removed the plugin registration from Double Commander (backup: doublecmd.xml.bak)."
        end
        if was_running
          system("/usr/bin/open", "-b", "com.company.doublecmd")
          puts "Double Commander restarted."
        end
      end
    end
  end

  caveats <<~EOS
    The plugin registers itself in Double Commander automatically. If Double
    Commander is running it is quit gracefully first (macOS may ask you to
    allow controlling it - a one-time permission) and restarted afterwards;
    then enter the Android entry in the drive list (Alt+F1 / Alt+F2).
    If registration was skipped, run:
      brew reinstall --cask adb-fs-tc-plugin
    Manual alternative in Double Commander:
      Configuration -> Options... -> Plugins -> File System Plugins (WFX)
      -> Add -> #{HOMEBREW_PREFIX}/share/adb-fs-tc-plugin/adb-fs-tc-plugin.wfx
  EOS
end

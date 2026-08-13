cask "adb-filesystem-doublecommander-plugin" do
  arch arm: "arm64", intel: "x86_64"

  version "1.0.5"
  sha256 arm:   "eb80f19caa867653e9dfcdc74ac74ed9f2d357628d4b008ac55e64b0e9974bb9",
         intel: "e2b677b398ae91478b1de370c748090fccc5a4a0cc21f4e4592555aec9d23ae2"

  url "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin/releases/download/v#{version}/adbfsplugin-#{version}-macos-#{arch}.zip"
  name "ADB Filesystem DoubleCommander plugin"
  desc "ADB filesystem (WFX) plugin for Double Commander"
  homepage "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin"

  livecheck do
    url "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin"
    strategy :github_latest
  end

  artifact "adbfsplugin.wfx",
           target: "#{HOMEBREW_PREFIX}/share/adb-filesystem-doublecommander-plugin/adbfsplugin.wfx"
  artifact "LICENCE",
           target: "#{HOMEBREW_PREFIX}/share/adb-filesystem-doublecommander-plugin/LICENCE"

  # Registers the plugin in Double Commander's config. Runs unsandboxed on
  # every install/upgrade. DC rewrites its config on quit, so editing is only
  # safe while it is closed; when skipped, `brew reinstall --cask` re-runs it.
  postflight do
    require "fileutils"
    config = File.join(Dir.home, "Library/Preferences/doublecmd/doublecmd.xml")
    wfx = "#{HOMEBREW_PREFIX}/share/adb-filesystem-doublecommander-plugin/adbfsplugin.wfx"
    if !File.exist?(config)
      puts "Double Commander has no config yet. Start it once, quit it, then run:"
      puts "  brew reinstall --cask adb-filesystem-doublecommander-plugin"
    else
      content = File.read(config)
      if content.include?(wfx)
        puts "Plugin already registered in Double Commander."
      elsif system("/usr/bin/pgrep", "-q", "-x", "doublecmd")
        puts "Double Commander is running and would overwrite the registration when it quits."
        puts "Quit it, then run: brew reinstall --cask adb-filesystem-doublecommander-plugin"
      else
        entry = "<WfxPlugin Enabled=\"True\">\n" \
                "        <Name>Android</Name>\n" \
                "        <Path>#{wfx}</Path>\n" \
                "      </WfxPlugin>"
        updated =
          if content.include?("adbfsplugin.wfx")
            # an older registration exists - repoint it at this install
            content.sub(%r{<Path>[^<]*adbfsplugin\.wfx</Path>}, "<Path>#{wfx}</Path>")
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
          puts "Restart Double Commander to load it."
        end
      end
    end
  end

  # Deregisters the plugin from Double Commander's config on uninstall,
  # same safety rules as postflight: only while Double Commander is closed.
  uninstall_postflight do
    require "fileutils"
    config = File.join(Dir.home, "Library/Preferences/doublecmd/doublecmd.xml")
    wfx = "#{HOMEBREW_PREFIX}/share/adb-filesystem-doublecommander-plugin/adbfsplugin.wfx"
    if File.exist?(config) && File.read(config).include?(wfx)
      if system("/usr/bin/pgrep", "-q", "-x", "doublecmd")
        puts "Double Commander is running - its plugin registration was left in place."
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
      end
    end
  end

  caveats <<~EOS
    The plugin registers itself in Double Commander automatically when
    possible (config present and Double Commander not running); restart
    Double Commander afterwards and enter the Android entry in the drive
    list (Alt+F1 / Alt+F2). If registration was skipped, quit Double
    Commander and run:
      brew reinstall --cask adb-filesystem-doublecommander-plugin
    Manual alternative in Double Commander:
      Configuration -> Options... -> Plugins -> File System Plugins (WFX)
      -> Add -> #{HOMEBREW_PREFIX}/share/adb-filesystem-doublecommander-plugin/adbfsplugin.wfx
  EOS
end

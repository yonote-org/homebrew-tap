class AdbFilesystemDoublecommanderPlugin < Formula
  desc "ADB filesystem (WFX) plugin for Double Commander"
  homepage "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin"
  version "1.0.5"
  license "AGPL-3.0-or-later"

  on_arm do
    url "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin/releases/download/v#{version}/adbfsplugin-#{version}-macos-arm64.zip"
    sha256 "eb80f19caa867653e9dfcdc74ac74ed9f2d357628d4b008ac55e64b0e9974bb9"
  end
  on_intel do
    url "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin/releases/download/v#{version}/adbfsplugin-#{version}-macos-x86_64.zip"
    sha256 "e2b677b398ae91478b1de370c748090fccc5a4a0cc21f4e4592555aec9d23ae2"
  end

  livecheck do
    url "https://github.com/yonote-org/adb-filesystem-doublecommander-plugin"
    strategy :github_latest
  end

  def install
    prefix.install "adbfsplugin.wfx", "pluginst.inf", "LICENCE"
    doc.install "README.md"
  end

  # Registers the plugin in Double Commander's config. Runs unsandboxed after
  # every install/upgrade; re-runnable any time with `brew postinstall`.
  # DC rewrites its config on quit, so editing is only safe while it is closed.
  def post_install
    config = File.expand_path("~/Library/Preferences/doublecmd/doublecmd.xml")
    wfx = opt_prefix/"adbfsplugin.wfx"

    unless File.exist?(config)
      ohai "Double Commander has no config yet. Start it once, quit it, then run:"
      ohai "  brew postinstall #{name}"
      return
    end

    content = File.read(config)
    if content.include?(wfx.to_s)
      ohai "Plugin already registered in Double Commander"
      return
    end

    if quiet_system("/usr/bin/pgrep", "-q", "-x", "doublecmd")
      opoo "Double Commander is running and would overwrite the change when it quits."
      opoo "Quit Double Commander, then run: brew postinstall #{name}"
      return
    end

    entry = <<~XML.strip
      <WfxPlugin Enabled="True">
              <Name>Android</Name>
              <Path>#{wfx}</Path>
            </WfxPlugin>
    XML

    updated =
      if content.include?("adbfsplugin.wfx")
        # an older registration exists - repoint it at this keg
        content.sub(%r{<Path>[^<]*adbfsplugin\.wfx</Path>}, "<Path>#{wfx}</Path>")
      elsif content.include?("</WfxPlugins>")
        content.sub("</WfxPlugins>", "  #{entry}\n    </WfxPlugins>")
      elsif content.include?("<WfxPlugins/>")
        content.sub("<WfxPlugins/>", "<WfxPlugins>\n      #{entry}\n    </WfxPlugins>")
      end

    if updated.nil? || updated == content
      opoo "Could not update #{config} - register the plugin manually (see caveats)"
      return
    end

    FileUtils.cp config, "#{config}.bak"
    File.write(config, updated)
    ohai "Registered the plugin in Double Commander (backup: doublecmd.xml.bak)."
    ohai "Restart Double Commander to load it."
  end

  def caveats
    <<~EOS
      The plugin registers itself in Double Commander automatically when
      possible (config present and Double Commander not running); restart
      Double Commander afterwards and enter the Android entry in the drive
      list (Alt+F1 / Alt+F2). If registration was skipped, quit Double
      Commander and run:
        brew postinstall #{name}
      Manual alternative in Double Commander:
        Configuration -> Options... -> Plugins -> File System Plugins (WFX)
        -> Add -> #{opt_prefix}/adbfsplugin.wfx
    EOS
  end

  test do
    assert_path_exists opt_prefix/"adbfsplugin.wfx"
  end
end

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

  def caveats
    <<~EOS
      Register the plugin in Double Commander:
        Configuration -> Options... -> Plugins -> File System Plugins (WFX) -> Add
      and select:
        #{opt_prefix}/adbfsplugin.wfx
      Then open the drive list (Alt+F1 / Alt+F2) and enter the Android entry.
    EOS
  end

  test do
    assert_path_exists opt_prefix/"adbfsplugin.wfx"
  end
end

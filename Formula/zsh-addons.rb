class ZshAddons < Formula
  desc "Modular zsh addons: git-aware prompt, history search, Homebrew helpers"
  homepage "https://github.com/yonote-org/.zsh"
  url "https://github.com/yonote-org/.zsh.git",
      tag:      "v1.3.0",
      revision: "85aa8293a29bb286bfa982a8664068315f5cab37"
  license "MIT"
  head "https://github.com/yonote-org/.zsh.git", branch: "main"

  depends_on "expect" # unbuffer, used by uless.zsh
  depends_on "git" # git.zsh prompt, brew-new's online engine
  depends_on "jq" # brew-autoupdate
  uses_from_macos "zsh"

  def install
    pkgshare.install Dir["*.zsh"]
    doc.install "README.md"

    # Point the setup command at the installed configs.zsh. HOMEBREW_PREFIX/share
    # rather than the Cellar path, so the ~/.zshrc line survives upgrades.
    inreplace "zsh-addons-setup", /^configs_default=.*$/,
              "configs_default=\"#{HOMEBREW_PREFIX}/share/zsh-addons/configs.zsh\""
    bin.install "zsh-addons-setup"
  end

  def caveats
    <<~EOS
      Run `zsh-addons-setup` to add the line that loads the addons to ~/.zshrc
      (honours ZDOTDIR, safe to re-run). Before `brew uninstall zsh-addons`,
      run `zsh-addons-setup --remove` to take that line out again.

      Or add it yourself:
        [[ -f #{HOMEBREW_PREFIX}/share/zsh-addons/configs.zsh ]] && source #{HOMEBREW_PREFIX}/share/zsh-addons/configs.zsh

      Individual modules can be sourced from that directory instead. Personal
      overrides go in ~/.zsh/local-user-config.zsh, which configs.zsh sources
      last if it exists.
    EOS
  end

  test do
    ENV["ZDOTDIR"] = testpath.to_s
    rc = testpath/".zshrc"
    system bin/"zsh-addons-setup"
    assert_match "source \"#{HOMEBREW_PREFIX}/share/zsh-addons/configs.zsh\"", rc.read
    system bin/"zsh-addons-setup"
    assert_equal 1, rc.read.lines.count
    system bin/"zsh-addons-setup", "--remove"
    refute_match "configs.zsh", rc.read

    functions = %w[brew_new brewuy brew_autoupdate_check confirm members cd_git_root]
    output = shell_output(
      "zsh -f -c 'source #{pkgshare}/configs.zsh && whence -w bn #{functions.join(" ")}'",
    )
    functions.each { |fn| assert_match "#{fn}: function", output }
    assert_match "bn: alias", output
    assert_match "newly added to Homebrew",
                 shell_output("zsh -f -c 'source #{pkgshare}/brew-new.zsh && brew_new -h'")
  end
end

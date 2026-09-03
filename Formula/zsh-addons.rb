class ZshAddons < Formula
  desc "Modular zsh addons: git-aware prompt, history search, Homebrew helpers"
  homepage "https://github.com/yonote-org/.zsh"
  url "https://github.com/yonote-org/.zsh.git",
      tag:      "v1.0.0",
      revision: "bec81c8f991f611486fc4aa4e6a363949b84e2e5"
  license "MIT"
  head "https://github.com/yonote-org/.zsh.git", branch: "main"

  depends_on "expect" # unbuffer, used by uless.zsh
  depends_on "jq" # brew-new's online engine
  uses_from_macos "zsh"

  def install
    pkgshare.install Dir["*.zsh"]
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      Add this line to ~/.zshrc to load all the addons:

        [[ -f #{opt_pkgshare}/configs.zsh ]] && source #{opt_pkgshare}/configs.zsh

      Or source individual modules from that directory. Personal overrides go in
      ~/.zsh/local-user-config.zsh, which configs.zsh sources last if it exists.
      The [[ -f ]] guard keeps the shell quiet after `brew uninstall zsh-addons`;
      remove the line to finish uninstalling.
    EOS
  end

  test do
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

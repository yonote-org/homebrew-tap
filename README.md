# yonote-org Homebrew tap

```sh
brew tap yonote-org/tap
```

| Formula | Description |
|---|---|
| [`zsh-addons`](Formula/zsh-addons.rb) | [Zsh configuration addons](https://github.com/yonote-org/.zsh): git-aware prompt, history search widgets, colour-preserving `less`, and Homebrew helpers (`brew-new`, cask autoupdate management) |

| Cask | Description |
|---|---|
| [`adb-fs-tc-plugin`](Casks/adb-fs-tc-plugin.rb) | [ADB filesystem (WFX) plugin](https://github.com/yonote-org/adb-fs-tc-plugin) for Double Commander on macOS — registers itself in Double Commander automatically |

## zsh-addons

```sh
brew install yonote-org/tap/zsh-addons
zsh-addons-setup
```

`brew install` puts the modules under `$(brew --prefix)/share/zsh-addons`
and, as declared dependencies, the two tools they rely on: `expect`
(`unbuffer`, for `uless.zsh`) and `jq` (for `brew-autoupdate` and `brew-new`'s
online fallback) — `brew uninstall` removes them again unless you had
installed them yourself. `zsh-addons-setup`
then adds the one line that loads them to `~/.zshrc` (honours `ZDOTDIR`; safe
to re-run):

```sh
[[ -f "/opt/homebrew/share/zsh-addons/configs.zsh" ]] && source "/opt/homebrew/share/zsh-addons/configs.zsh"  # zsh-addons
```

Homebrew formulae cannot edit `~/.zshrc` themselves (they install inside a
write sandbox and have no uninstall hook), which is why this is a command you
run rather than something `brew install` does — add the line by hand if you
prefer. Individual modules can be sourced instead of `configs.zsh`. Personal
overrides go in `~/.zsh/local-user-config.zsh`, which `configs.zsh` sources
last if it exists — it lives outside Homebrew's prefix, so upgrades never
touch it. The [repo README](https://github.com/yonote-org/.zsh#readme)
describes each module.

To uninstall, take the line out first, then remove the formula:

```sh
zsh-addons-setup --remove
brew uninstall zsh-addons
```

(If you uninstall first, the `[[ -f ... ]]` guard keeps the shell quiet until
you delete the line by hand.)

## adb-fs-tc-plugin

```sh
brew install --cask yonote-org/tap/adb-fs-tc-plugin
```

Install **registers** the plugin in Double Commander's config
(`~/Library/Preferences/doublecmd/doublecmd.xml`) and
`brew uninstall --cask` **deregisters** it again — both automatically, with a
`doublecmd.xml.bak` backup written before any change. If Double Commander is
running, it is asked to quit gracefully (macOS may show a one-time
permission prompt for controlling it) and relaunched after the change —
Double Commander only reads its config at startup and overwrites it on quit,
so edits must happen while it is closed. If it refuses to quit (e.g. an
unsaved editor prompt) or had never been started, the change is skipped —
run `brew reinstall --cask adb-fs-tc-plugin` to retry (or remove the entry
by hand after an uninstall: **Configuration → Options… → Plugins → File
System Plugins (WFX)**). Only the entry pointing at this cask's own
`adb-fs-tc-plugin.wfx` is ever touched.

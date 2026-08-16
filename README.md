# yonote-org Homebrew tap

```sh
brew install --cask yonote-org/tap/adb-fs-tc-plugin
```

| Cask | Description |
|---|---|
| [`adb-fs-tc-plugin`](Casks/adb-fs-tc-plugin.rb) | [ADB filesystem (WFX) plugin](https://github.com/yonote-org/adb-fs-tc-plugin) for Double Commander on macOS — registers itself in Double Commander automatically |

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

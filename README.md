# yonote-org Homebrew tap

```sh
brew install --cask yonote-org/tap/adb-filesystem-doublecommander-plugin
```

| Cask | Description |
|---|---|
| [`adb-filesystem-doublecommander-plugin`](Casks/adb-filesystem-doublecommander-plugin.rb) | [ADB filesystem (WFX) plugin](https://github.com/yonote-org/adb-filesystem-doublecommander-plugin) for Double Commander on macOS — registers itself in Double Commander automatically |

Install **registers** the plugin in Double Commander's config
(`~/Library/Preferences/doublecmd/doublecmd.xml`) and
`brew uninstall --cask` **deregisters** it again — both automatically, with a
`doublecmd.xml.bak` backup written before any change. Registration is only
edited while Double Commander is closed (it overwrites its config on quit);
if it was running, or had never been started, quit it and run
`brew reinstall --cask adb-filesystem-doublecommander-plugin`
(or remove the entry by hand after an uninstall: **Configuration →
Options… → Plugins → File System Plugins (WFX)**). Only the entry pointing
at this cask's own `adbfsplugin.wfx` is ever touched.

# Redragon M612 Pro — F13–F24 Macro Generator

Add **F13 through F24** as programmable mouse-button macros on the **Redragon Predator M612RGB-PRO** using its official Windows configuration utility.

The Redragon app's macro recorder does not expose F13–F24 directly, but the app can import the keycodes from its local `MacroKey.txt` file and program them into the mouse. The editor may show *blank key labels* for these macros; that does not necessarily prevent them from working.

**No firmware flashing, driver replacement, AutoHotkey, or permanently running background software is needed.** Once programmed, the mouse can execute the macro from onboard memory. In testing, an F14 macro continued to work on a second Windows computer without Redragon software installed.

> [!IMPORTANT]
> Community-developed and unofficial. Tested with **M612RGB-PRO** and **Mouse Drive Beta / Redragon software v1.0.0.4**. Other Redragon models and software versions have not been verified. Back up your settings before making changes.

## Quick start

1. Install and launch the official Redragon M612RGB-PRO configuration utility. Create and save a simple test macro if needed to ensure that the `MacroKey.txt` file exists.
2. **Completely exit the Redragon software**, including the system-tray icon.
3. Save [`Redragon-M612Pro-F13-F24.ps1`](Redragon-M612Pro-F13-F24.ps1) to your **Downloads** folder.
4. Open **Windows PowerShell** and run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\Redragon-M612Pro-F13-F24.ps1"
   ```

   If the script is somewhere else, change the path after `-File`. This command does **not** permanently change your execution policy.
5. Reopen the Redragon app. You should see macros named `PS_F13`, `PS_F14`, ... `PS_F24` in its macro list.
6. Assign any of those macros to a mouse button, click **Apply**, and test the button in a keyboard-event tester.

> [!TIP]
> The editor may show a press and release with **no key name** for F13–F24. **Do not re-record or manually modify the key events inside the Redragon editor**, because it may not understand those labels. Use the macros as loaded.

## Generate selected keys only

To add only particular macros (for example F13, F14, and F20):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
& "$HOME\Downloads\Redragon-M612Pro-F13-F24.ps1" -Keys 13,14,20
```

## What the script does

- Locates `%LOCALAPPDATA%\Redragon\Redragon M612RGB-PRO\MacroKey.txt`.
- Checks that `Mouse Drive Beta.exe` is closed before editing.
- Saves a timestamped backup of the macro file before changes.
- Appends missing macros `PS_F13` through `PS_F24` without replacing existing ones.
- Skips already-present macro names so rerunning the script is safe.
- Uses USB HID keyboard usage IDs `0x68` through `0x73`.

It **does not communicate with the USB device directly**, and it does not install any software.

## Troubleshooting

**No `MacroKey.txt` found:** Open Redragon, record and save any ordinary macro, then completely exit the application and rerun the script.

**Macro names appear, but the event key labels are blank:** This is expected for the extended function keys in the tested editor. Assign the macro to a button and test the actual output.

**A button doesn't output the new key:** Ensure you assigned the *macro* to the desired button and clicked **Apply**. Test with a keyboard event viewer capable of showing F13–F24.

**Need to revert the macro file:** Close Redragon and restore the timestamped `MacroKey.txt.backup-...` created by the script. This restores the *local macro list*; it does not necessarily undo button assignments already written to onboard memory.

## Compatibility and testing

| Item | Status |
| --- | --- |
| Redragon Predator **M612RGB-PRO** | Tested |
| Redragon software **v1.0.0.4** / `Mouse Drive Beta.exe` | Tested |
| Generation of F13–F24 macros | Reported working on tested setup |
| F14 on a different computer without Redragon software | Verified |
| Other Redragon mice / other software builds | Not tested |

## Technical details

See [docs/TECHNICAL-NOTES.md](docs/TECHNICAL-NOTES.md) for the observed macro format, HID codes, and why the editor sometimes displays blank names.

## Inspiration and acknowledgments

Inspired by the F13–F24 workaround for the **non-Pro** Redragon mouse in [MAKS11060/REDRAGON-Gaming-Mouse-Custom-Macros](https://github.com/MAKS11060/REDRAGON-Gaming-Mouse-Custom-Macros). The M612RGB-PRO stores macros in a different format and location, so this project provides a separate generator for the Pro utility.

This project is **not affiliated with or endorsed by Redragon**.

## License

Copyright (c) 2026 CoreLineNexus

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.

You are free to use, modify, and distribute this software
in accordance with the terms of the MIT License.

This is an independent, community-developed project
and is not affiliated with or endorsed by Redragon.

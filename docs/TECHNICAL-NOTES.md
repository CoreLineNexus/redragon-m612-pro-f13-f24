# M612RGB-PRO macro format — technical notes

These notes record observations from testing with `Mouse Drive Beta.exe` / Redragon software v1.0.0.4. They describe *observed behavior*, not an official Redragon specification.

## Local storage

Macro definitions were found in:

```text
%LOCALAPPDATA%\Redragon\Redragon M612RGB-PRO\MacroKey.txt
```

The installation folder's `Config.ini` was not the macro-definition store in the tested setup.

## Example: F14

The tested `PS_F14` entry was created by appending:

```text
Macro Name:PS_F14
Macro Context Count:2
Macro Cycle Times:1
01 00 69 00 1A 00
01 01 69 00 00 00
```

`69` is USB HID keyboard usage `0x69` (F14). The pair of event rows is interpreted by the tool as press and release. The `1A` timing value reproduces the successful test macro; the full binary/text format and timing units have not been independently documented.

The Redragon app displayed blank key labels for this custom macro, but the mouse output F14 when its assigned button was pressed.

## USB HID usage IDs

| Key | HID hex | Key | HID hex |
| --- | --- | --- | --- |
| F13 | `68` | F19 | `6E` |
| F14 | `69` | F20 | `6F` |
| F15 | `6A` | F21 | `70` |
| F16 | `6B` | F22 | `71` |
| F17 | `6C` | F23 | `72` |
| F18 | `6D` | F24 | `73` |

## Device-log evidence

After selecting the hand-authored `PS_F14`, `Device1_log.txt` showed a `WriteFlashData` entry containing:

```text
81 69 00 00 1A 41 69 00 00 00 A5
```

The two `69` bytes match F14's HID usage. The last byte has not been reverse-engineered here. The script **does not generate or send flash packets**; it relies on the Redragon app to program the mouse.

## Persistence

An F14-assigned mouse was moved to another Windows computer with **no Redragon configuration software**, and the macro still triggered F14. This verifies onboard operation for that tested macro.

## Safety and scope

The script only edits the user's local macro text file after creating a backup. It refuses to run if the Redragon software process is open. It does not modify firmware and does not change the mouse button assignments itself. Users must apply their chosen button-to-macro assignments in the official app.

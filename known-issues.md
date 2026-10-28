# Known issues

Maintained by the Port-Sight team. One `##` heading per issue; the fields below are read by the support assistant.

## A map returns 500 on open
- **Versions:** 2.15.0 to 2.15.21
- **Fixed in:** 2.15.22
- **Cause:** A candidate kind was added to the subnet derivation but not to the API schema, so opening a map that produced one failed.
- **Fix or workaround:** Update to 2.15.22 or later.

## Capacity Trends boards appear to have vanished
- **Versions:** 2.14.35 to 2.15.12
- **Fixed in:** 2.15.13
- **Cause:** The summary endpoint raised for a tracked interface that was not bound to a map, and the page hid the boards behind that failure. The boards themselves were intact.
- **Fix or workaround:** Update to 2.15.13 or later; the boards reappear without any other action.

## A Dell stack is reported as a whole-chassis swap after a reload
- **Versions:** up to 2.15.22
- **Fixed in:** 2.15.23
- **Cause:** Dell stacks report the current master's serial number on every member, so a change of master looked like every member being replaced.
- **Fix or workaround:** Update to 2.15.23 or later. The pending change left over from before the update needs a one-time clear; contact support for the one-time clear.

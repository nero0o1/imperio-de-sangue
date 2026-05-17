# Wave 4.6.2I - Persistent Gather Loop and Navigation Recovery

## Summary

This wave investigates and corrects two coupled NPC issues in the `GATHER_RESOURCE` flow:

- after a successful warehouse deposit, the order behaved like a one-shot gather instead of re-entering resource search;
- navigation failures during the warehouse leg of a gather order were treated as final order failures, while resource-leg failures already had blacklist/retry behavior.

The implemented correction is intentionally narrow. It keeps the existing order queue, Wave 4.6.2H pickup reservation, temporary blacklist, inventory, warehouse, and construction systems intact.

## Observed behavior

Manual validation reported that a single gather order collected one pickup, deposited it, waited briefly near the warehouse, and then returned to idle/previous position. Repeating gather manually many times worked, which showed that pickup collection and warehouse deposit were basically functional.

Dynamic obstacle validation also showed that newly placed buildings can physically block NPC movement. The NPC may continue trying a route computed before the obstacle existed and eventually report a stuck/navigation failure.

## Reproduction steps

Persistent gather:

1. Open `res://scenes/test/NPCWave4OrderIntegrationTest.tscn`.
2. Ensure there are multiple wood and stone pickups and a valid warehouse.
3. Select one NPC.
4. Issue one `GATHER_RESOURCE` order for wood, stone, or any resource.
5. Observe the state after the first successful deposit.

Dynamic obstacle:

1. Send an NPC toward a pickup or warehouse.
2. Place a building so it blocks the intended route.
3. Observe whether the NPC recovers, retries, blacklists the pickup, or ends the whole order.

## Root cause found

The gather loop and navigation issues had different concrete causes:

- The post-deposit `GATHER_RESOURCE` transition needed an explicit same-order continuation path. After deposit, the executor must release the old target, preserve the original resource filter, re-enter `COLLECTOR_FINDING_RESOURCE`, and scan candidates before completing or advancing the queue.
- The any-resource order was previously at risk of being narrowed to the first selected pickup resource type. That made "any resource" less dynamic after a deposit.
- Movement failure while going to a resource already used the Wave 4.6.2H unreachable-target path, which blacklists the pickup and continues searching. Movement failure while going to a warehouse still finished the order as `FAILED`, causing the queue/order cleanup path to run.
- Player-built structures appear to have physical collision, but this project does not currently register completed buildings as `NavigationObstacle3D` and no dynamic navmesh rebake path was found. The static navigation mesh can therefore become stale when construction changes the world.

## Hypotheses rejected

- Warehouse deposit itself is not the primary failure: repeated manual gather orders can collect and deposit repeatedly.
- The queue system is not intentionally round-robin for persistent gather. A queued wood order should complete or become partial before stone begins.
- Pickup reservation is not the root cause of the one-shot deposit behavior; reservation release is still required on every target exit path.
- The construction/build NPC flow is mostly independent and was not rewritten.

## Files changed

- `scripts/npc/npc_order_executor.gd`
- `scripts/npc/npc_base.gd`
- `docs/WAVE_4_6_2I_PERSISTENT_GATHER_AND_NAV_RECOVERY.md`

## State transition before

Observed/likely bad flow:

```text
FINDING_RESOURCE
-> MOVING_TO_RESOURCE
-> COLLECTING_RESOURCE
-> MOVING_TO_WAREHOUSE
-> DEPOSITING
-> order cleanup / next order / return to idle
```

Warehouse navigation failure path:

```text
GOING_TO_DEPOSIT
-> stuck or timeout
-> FAILED
-> current order cleanup
```

## State transition after

Corrected gather deposit flow:

```text
FINDING_RESOURCE
-> MOVING_TO_RESOURCE
-> COLLECTING_RESOURCE
-> MOVING_TO_WAREHOUSE
-> DEPOSITING
-> FINDING_RESOURCE
```

The order completes only after the follow-up scan confirms there are no valid pickups left for the filter. If valid pickups exist but all are temporarily unavailable due to blacklist/reservation, the order returns `PARTIAL`.

Warehouse navigation failure path:

```text
GOING_TO_DEPOSIT
-> stuck or timeout
-> clear cached warehouse route
-> retry warehouse discovery/path up to a bounded limit
-> FAILED only after retry guard is exhausted
```

## Fix implemented

In `npc_order_executor.gd`:

- added a post-deposit continuation path for `GATHER_RESOURCE`;
- preserved the original resource filter across deposit, including empty filter for "any resource";
- after deposit, released the current pickup reservation, cleared the target, reset warehouse retry state, and returned to `COLLECTOR_FINDING_RESOURCE`;
- used the existing resource candidate scan to decide whether to continue, complete, or partial;
- kept pickup route failures on the blacklist/retry path;
- added bounded warehouse route recovery before failing a gather order;
- cached collector interaction approach targets to avoid resetting the same navigation target every frame.

In `npc_base.gd`:

- improved navigation debug context with next path position and navigation-finished state;
- renamed touched warning-prone identifiers without changing behavior.

## Navigation findings

NPCs use `NavigationAgent3D` and already have local stuck detection/recovery attempts. The agent can retry nearby offset targets, but it cannot fully solve stale static navmesh data caused by newly placed buildings.

The safe hotfix behavior is:

- if moving to a pickup fails, release the pickup reservation, temporarily blacklist that target, and search another pickup;
- if moving to the warehouse fails, clear the cached warehouse target/path and retry warehouse navigation a limited number of times;
- if the warehouse remains unreachable, return `FAILED` because the NPC cannot safely deposit inventory.

## Dynamic obstacle findings

Searches found building placement and completed building collision logic, but no active `NavigationObstacle3D` registration and no dynamic navmesh rebake flow for player-built structures. This means dynamic construction can block physics movement without updating the navigation representation.

This wave does not implement a broad dynamic navigation system. A future wave should add either obstacle registration for completed buildings or an explicit navmesh update strategy.

## Warnings fixed

- Renamed `project_position_to_navigation(position)` to `project_position_to_navigation(world_position)`.
- Renamed local variable `sign` to `direction_sign`.

## Tests run

- `git status -sb`
- `git diff --check`
- Godot headless project boot:
  - `C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit`
- Godot headless integrated scene:
  - `C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 5 res://scenes/test/NPCWave4OrderIntegrationTest.tscn`

Available test scenes found:

- `scenes/test/TestMap.tscn`
- `scenes/test/TestInventoryWarehouse.tscn`
- `scenes/test/TestInteractable.tscn`
- `scenes/test/NPCWave4Test.tscn`
- `scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `scenes/test/NPCWave4ConstructionStressTest.tscn`

No GUT/WAT/addon unit test runner directory was found during the project search.

## Tests pending

Manual gameplay validation is still pending. The headless integrated scene only proves the project and scene parse/run for a short boot window; it does not prove the complete multi-cycle player workflow.

## Manual homologation checklist

For Francisco:

| Test | How to validate | Passes if |
| --- | --- | --- |
| Single wood order | Order gather wood once | NPC performs multiple pickup/deposit cycles |
| Single stone order | Order gather stone once | NPC performs multiple pickup/deposit cycles |
| Any resource | Order gather any resource once | NPC re-scans after each deposit |
| Queue wood then stone | Queue both orders | Wood persists before stone starts |
| Stone 15 times | Repeat current manual regression | Existing repeated-order behavior still works |
| Dynamic building obstacle | Block route during movement | NPC does not erase the order immediately |
| Existing houses obstacle | Put resource near/behind house | NPC routes around or blacklists and changes target |
| Two NPCs same resource | Order both to gather same type | They do not reserve the same pickup |
| No resources remaining | Exhaust requested pickups | Order ends `COMPLETED` |
| Unavailable resources | Block or reserve all valid pickups | Order ends `PARTIAL` or chooses another reachable target |
| Invalid warehouse | Simulate missing/deposit failure | Order ends `FAILED` |
| Cancellation | Cancel during gather | Reservation is released |

## Known risks

- Dynamic buildings are still not fully represented in navigation. The recovery logic can retry or abandon a blocked target, but it cannot make a static navmesh understand newly built obstacles.
- Warehouse route recovery is bounded to avoid infinite loops. If the only warehouse remains unreachable, the order still fails after retries.
- Manual validation is required to confirm that idle/return-to-origin now happens only after the gather order truly completes or becomes partial/failed.
- The integrated scene boot does not simulate the full player queue and obstruction workflows.

## Recommendation

Do not merge as fully homologated until Francisco completes the manual checklist above. The code is suitable for manual validation because project boot, integrated scene boot, and diff whitespace validation passed, and the fix is limited to the gather executor and NPC navigation diagnostics/recovery.

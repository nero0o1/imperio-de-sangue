# Wave 4.5 - Semantic RTS/RPG Order System

## Scope

This wave adds a semantic order layer for NPCs without replacing the existing player movement, NPC movement, or building systems.

## Files Created

- `scripts/npc/npc_capability_set.gd`
- `scripts/npc/npc_tactical_state.gd`
- `scripts/npc/npc_order_queue.gd`
- `scripts/npc/npc_order_executor.gd`

## Files Changed

- `scripts/npc/npc_enums.gd`
- `scripts/npc/npc_order.gd`
- `scripts/npc/npc_base.gd`

## Architecture

- `NPCEnums` is the central registry for order types and order statuses.
- `NPCOrder` carries semantic order data: type, target position, target node, queue flag, priority, status, failure reason, debug label, and timestamps.
- `NPCOrderQueue` owns the current order and pending queue.
- `NPCCapabilitySet` validates whether an NPC can attempt an order.
- `NPCTacticalState` records posture and tactical locks for debugging and future expansion.
- `NPCOrderExecutor` starts, processes, completes, partially executes, or rejects orders.
- `NPCBase` exposes public order helpers and bridges orders to the existing movement/building behavior.

## Queue Rules

- A non-queued order cancels the current order, clears pending orders, and starts immediately.
- A queued order is appended as `PENDING` while the current order continues.
- `STOP` cancels the current order and clears pending orders.
- `CLEAR_QUEUE` clears only pending orders and preserves the current order.
- Finished, failed, cancelled, unsupported, and partial orders advance the queue.

## Real Execution

- `MOVE_TO_POSITION`
- `STOP`
- `HOLD_POSITION`
- `FOLLOW_TARGET`
- `ASSIST_BUILD`
- `CLEAR_QUEUE`

`ASSIST_BUILD` calls the target building's `can_build_step(actor)` and `build_step(actor)` methods. It does not consume resources directly and does not bypass existing construction completion rules.

## Partial Execution

- `ATTACK_MOVE`: moves to the target point, then returns `PARTIAL`.
- `PATROL`: moves to one patrol point, then returns `PARTIAL`.
- `FIRE_AT_WILL`: records attack posture, then returns `PARTIAL`.
- `HOLD_FIRE`: records hold-fire posture and blocks automatic chase semantically, then returns `PARTIAL`.
- `FORM_SHIELD_WALL`: stops movement, reduces speed while active, blocks chase, then returns `PARTIAL`.
- `BRACE_PIKES`: stops movement, blocks movement/chase, then returns `PARTIAL`.
- `GARRISON`: returns `PARTIAL` only when the target exposes minimal garrison support.

## Unsupported Orders

These orders are recognized and return `UNSUPPORTED` with a reason when the required system is missing:

- `FOCUS_FIRE`
- `VOLLEY_FIRE`
- `GATHER_RESOURCE`
- `FORCE_DROP`
- `REPAIR`
- `REPAIR_UNDER_FIRE`
- `MAN_SIEGE_RAM`
- `SCALE_WALLS`
- `SAP_FOUNDATION`
- `POUR_MURDER_HOLES`
- `SALLY_OUT`

Capability failures also return `UNSUPPORTED` with a clear reason.

## Public API

```gdscript
npc.issue_order(order)
npc.issue_move_order(position, queue)
npc.issue_stop_order()
npc.issue_hold_position_order()
npc.issue_follow_order(target, queue)
npc.issue_assist_build_order(building_site, queue)
npc.issue_test_order_by_type(NPCEnums.OrderType.FORM_SHIELD_WALL)
```

Orders can also be built directly:

```gdscript
var order := NPCOrder.make(NPCEnums.OrderType.FORM_SHIELD_WALL)
npc.issue_order(order)
```

## Expected Logs

```text
[Order] Civil NPC received MOVE_TO_POSITION target=(x, y, z)
[Order] Civil NPC started ASSIST_BUILD target=(0, 0, 0) node=BuildingSite_Casa_01
[Order] Civil NPC completed MOVE_TO_POSITION
[Order] Soldier NPC PARTIAL FORM_SHIELD_WALL: FORM_SHIELD_WALL partial: visual formation not implemented.
[Order] Civil NPC UNSUPPORTED VOLLEY_FIRE: VOLLEY_FIRE unsupported: NPC lacks required capability.
```

## Validation Performed

- Inspected project structure and existing NPC/building/test scripts.
- Confirmed there is no Git repository in `O:\game`.
- Cross-referenced order symbols and legacy `FOLLOW_PLAYER` usage with `rg`.
- Checked that existing `NPCOrder.move_to_position`, `NPCOrder.follow_player`, and `NPCOrder.stop` helpers remain available.

## Validation Not Performed

- Godot headless scene loading and script syntax validation were not executed because `godot`, `godot4`, `godot.console`, and `godot4.console` were not available in PATH.
- Manual editor validation was not executed from this environment.

## Manual Test Targets

- Issue `MOVE_TO_POSITION` and confirm NPC movement.
- Issue `STOP` and confirm movement stops and queue clears.
- Issue `HOLD_POSITION` and confirm the NPC remains locked until a new explicit movement order or STOP.
- Issue `FOLLOW_TARGET` and confirm the NPC follows a valid target.
- Issue `ASSIST_BUILD` against a valid `BuildingSite` and confirm progress uses existing build methods.
- Queue multiple move orders and confirm next order starts after completion.
- Issue `FORM_SHIELD_WALL`, `BRACE_PIKES`, `VOLLEY_FIRE`, and `GARRISON` and confirm `PARTIAL`/`UNSUPPORTED` reasons are logged.

## Remaining Risks

- No automated Godot parser run was available in this environment.
- UI command coverage is still minimal; advanced orders are exposed through public methods.
- Combat, resource gathering, repair, siege, and formation visuals remain semantic contracts only.
- Capability defaults may need balancing once unit archetypes become concrete.

## Recommended Next Wave

Build a small in-editor command test harness or debug command palette, then add focused automated scenes for queue behavior, construction assist, capability rejection, and partial/unsupported order feedback.

# enemybar2

This is an addon for Windower4 for FFXI. It creates a big health bar for the target to make it easy to see.

The `ffxi-bar-skin-2026-10-07` branch adds a main-target gauge prototype: a dark recessed trough, near-black outline, restrained bevel and highlight, and separate left/center/right pieces for both the trough and fill. The center stretches; the endcaps retain their shape except at nearly empty HP. The shell is neutral and the fill takes the configured bar color. The main target uses this skin by default; other frames retain the classic skin for the first test.

![FFXI gauge skin, rendered from the shipped assets](docs/ffxi-bar-preview.png)

This preview is an offline composition of the actual PNG assets at their display dimensions. The blue and green examples demonstrate reuse of the same pieces; they do not enable those skins on the other frames. The assets are original FFXI-inspired vector artwork based on the supplied visual reference, rather than extracted `51.DAT` textures.

To install the testing package, merge its `enemybar2` directory into `Windower/addons/enemybar2`, replacing the included files. The package includes no `data` directory, so existing character settings remain available. Reload and explicitly select the prototype and HP pink, since an existing saved color takes precedence over the new default:

```text
//lua reload enemybar2
//eb set skin t ffxi
//eb set color t 255 149 151
//eb setup
```

Use `//eb setup` again to return to live targeting. Setup retains the existing drag and Ctrl-snap controls. If the saved position is outside the current viewport, `//eb set pos t 120 120` brings the test gauge into view. Test full, partial and empty HP, switching targets, clearing the target, dragging, and reloading. `//eb set skin t classic` restores the original renderer. Both skins use the same existing width/color commands.

This pass changes the gauge renderer and its text outline only. Combat tracking, action/attention displays, debuff handling, text placement and HP update timing retain their existing behavior. Distance, action and target indicators remain off by default. Gauge geometry and bar lifecycle tests pass outside the client; visual filtering and actual game behavior still need a Windower/FFXI test.

Developers can rebuild the six PNG pieces with `python tools/build_skin.py` (Python 3 and Inkscape), and run `lua tests/gauge_spec.lua` from the repository root. The tests check zero/tiny/full HP, fixed shell dimensions, movement and hover, both renderers, repeated recreation and complete primitive cleanup.

![alt text](https://i.imgur.com/8g96UZY.png)

### Commands:
target_frame = **t**arget/**s**ub**t**arget/**f**ocus**t**arget/**a**ggro/all. Specifies which target frame to update the settings for, or all of them.

| Command | Action |
| --- | --- |
| //eb setup/debug/demo/test | Activate setup mode. Enables draging target frames and displays everything with your current settings. Ctrl-drag to snap to grid. |
| //eb focustarget/ft [target name] | Specifies a focus target. The focus target frame will display this target's hp and status. |
| //eb **s**et pos *target_frame* x y | Moves a target frame to a specified position |
| //eb **s**et color *target_frame* red green blue | Specifies the hp bar color for the given target frame |
| //eb **s**et skin *target_frame* ffxi/classic | Selects the new gauge skin or the original renderer for a frame. |
| //eb **s**et count *target_frame* i | Specifies the number of aggro'd monsters to display in the aggro frame |
| //eb **s**et stack_dir *target_frame* up/down | Specifies the stack direction of the aggro frame. Up stacks upwards, down stacks downwards |
| //eb **s**et stack_padding *target_frame* i | Specifies the distance between the target bars in the aggro frame |
| //eb **s**et font *target_frame* font_name | Specifies the font name for the given target frame. |
| //eb **s**et font_size *target_frame* i | Specifies the font size for the given target frame. |
| //eb **s**et width *target_frame* i | Specifies the width of the hp bar for the given target frame. |
| //eb **s**et show *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the given target frame. |
| //eb **s**et show_target_icon *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display whether the enemy is targeted or not in the given target frame. |
| //eb **s**et show_target *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the target of the target in the given target frame. |
| //eb **s**et show_debuff *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the debuffs on the target in the given target frame. |
| //eb **s**et show_action *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the current action of the target in the given target frame. |
| //eb **s**et show_dist *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the distance from the target in the given target frame. |
| //eb help | Shows help text for this addon |

UPDATE: 1.1
Updates;
- unified healbar creation and management logic
Added several things:
- focus target function to track a specified target's status
- mob action (spell/ws) and attention tracking (not quite enmity, but close)
- aggro'd mobs can now be displayed as a stack of health bars + their action and attention
- display for target/subtarget/focustarget/aggro'd mobs' distance.
- indicator on aggro'd mobs' health bars for which is targeted.
- indicator on target/subtarget/focustarget/aggro'd mobs for crowd control status effects

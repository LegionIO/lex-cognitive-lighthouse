# lex-cognitive-lighthouse

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Beacon and fog metaphor for navigational clarity in cognitive processing. Beacons represent sources of truth, clarity, warning, guidance, and hope — each with a luminosity level. Fog banks represent confusion, uncertainty, ambiguity, doubt, and overwhelm — each with a density level. The sweep operation actively disperses fog using beacon luminosity, modeling how clarity-producing cognition reduces confusion.

## Gem Info

- **Gem name**: `lex-cognitive-lighthouse`
- **Module**: `Legion::Extensions::CognitiveLighthouse`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_lighthouse/
  version.rb
  client.rb
  helpers/
    constants.rb
    beacon.rb
    fog.rb
    lighthouse_engine.rb
  runners/
    cognitive_lighthouse.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `BEACON_TYPES` | `%i[truth clarity warning guidance hope]` | Valid beacon categories |
| `FOG_TYPES` | `%i[confusion uncertainty ambiguity doubt overwhelm]` | Valid fog categories |
| `MAX_BEACONS` | `100` | Per-engine beacon capacity |
| `MAX_FOG_BANKS` | `50` | Per-engine fog capacity |
| `LUMINOSITY_RATE` | `0.1` | Default brightness change per brighten/dim operation |
| `FOG_DENSITY_RATE` | `0.05` | Default density change per thicken/disperse operation |
| `VISIBILITY_LABELS` | range hash | From `:blind` to `:crystal_clear` |
| `LUMINOSITY_LABELS` | range hash | From `:dark` to `:blazing` |

## Helpers

### `Helpers::Beacon`
Emits light to cut through cognitive fog. Has `id`, `beacon_type`, `luminosity`, `domain`, `content`, and `created_at`.

- `brighten!(rate)` — increases luminosity
- `dim!(rate)` — decreases luminosity
- `extinguished?` — luminosity at or below zero
- `blazing?` — luminosity at maximum
- `luminosity_label`
- `to_h`

### `Helpers::Fog`
Represents a cloud of cognitive obscuration. Has `id`, `fog_type`, `density`, `domain`, `content`, and `created_at`.

- `thicken!(rate)` — increases density
- `disperse!(rate)` — decreases density
- `impenetrable?` — density at maximum
- `clearing?` — density below a low threshold
- `visibility_label` — based on inverse of density
- `to_h`

### `Helpers::LighthouseEngine`
Manages beacons and fog banks, enforces capacity limits.

- `light_beacon(beacon_type:, luminosity:, domain:, content:)` → beacon or capacity error
- `create_fog(fog_type:, density:, domain:, content:)` → fog or capacity error
- `sweep` — for each beacon, disperses fog banks in the same domain; dispersion amount = `beacon.luminosity * 0.5`; extinguished beacons are pruned
- `dim_all!(rate:)` — dims all beacons, prunes extinguished ones
- `thicken_all!(rate:)` — thickens all fog banks
- `brightest_beacons(limit:)` → top N by luminosity
- `densest_fogs(limit:)` → top N by density
- `visibility_report` → aggregate stats hash

## Runners

Module: `Runners::CognitiveLighthouse`

| Runner Method | Description |
|---|---|
| `light_beacon(beacon_type:, luminosity:, domain:, content:)` | Create a new beacon |
| `create_fog(fog_type:, density:, domain:, content:)` | Create a new fog bank |
| `sweep` | Beacons disperse fog in matching domains |
| `list_beacons(limit:)` | Brightest beacons |
| `navigation_status` | Full visibility report |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- No direct dependencies on other agentic LEX gems
- Can integrate with `lex-tick` phase handlers: low overall visibility → switch to sentinel mode
- Beacon luminosity can be boosted when `lex-emotion` valence is positive
- Fog density can be increased on `lex-conflict` escalation events
- `sweep` is the natural action for the agent's clarification-seeking behavior

## Development Notes

- `Client` instantiates `@lighthouse_engine = Helpers::LighthouseEngine.new`
- `sweep` prunes beacons that become extinguished after dispersion calculations
- Beacon and fog domains are matched for targeted dispersion — a `:truth` beacon only disperses fog in its own domain
- `MAX_BEACONS = 100` and `MAX_FOG_BANKS = 50` are hard engine-level caps

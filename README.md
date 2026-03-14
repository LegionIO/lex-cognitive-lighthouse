# lex-cognitive-lighthouse

Beacon and fog navigation model for LegionIO cognitive agents. Beacons (truth, clarity, warning, guidance, hope) actively disperse fog banks (confusion, uncertainty, ambiguity, doubt, overwhelm) through sweep operations.

## What It Does

- Light beacons with luminosity levels to represent sources of cognitive clarity
- Create fog banks with density levels to represent sources of cognitive obscuration
- Run `sweep` to have beacons disperse fog in their matching domains
- Track overall visibility across all fog banks
- Monitor brightest beacons and densest fog clusters
- Beacons that dim to zero are pruned automatically during sweep

## Usage

```ruby
# Light a beacon
runner.light_beacon(beacon_type: :clarity, luminosity: 0.8,
                    domain: :reasoning, content: 'Root cause identified')

# Create a fog bank
runner.create_fog(fog_type: :uncertainty, density: 0.6,
                  domain: :reasoning, content: 'Multiple conflicting hypotheses')

# Sweep: beacons disperse fog in their domain
runner.sweep
# => { success: true, swept: 1, beacons_dimmed: 0, beacons_pruned: 0 }

# Check navigation status
runner.navigation_status
# => { success: true, total_beacons: 1, total_fog_banks: 1, avg_luminosity: 0.8, avg_density: ..., ... }

# List brightest beacons
runner.list_beacons(limit: 5)
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT

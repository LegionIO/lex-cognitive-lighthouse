# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLighthouse
      module Helpers
        class LighthouseEngine
          def initialize
            @beacons   = {}
            @fog_banks = {}
          end

          def light_beacon(beacon_type:, domain:, content:, luminosity: nil, sweep_angle: nil)
            raise ArgumentError, 'too many beacons' if @beacons.size >= Constants::MAX_BEACONS

            beacon = Beacon.new(
              beacon_type: beacon_type,
              domain:      domain,
              content:     content,
              luminosity:  luminosity,
              sweep_angle: sweep_angle
            )
            @beacons[beacon.id] = beacon
            beacon
          end

          def create_fog(fog_type:, domain:, density: nil, extent: nil)
            raise ArgumentError, 'too many fog banks' if @fog_banks.size >= Constants::MAX_FOG_BANKS

            fog = Fog.new(fog_type: fog_type, domain: domain, density: density, extent: extent)
            @fog_banks[fog.id] = fog
            fog
          end

          def sweep(beacon_id:, fog_id:)
            beacon = fetch_beacon(beacon_id)
            fog    = fetch_fog(fog_id)

            reduction = (beacon.luminosity * 0.5).round(10)
            fog.disperse!(rate: reduction)

            { beacon: beacon.to_h, fog: fog.to_h, reduction: reduction }
          end

          def dim_all!(rate: Constants::LUMINOSITY_RATE)
            @beacons.each_value { |b| b.dim!(rate: rate) }
            pruned = @beacons.select { |_, b| b.extinguished? }.keys
            pruned.each { |id| @beacons.delete(id) }
            { remaining: @beacons.size, pruned: pruned.size }
          end

          def thicken_all!(rate: Constants::FOG_DENSITY_RATE)
            @fog_banks.each_value { |f| f.thicken!(rate: rate) }
            { fog_banks: @fog_banks.size }
          end

          def brightest_beacons(limit: 5)
            @beacons.values
                    .reject(&:extinguished?)
                    .sort_by { |b| -b.luminosity }
                    .first(limit)
          end

          def densest_fogs(limit: 5)
            @fog_banks.values
                      .sort_by { |f| -f.density }
                      .first(limit)
          end

          def visibility_report
            avg_luminosity = compute_average_luminosity
            avg_density    = compute_average_density
            net_visibility = (avg_luminosity - avg_density).clamp(0.0, 1.0).round(10)

            {
              total_beacons:    @beacons.size,
              total_fog_banks:  @fog_banks.size,
              avg_luminosity:   avg_luminosity,
              avg_density:      avg_density,
              net_visibility:   net_visibility,
              blazing_beacons:  @beacons.count { |_, b| b.blazing? },
              extinguished:     @beacons.count { |_, b| b.extinguished? },
              impenetrable_fog: @fog_banks.count { |_, f| f.impenetrable? },
              clearing_fog:     @fog_banks.count { |_, f| f.clearing? }
            }
          end

          def all_beacons
            @beacons.values
          end

          def all_fog_banks
            @fog_banks.values
          end

          private

          def fetch_beacon(id)
            @beacons.fetch(id) { raise ArgumentError, "beacon not found: #{id}" }
          end

          def fetch_fog(id)
            @fog_banks.fetch(id) { raise ArgumentError, "fog bank not found: #{id}" }
          end

          def compute_average_luminosity
            return 0.0 if @beacons.empty?

            total = @beacons.values.sum(&:luminosity)
            (total / @beacons.size).round(10)
          end

          def compute_average_density
            return 0.0 if @fog_banks.empty?

            total = @fog_banks.values.sum(&:density)
            (total / @fog_banks.size).round(10)
          end
        end
      end
    end
  end
end

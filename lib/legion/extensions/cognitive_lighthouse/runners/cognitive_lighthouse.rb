# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLighthouse
      module Runners
        module CognitiveLighthouse
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def light_beacon(beacon_type:, domain:, content:, luminosity: nil,
                           sweep_angle: nil, engine: nil, **)
            eng    = resolve_engine(engine)
            beacon = eng.light_beacon(
              beacon_type: beacon_type,
              domain:      domain,
              content:     content,
              luminosity:  luminosity,
              sweep_angle: sweep_angle
            )
            Legion::Logging.debug "[lighthouse] lit beacon: type=#{beacon_type} domain=#{domain} " \
                                  "luminosity=#{beacon.luminosity}"
            { success: true, beacon: beacon.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def create_fog(fog_type:, domain:, density: nil, extent: nil, engine: nil, **)
            eng = resolve_engine(engine)
            fog = eng.create_fog(fog_type: fog_type, domain: domain,
                                 density: density, extent: extent)
            Legion::Logging.debug "[lighthouse] created fog: type=#{fog_type} domain=#{domain} " \
                                  "density=#{fog.density}"
            { success: true, fog: fog.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def sweep(beacon_id:, fog_id:, engine: nil, **)
            eng    = resolve_engine(engine)
            result = eng.sweep(beacon_id: beacon_id, fog_id: fog_id)
            Legion::Logging.debug "[lighthouse] sweep: beacon=#{beacon_id} fog=#{fog_id} " \
                                  "reduction=#{result[:reduction]}"
            { success: true, **result }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_beacons(engine: nil, domain: nil, beacon_type: nil, **)
            eng     = resolve_engine(engine)
            results = eng.all_beacons
            results = results.select { |b| b.domain == domain.to_s } if domain
            results = results.select { |b| b.beacon_type == beacon_type.to_sym } if beacon_type
            { success: true, beacons: results.map(&:to_h), count: results.size }
          end

          def navigation_status(engine: nil, **)
            eng = resolve_engine(engine)
            { success: true, report: eng.visibility_report }
          end

          private

          def resolve_engine(engine)
            engine || default_engine
          end

          def default_engine
            @default_engine ||= Helpers::LighthouseEngine.new
          end
        end
      end
    end
  end
end

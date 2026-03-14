# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLighthouse
      module Helpers
        class Beacon
          attr_reader :id, :beacon_type, :domain, :content, :sweep_angle, :lit_at
          attr_accessor :luminosity

          def initialize(beacon_type:, domain:, content:, luminosity: nil, sweep_angle: nil)
            validate_beacon_type!(beacon_type)
            @id          = SecureRandom.uuid
            @beacon_type = beacon_type.to_sym
            @domain      = domain.to_s
            @content     = content.to_s
            @luminosity  = (luminosity || 0.7).to_f.clamp(0.0, 1.0).round(10)
            @sweep_angle = (sweep_angle || 0.0).to_f.clamp(0.0, 360.0).round(10)
            @lit_at      = Time.now.utc
          end

          def brighten!(rate: Constants::LUMINOSITY_RATE)
            @luminosity = (@luminosity + rate).clamp(0.0, 1.0).round(10)
            self
          end

          def dim!(rate: Constants::LUMINOSITY_RATE)
            @luminosity = (@luminosity - rate).clamp(0.0, 1.0).round(10)
            self
          end

          def extinguished?
            @luminosity <= 0.0
          end

          def blazing?
            @luminosity >= 0.9
          end

          def luminosity_label
            Constants.label_for(Constants::LUMINOSITY_LABELS, @luminosity)
          end

          def to_h
            {
              id:               @id,
              beacon_type:      @beacon_type,
              domain:           @domain,
              content:          @content,
              luminosity:       @luminosity,
              sweep_angle:      @sweep_angle,
              luminosity_label: luminosity_label,
              extinguished:     extinguished?,
              blazing:          blazing?,
              lit_at:           @lit_at
            }
          end

          private

          def validate_beacon_type!(type)
            sym = type.to_sym
            return if Constants::BEACON_TYPES.include?(sym)

            raise ArgumentError,
                  "unknown beacon_type: #{type.inspect}; must be one of #{Constants::BEACON_TYPES.inspect}"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLighthouse
      module Helpers
        class Fog
          attr_reader :id, :fog_type, :domain, :extent, :formed_at
          attr_accessor :density

          def initialize(fog_type:, domain:, density: nil, extent: nil)
            validate_fog_type!(fog_type)
            @id       = SecureRandom.uuid
            @fog_type = fog_type.to_sym
            @domain   = domain.to_s
            @density  = (density || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @extent   = (extent || 1.0).to_f.clamp(0.0, 1.0).round(10)
            @formed_at = Time.now.utc
          end

          def thicken!(rate: Constants::FOG_DENSITY_RATE)
            @density = (@density + rate).clamp(0.0, 1.0).round(10)
            self
          end

          def disperse!(rate: Constants::FOG_DENSITY_RATE)
            @density = (@density - rate).clamp(0.0, 1.0).round(10)
            self
          end

          def impenetrable?
            @density >= 1.0
          end

          def clearing?
            @density < 0.2
          end

          def visibility_label
            Constants.label_for(Constants::VISIBILITY_LABELS, @density)
          end

          def to_h
            {
              id:               @id,
              fog_type:         @fog_type,
              domain:           @domain,
              density:          @density,
              extent:           @extent,
              visibility_label: visibility_label,
              impenetrable:     impenetrable?,
              clearing:         clearing?,
              formed_at:        @formed_at
            }
          end

          private

          def validate_fog_type!(type)
            sym = type.to_sym
            return if Constants::FOG_TYPES.include?(sym)

            raise ArgumentError,
                  "unknown fog_type: #{type.inspect}; must be one of #{Constants::FOG_TYPES.inspect}"
          end
        end
      end
    end
  end
end

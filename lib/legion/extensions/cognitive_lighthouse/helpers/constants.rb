# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLighthouse
      module Helpers
        module Constants
          BEACON_TYPES = %i[truth clarity warning guidance hope].freeze
          FOG_TYPES    = %i[confusion uncertainty ambiguity doubt overwhelm].freeze

          MAX_BEACONS   = 100
          MAX_FOG_BANKS = 50

          LUMINOSITY_RATE   = 0.1
          FOG_DENSITY_RATE  = 0.05

          # Visibility labels (fog density: high density = low visibility)
          VISIBILITY_LABELS = [
            [(0.0...0.1), :crystal_clear],
            [(0.1...0.3), :clear],
            [(0.3...0.5), :hazy],
            [(0.5...0.7), :foggy],
            [(0.7...0.9), :dense_fog],
            [(0.9..),     :blind]
          ].freeze

          # Luminosity labels (beacon luminosity: high = bright)
          LUMINOSITY_LABELS = [
            [(0.9..),      :blazing],
            [(0.7...0.9),  :bright],
            [(0.5...0.7),  :steady],
            [(0.3...0.5),  :dim],
            [(0.1...0.3),  :faint],
            [(..0.1),      :dark]
          ].freeze

          def self.label_for(table, value)
            table.each { |range, label| return label if range.cover?(value) }
            table.last.last
          end
        end
      end
    end
  end
end

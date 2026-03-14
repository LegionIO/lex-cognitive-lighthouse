# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Helpers::Constants do
  describe 'BEACON_TYPES' do
    it 'contains expected types' do
      expect(described_class::BEACON_TYPES).to include(:truth, :clarity, :warning, :guidance, :hope)
    end

    it 'is frozen' do
      expect(described_class::BEACON_TYPES).to be_frozen
    end
  end

  describe 'FOG_TYPES' do
    it 'contains expected types' do
      expect(described_class::FOG_TYPES).to include(:confusion, :uncertainty, :ambiguity, :doubt, :overwhelm)
    end

    it 'is frozen' do
      expect(described_class::FOG_TYPES).to be_frozen
    end
  end

  describe 'capacity constants' do
    it 'MAX_BEACONS is positive' do
      expect(described_class::MAX_BEACONS).to be > 0
    end

    it 'MAX_FOG_BANKS is positive' do
      expect(described_class::MAX_FOG_BANKS).to be > 0
    end
  end

  describe 'rate constants' do
    it 'LUMINOSITY_RATE is between 0 and 1' do
      expect(described_class::LUMINOSITY_RATE).to be > 0
      expect(described_class::LUMINOSITY_RATE).to be < 1
    end

    it 'FOG_DENSITY_RATE is between 0 and 1' do
      expect(described_class::FOG_DENSITY_RATE).to be > 0
      expect(described_class::FOG_DENSITY_RATE).to be < 1
    end
  end

  describe 'VISIBILITY_LABELS' do
    it 'covers full [0, 1] range' do
      expect(described_class::VISIBILITY_LABELS).not_to be_empty
    end

    it 'includes :crystal_clear and :blind' do
      labels = described_class::VISIBILITY_LABELS.map(&:last)
      expect(labels).to include(:crystal_clear, :blind)
    end
  end

  describe 'LUMINOSITY_LABELS' do
    it 'includes :blazing and :dark' do
      labels = described_class::LUMINOSITY_LABELS.map(&:last)
      expect(labels).to include(:blazing, :dark)
    end
  end

  describe '.label_for' do
    it 'returns crystal_clear for density 0.0' do
      expect(described_class.label_for(described_class::VISIBILITY_LABELS, 0.0)).to eq(:crystal_clear)
    end

    it 'returns blind for density 1.0' do
      expect(described_class.label_for(described_class::VISIBILITY_LABELS, 1.0)).to eq(:blind)
    end

    it 'returns blazing for luminosity 1.0' do
      expect(described_class.label_for(described_class::LUMINOSITY_LABELS, 1.0)).to eq(:blazing)
    end

    it 'returns dark for luminosity 0.0' do
      expect(described_class.label_for(described_class::LUMINOSITY_LABELS, 0.0)).to eq(:dark)
    end

    it 'returns steady for mid-range luminosity' do
      expect(described_class.label_for(described_class::LUMINOSITY_LABELS, 0.6)).to eq(:steady)
    end

    it 'returns foggy for mid-range density' do
      expect(described_class.label_for(described_class::VISIBILITY_LABELS, 0.6)).to eq(:foggy)
    end

    it 'falls back to last label for out-of-range values' do
      result = described_class.label_for(described_class::LUMINOSITY_LABELS, 2.0)
      expect(result).to be_a(Symbol)
    end
  end
end

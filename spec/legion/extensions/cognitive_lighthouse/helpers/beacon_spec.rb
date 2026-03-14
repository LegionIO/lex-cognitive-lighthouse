# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Helpers::Beacon do
  subject(:beacon) { described_class.new(beacon_type: :truth, domain: 'reasoning', content: 'north star') }

  describe '#initialize' do
    it 'sets beacon_type as symbol' do
      expect(beacon.beacon_type).to eq(:truth)
    end

    it 'sets domain as string' do
      expect(beacon.domain).to eq('reasoning')
    end

    it 'sets content as string' do
      expect(beacon.content).to eq('north star')
    end

    it 'defaults luminosity to 0.7' do
      expect(beacon.luminosity).to be_within(0.001).of(0.7)
    end

    it 'defaults sweep_angle to 0.0' do
      expect(beacon.sweep_angle).to be_within(0.001).of(0.0)
    end

    it 'assigns a UUID id' do
      expect(beacon.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets lit_at timestamp' do
      expect(beacon.lit_at).to be_a(Time)
    end

    it 'clamps luminosity to [0, 1]' do
      b = described_class.new(beacon_type: :clarity, domain: 'x', content: 'y', luminosity: 2.0)
      expect(b.luminosity).to eq(1.0)
    end

    it 'clamps sweep_angle to [0, 360]' do
      b = described_class.new(beacon_type: :hope, domain: 'x', content: 'y', sweep_angle: 400.0)
      expect(b.sweep_angle).to eq(360.0)
    end

    it 'raises for unknown beacon_type' do
      expect do
        described_class.new(beacon_type: :mirage, domain: 'x', content: 'y')
      end.to raise_error(ArgumentError, /unknown beacon_type/)
    end

    it 'accepts all valid beacon types' do
      Legion::Extensions::CognitiveLighthouse::Helpers::Constants::BEACON_TYPES.each do |type|
        expect do
          described_class.new(beacon_type: type, domain: 'test', content: 'test')
        end.not_to raise_error
      end
    end
  end

  describe '#brighten!' do
    it 'increases luminosity by default rate' do
      beacon.luminosity = 0.5
      beacon.brighten!
      expect(beacon.luminosity).to be_within(0.001).of(0.6)
    end

    it 'accepts custom rate' do
      beacon.luminosity = 0.5
      beacon.brighten!(rate: 0.2)
      expect(beacon.luminosity).to be_within(0.001).of(0.7)
    end

    it 'clamps at 1.0' do
      beacon.luminosity = 0.95
      beacon.brighten!(rate: 0.1)
      expect(beacon.luminosity).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(beacon.brighten!).to eq(beacon)
    end
  end

  describe '#dim!' do
    it 'decreases luminosity by default rate' do
      beacon.luminosity = 0.5
      beacon.dim!
      expect(beacon.luminosity).to be_within(0.001).of(0.4)
    end

    it 'accepts custom rate' do
      beacon.luminosity = 0.5
      beacon.dim!(rate: 0.3)
      expect(beacon.luminosity).to be_within(0.001).of(0.2)
    end

    it 'clamps at 0.0' do
      beacon.luminosity = 0.05
      beacon.dim!(rate: 0.1)
      expect(beacon.luminosity).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(beacon.dim!).to eq(beacon)
    end
  end

  describe '#extinguished?' do
    it 'returns false when luminosity > 0' do
      beacon.luminosity = 0.5
      expect(beacon.extinguished?).to be false
    end

    it 'returns true when luminosity is 0' do
      beacon.luminosity = 0.0
      expect(beacon.extinguished?).to be true
    end
  end

  describe '#blazing?' do
    it 'returns false for moderate luminosity' do
      beacon.luminosity = 0.5
      expect(beacon.blazing?).to be false
    end

    it 'returns true when luminosity >= 0.9' do
      beacon.luminosity = 0.9
      expect(beacon.blazing?).to be true
    end
  end

  describe '#luminosity_label' do
    it 'returns a symbol' do
      expect(beacon.luminosity_label).to be_a(Symbol)
    end

    it 'returns :blazing for luminosity 1.0' do
      beacon.luminosity = 1.0
      expect(beacon.luminosity_label).to eq(:blazing)
    end

    it 'returns :dark for luminosity 0.0' do
      beacon.luminosity = 0.0
      expect(beacon.luminosity_label).to eq(:dark)
    end

    it 'returns :steady for mid-range luminosity' do
      beacon.luminosity = 0.6
      expect(beacon.luminosity_label).to eq(:steady)
    end
  end

  describe '#to_h' do
    it 'includes expected keys' do
      h = beacon.to_h
      %i[id beacon_type domain content luminosity sweep_angle
         luminosity_label extinguished blazing lit_at].each do |k|
        expect(h).to have_key(k)
      end
    end

    it 'beacon_type matches' do
      expect(beacon.to_h[:beacon_type]).to eq(:truth)
    end

    it 'extinguished is boolean' do
      expect(beacon.to_h[:extinguished]).to be(false).or be(true)
    end
  end
end

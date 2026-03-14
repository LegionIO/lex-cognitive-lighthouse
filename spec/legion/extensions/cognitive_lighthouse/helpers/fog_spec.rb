# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Helpers::Fog do
  subject(:fog) { described_class.new(fog_type: :confusion, domain: 'decision', density: 0.5) }

  describe '#initialize' do
    it 'sets fog_type as symbol' do
      expect(fog.fog_type).to eq(:confusion)
    end

    it 'sets domain as string' do
      expect(fog.domain).to eq('decision')
    end

    it 'sets density' do
      expect(fog.density).to be_within(0.001).of(0.5)
    end

    it 'defaults density to 0.5' do
      f = described_class.new(fog_type: :doubt, domain: 'x')
      expect(f.density).to be_within(0.001).of(0.5)
    end

    it 'defaults extent to 1.0' do
      f = described_class.new(fog_type: :doubt, domain: 'x')
      expect(f.extent).to be_within(0.001).of(1.0)
    end

    it 'assigns a UUID id' do
      expect(fog.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets formed_at timestamp' do
      expect(fog.formed_at).to be_a(Time)
    end

    it 'clamps density to [0, 1]' do
      f = described_class.new(fog_type: :doubt, domain: 'x', density: 1.5)
      expect(f.density).to eq(1.0)
    end

    it 'raises for unknown fog_type' do
      expect do
        described_class.new(fog_type: :sunshine, domain: 'x')
      end.to raise_error(ArgumentError, /unknown fog_type/)
    end

    it 'accepts all valid fog types' do
      Legion::Extensions::CognitiveLighthouse::Helpers::Constants::FOG_TYPES.each do |type|
        expect do
          described_class.new(fog_type: type, domain: 'test')
        end.not_to raise_error
      end
    end
  end

  describe '#thicken!' do
    it 'increases density by default rate' do
      fog.density = 0.5
      fog.thicken!
      expect(fog.density).to be_within(0.001).of(0.55)
    end

    it 'accepts custom rate' do
      fog.density = 0.5
      fog.thicken!(rate: 0.2)
      expect(fog.density).to be_within(0.001).of(0.7)
    end

    it 'clamps at 1.0' do
      fog.density = 0.98
      fog.thicken!(rate: 0.05)
      expect(fog.density).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(fog.thicken!).to eq(fog)
    end
  end

  describe '#disperse!' do
    it 'decreases density by default rate' do
      fog.density = 0.5
      fog.disperse!
      expect(fog.density).to be_within(0.001).of(0.45)
    end

    it 'accepts custom rate' do
      fog.density = 0.5
      fog.disperse!(rate: 0.3)
      expect(fog.density).to be_within(0.001).of(0.2)
    end

    it 'clamps at 0.0' do
      fog.density = 0.03
      fog.disperse!(rate: 0.05)
      expect(fog.density).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(fog.disperse!).to eq(fog)
    end
  end

  describe '#impenetrable?' do
    it 'returns false when density < 1.0' do
      fog.density = 0.9
      expect(fog.impenetrable?).to be false
    end

    it 'returns true when density is 1.0' do
      fog.density = 1.0
      expect(fog.impenetrable?).to be true
    end
  end

  describe '#clearing?' do
    it 'returns false when density >= 0.2' do
      fog.density = 0.5
      expect(fog.clearing?).to be false
    end

    it 'returns true when density < 0.2' do
      fog.density = 0.1
      expect(fog.clearing?).to be true
    end
  end

  describe '#visibility_label' do
    it 'returns a symbol' do
      expect(fog.visibility_label).to be_a(Symbol)
    end

    it 'returns :blind for max density' do
      fog.density = 1.0
      expect(fog.visibility_label).to eq(:blind)
    end

    it 'returns :crystal_clear for zero density' do
      fog.density = 0.0
      expect(fog.visibility_label).to eq(:crystal_clear)
    end

    it 'returns :foggy for mid-range density' do
      fog.density = 0.6
      expect(fog.visibility_label).to eq(:foggy)
    end
  end

  describe '#to_h' do
    it 'includes expected keys' do
      h = fog.to_h
      %i[id fog_type domain density extent visibility_label impenetrable clearing formed_at].each do |k|
        expect(h).to have_key(k)
      end
    end

    it 'fog_type matches' do
      expect(fog.to_h[:fog_type]).to eq(:confusion)
    end

    it 'clearing is boolean' do
      expect(fog.to_h[:clearing]).to be(false).or be(true)
    end
  end
end

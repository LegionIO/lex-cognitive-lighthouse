# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Runners::CognitiveLighthouse do
  let(:engine) { Legion::Extensions::CognitiveLighthouse::Helpers::LighthouseEngine.new }

  describe '.light_beacon' do
    it 'returns success with beacon hash' do
      result = described_class.light_beacon(
        beacon_type: :truth, domain: 'logic', content: 'north star', engine: engine
      )
      expect(result[:success]).to be true
      expect(result[:beacon][:beacon_type]).to eq(:truth)
    end

    it 'returns failure for invalid beacon_type' do
      result = described_class.light_beacon(
        beacon_type: :mirage, domain: 'x', content: 'y', engine: engine
      )
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'passes luminosity to engine' do
      result = described_class.light_beacon(
        beacon_type: :hope, domain: 'x', content: 'y', luminosity: 0.9, engine: engine
      )
      expect(result[:beacon][:luminosity]).to be_within(0.001).of(0.9)
    end

    it 'passes sweep_angle to engine' do
      result = described_class.light_beacon(
        beacon_type: :clarity, domain: 'x', content: 'y', sweep_angle: 90.0, engine: engine
      )
      expect(result[:beacon][:sweep_angle]).to be_within(0.001).of(90.0)
    end

    it 'ignores extra kwargs via ** splat' do
      expect do
        described_class.light_beacon(
          beacon_type: :truth, domain: 'x', content: 'y',
          engine: engine, extra_key: 'ignored'
        )
      end.not_to raise_error
    end
  end

  describe '.create_fog' do
    it 'returns success with fog hash' do
      result = described_class.create_fog(
        fog_type: :confusion, domain: 'decision', engine: engine
      )
      expect(result[:success]).to be true
      expect(result[:fog][:fog_type]).to eq(:confusion)
    end

    it 'returns failure for invalid fog_type' do
      result = described_class.create_fog(
        fog_type: :sunshine, domain: 'x', engine: engine
      )
      expect(result[:success]).to be false
    end

    it 'passes density to engine' do
      result = described_class.create_fog(
        fog_type: :doubt, domain: 'x', density: 0.3, engine: engine
      )
      expect(result[:fog][:density]).to be_within(0.001).of(0.3)
    end

    it 'passes extent to engine' do
      result = described_class.create_fog(
        fog_type: :ambiguity, domain: 'x', extent: 0.7, engine: engine
      )
      expect(result[:fog][:extent]).to be_within(0.001).of(0.7)
    end

    it 'ignores extra kwargs via ** splat' do
      expect do
        described_class.create_fog(
          fog_type: :confusion, domain: 'x', engine: engine, unexpected: true
        )
      end.not_to raise_error
    end
  end

  describe '.sweep' do
    let(:beacon) do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.8)
    end
    let(:fog) { engine.create_fog(fog_type: :confusion, domain: 'x', density: 0.8) }

    it 'returns success with beacon, fog, and reduction' do
      result = described_class.sweep(beacon_id: beacon.id, fog_id: fog.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:beacon]).to have_key(:id)
      expect(result[:fog]).to have_key(:id)
      expect(result[:reduction]).to be > 0
    end

    it 'returns failure for unknown beacon' do
      result = described_class.sweep(beacon_id: 'nope', fog_id: fog.id, engine: engine)
      expect(result[:success]).to be false
    end

    it 'returns failure for unknown fog' do
      result = described_class.sweep(beacon_id: beacon.id, fog_id: 'nope', engine: engine)
      expect(result[:success]).to be false
    end

    it 'ignores extra kwargs' do
      expect do
        described_class.sweep(beacon_id: beacon.id, fog_id: fog.id,
                              engine: engine, extra: true)
      end.not_to raise_error
    end
  end

  describe '.list_beacons' do
    before do
      engine.light_beacon(beacon_type: :truth, domain: 'alpha', content: 'a')
      engine.light_beacon(beacon_type: :hope, domain: 'beta', content: 'b')
      engine.light_beacon(beacon_type: :truth, domain: 'gamma', content: 'c')
    end

    it 'returns all beacons when no filters' do
      result = described_class.list_beacons(engine: engine)
      expect(result[:count]).to eq(3)
    end

    it 'filters by domain' do
      result = described_class.list_beacons(engine: engine, domain: 'alpha')
      expect(result[:count]).to eq(1)
      expect(result[:beacons].first[:domain]).to eq('alpha')
    end

    it 'filters by beacon_type' do
      result = described_class.list_beacons(engine: engine, beacon_type: :truth)
      expect(result[:count]).to eq(2)
    end

    it 'returns success' do
      result = described_class.list_beacons(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns beacons as array of hashes' do
      result = described_class.list_beacons(engine: engine)
      expect(result[:beacons]).to be_an(Array)
      expect(result[:beacons].first).to have_key(:id)
    end
  end

  describe '.navigation_status' do
    it 'returns success with report' do
      result = described_class.navigation_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to have_key(:net_visibility)
    end

    it 'includes all report keys' do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y')
      engine.create_fog(fog_type: :confusion, domain: 'x')
      result = described_class.navigation_status(engine: engine)
      %i[total_beacons total_fog_banks avg_luminosity avg_density net_visibility].each do |k|
        expect(result[:report]).to have_key(k)
      end
    end

    it 'ignores extra kwargs' do
      expect do
        described_class.navigation_status(engine: engine, extra_param: 'x')
      end.not_to raise_error
    end
  end

  describe 'default engine (module-level state)' do
    it 'uses a default engine when none provided' do
      result = described_class.navigation_status
      expect(result[:success]).to be true
    end
  end
end

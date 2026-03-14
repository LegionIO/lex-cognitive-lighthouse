# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Helpers::LighthouseEngine do
  subject(:engine) { described_class.new }

  let(:mod) { Legion::Extensions::CognitiveLighthouse }

  describe '#light_beacon' do
    it 'creates and returns a beacon' do
      b = engine.light_beacon(beacon_type: :truth, domain: 'logic', content: 'clarity first')
      expect(b).to be_a(mod::Helpers::Beacon)
    end

    it 'stores the beacon internally' do
      engine.light_beacon(beacon_type: :hope, domain: 'x', content: 'y')
      expect(engine.all_beacons.size).to eq(1)
    end

    it 'accepts luminosity override' do
      b = engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.9)
      expect(b.luminosity).to be_within(0.001).of(0.9)
    end

    it 'accepts sweep_angle override' do
      b = engine.light_beacon(beacon_type: :clarity, domain: 'x', content: 'y', sweep_angle: 180.0)
      expect(b.sweep_angle).to be_within(0.001).of(180.0)
    end

    it 'raises when too many beacons' do
      stub_const('Legion::Extensions::CognitiveLighthouse::Helpers::Constants::MAX_BEACONS', 1)
      engine.light_beacon(beacon_type: :truth, domain: 'a', content: 'first')
      expect do
        engine.light_beacon(beacon_type: :hope, domain: 'b', content: 'second')
      end.to raise_error(ArgumentError, /too many beacons/)
    end

    it 'raises for invalid beacon_type' do
      expect do
        engine.light_beacon(beacon_type: :mirage, domain: 'x', content: 'y')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#create_fog' do
    it 'creates and returns a fog bank' do
      f = engine.create_fog(fog_type: :confusion, domain: 'planning')
      expect(f).to be_a(mod::Helpers::Fog)
    end

    it 'stores the fog bank internally' do
      engine.create_fog(fog_type: :doubt, domain: 'x')
      expect(engine.all_fog_banks.size).to eq(1)
    end

    it 'accepts density override' do
      f = engine.create_fog(fog_type: :ambiguity, domain: 'x', density: 0.8)
      expect(f.density).to be_within(0.001).of(0.8)
    end

    it 'raises when too many fog banks' do
      stub_const('Legion::Extensions::CognitiveLighthouse::Helpers::Constants::MAX_FOG_BANKS', 1)
      engine.create_fog(fog_type: :confusion, domain: 'a')
      expect do
        engine.create_fog(fog_type: :doubt, domain: 'b')
      end.to raise_error(ArgumentError, /too many fog banks/)
    end

    it 'raises for invalid fog_type' do
      expect do
        engine.create_fog(fog_type: :sunshine, domain: 'x')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#sweep' do
    let(:beacon) { engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.8) }
    let(:fog)    { engine.create_fog(fog_type: :confusion, domain: 'x', density: 0.8) }

    it 'reduces fog density' do
      old_density = fog.density
      engine.sweep(beacon_id: beacon.id, fog_id: fog.id)
      expect(fog.density).to be < old_density
    end

    it 'returns reduction amount' do
      result = engine.sweep(beacon_id: beacon.id, fog_id: fog.id)
      expect(result[:reduction]).to be > 0
    end

    it 'returns beacon and fog hashes' do
      result = engine.sweep(beacon_id: beacon.id, fog_id: fog.id)
      expect(result[:beacon]).to have_key(:id)
      expect(result[:fog]).to have_key(:id)
    end

    it 'raises for unknown beacon' do
      engine.create_fog(fog_type: :doubt, domain: 'x')
      expect { engine.sweep(beacon_id: 'nope', fog_id: fog.id) }
        .to raise_error(ArgumentError, /beacon not found/)
    end

    it 'raises for unknown fog' do
      expect { engine.sweep(beacon_id: beacon.id, fog_id: 'nope') }
        .to raise_error(ArgumentError, /fog bank not found/)
    end

    it 'brighter beacons cause larger reductions' do
      bright = engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 1.0)
      dim    = engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.2)
      fog1   = engine.create_fog(fog_type: :confusion, domain: 'a', density: 0.8)
      fog2   = engine.create_fog(fog_type: :confusion, domain: 'b', density: 0.8)

      result_bright = engine.sweep(beacon_id: bright.id, fog_id: fog1.id)
      result_dim    = engine.sweep(beacon_id: dim.id, fog_id: fog2.id)
      expect(result_bright[:reduction]).to be > result_dim[:reduction]
    end
  end

  describe '#dim_all!' do
    it 'dims all beacons' do
      b = engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.5)
      old_lum = b.luminosity
      engine.dim_all!
      expect(b.luminosity).to be < old_lum
    end

    it 'prunes extinguished beacons' do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.05)
      result = engine.dim_all!(rate: 0.1)
      expect(result[:pruned]).to be >= 1
    end

    it 'returns remaining and pruned counts' do
      engine.light_beacon(beacon_type: :hope, domain: 'x', content: 'y', luminosity: 0.8)
      result = engine.dim_all!
      expect(result).to have_key(:remaining)
      expect(result).to have_key(:pruned)
    end
  end

  describe '#thicken_all!' do
    it 'thickens all fog banks' do
      f = engine.create_fog(fog_type: :doubt, domain: 'x', density: 0.3)
      old_density = f.density
      engine.thicken_all!
      expect(f.density).to be > old_density
    end

    it 'returns fog bank count' do
      engine.create_fog(fog_type: :confusion, domain: 'x')
      result = engine.thicken_all!
      expect(result[:fog_banks]).to eq(1)
    end
  end

  describe '#brightest_beacons' do
    it 'returns sorted by luminosity descending' do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'a', luminosity: 0.3)
      engine.light_beacon(beacon_type: :hope, domain: 'y', content: 'b', luminosity: 0.9)
      engine.light_beacon(beacon_type: :clarity, domain: 'z', content: 'c', luminosity: 0.6)
      result = engine.brightest_beacons
      expect(result.first.luminosity).to be >= result.last.luminosity
    end

    it 'respects limit' do
      3.times { |i| engine.light_beacon(beacon_type: :truth, domain: "d#{i}", content: "c#{i}") }
      expect(engine.brightest_beacons(limit: 2).size).to eq(2)
    end

    it 'excludes extinguished beacons' do
      b = engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.0)
      results = engine.brightest_beacons
      expect(results).not_to include(b)
    end
  end

  describe '#densest_fogs' do
    it 'returns sorted by density descending' do
      engine.create_fog(fog_type: :confusion, domain: 'a', density: 0.2)
      engine.create_fog(fog_type: :doubt, domain: 'b', density: 0.9)
      result = engine.densest_fogs
      expect(result.first.density).to be >= result.last.density
    end

    it 'respects limit' do
      3.times { |i| engine.create_fog(fog_type: :ambiguity, domain: "d#{i}") }
      expect(engine.densest_fogs(limit: 2).size).to eq(2)
    end
  end

  describe '#visibility_report' do
    it 'returns comprehensive report hash' do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y')
      engine.create_fog(fog_type: :confusion, domain: 'x')
      report = engine.visibility_report
      %i[total_beacons total_fog_banks avg_luminosity avg_density
         net_visibility blazing_beacons extinguished impenetrable_fog clearing_fog].each do |k|
        expect(report).to have_key(k)
      end
    end

    it 'returns zeros with empty engine' do
      report = engine.visibility_report
      expect(report[:total_beacons]).to eq(0)
      expect(report[:total_fog_banks]).to eq(0)
      expect(report[:avg_luminosity]).to eq(0.0)
      expect(report[:avg_density]).to eq(0.0)
    end

    it 'net_visibility is clamped to [0, 1]' do
      engine.light_beacon(beacon_type: :hope, domain: 'x', content: 'y', luminosity: 1.0)
      report = engine.visibility_report
      expect(report[:net_visibility]).to be >= 0.0
      expect(report[:net_visibility]).to be <= 1.0
    end

    it 'counts blazing beacons' do
      engine.light_beacon(beacon_type: :truth, domain: 'x', content: 'y', luminosity: 0.95)
      expect(engine.visibility_report[:blazing_beacons]).to eq(1)
    end
  end

  describe '#all_beacons' do
    it 'returns all beacon objects' do
      engine.light_beacon(beacon_type: :truth, domain: 'a', content: 'x')
      engine.light_beacon(beacon_type: :hope, domain: 'b', content: 'y')
      expect(engine.all_beacons.size).to eq(2)
    end
  end

  describe '#all_fog_banks' do
    it 'returns all fog bank objects' do
      engine.create_fog(fog_type: :confusion, domain: 'a')
      engine.create_fog(fog_type: :doubt, domain: 'b')
      expect(engine.all_fog_banks.size).to eq(2)
    end
  end
end

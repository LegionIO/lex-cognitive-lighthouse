# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLighthouse::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a client with default engine' do
      expect(client).to be_a(described_class)
    end

    it 'accepts an injected engine' do
      custom = Legion::Extensions::CognitiveLighthouse::Helpers::LighthouseEngine.new
      c = described_class.new(engine: custom)
      expect(c).to be_a(described_class)
    end
  end

  describe 'runner method delegation' do
    it 'responds to light_beacon' do
      expect(client).to respond_to(:light_beacon)
    end

    it 'responds to create_fog' do
      expect(client).to respond_to(:create_fog)
    end

    it 'responds to sweep' do
      expect(client).to respond_to(:sweep)
    end

    it 'responds to list_beacons' do
      expect(client).to respond_to(:list_beacons)
    end

    it 'responds to navigation_status' do
      expect(client).to respond_to(:navigation_status)
    end
  end

  describe 'full lifecycle' do
    it 'lights a beacon and checks status' do
      result = client.light_beacon(beacon_type: :truth, domain: 'reasoning', content: 'seek truth')
      expect(result[:success]).to be true

      status = client.navigation_status
      expect(status[:report][:total_beacons]).to eq(1)
    end

    it 'creates fog and sweeps with beacon' do
      beacon_result = client.light_beacon(
        beacon_type: :clarity, domain: 'planning', content: 'clear path', luminosity: 0.8
      )
      fog_result = client.create_fog(fog_type: :confusion, domain: 'planning', density: 0.7)

      sweep_result = client.sweep(
        beacon_id: beacon_result[:beacon][:id],
        fog_id:    fog_result[:fog][:id]
      )

      expect(sweep_result[:success]).to be true
      expect(sweep_result[:fog][:density]).to be < 0.7
    end

    it 'lists beacons after lighting multiple' do
      client.light_beacon(beacon_type: :guidance, domain: 'alpha', content: 'first')
      client.light_beacon(beacon_type: :hope, domain: 'beta', content: 'second')

      result = client.list_beacons
      expect(result[:count]).to eq(2)
    end

    it 'persists state across calls using its own engine' do
      c1 = described_class.new
      c1.light_beacon(beacon_type: :warning, domain: 'x', content: 'y')

      c2 = described_class.new
      expect(c1.navigation_status[:report][:total_beacons]).to eq(1)
      expect(c2.navigation_status[:report][:total_beacons]).to eq(0)
    end

    it 'returns failure gracefully for invalid types' do
      result = client.light_beacon(beacon_type: :phantom, domain: 'x', content: 'y')
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'filters beacons by type' do
      client.light_beacon(beacon_type: :truth, domain: 'a', content: 'first')
      client.light_beacon(beacon_type: :hope, domain: 'b', content: 'second')
      client.light_beacon(beacon_type: :truth, domain: 'c', content: 'third')

      result = client.list_beacons(beacon_type: :truth)
      expect(result[:count]).to eq(2)
    end

    it 'navigation_status shows fog metrics' do
      client.create_fog(fog_type: :overwhelm, domain: 'x', density: 0.9)
      report = client.navigation_status[:report]
      expect(report[:total_fog_banks]).to eq(1)
      expect(report[:avg_density]).to be > 0
    end
  end
end

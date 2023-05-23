require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
  end
  describe '#initialize' do

    it 'can initialize' do
      expect(@facility).to be_an_instance_of(Facility)
      expect(@facility.name).to eq('Albany DMV Office')
      expect(@facility.address).to eq('2242 Santiam Hwy SE Albany OR 97321')
      expect(@facility.phone).to eq('541-967-2014')
      expect(@facility.services).to eq([])
    end
  end

  describe '#add service' do

    it 'can add available services' do
      expect(@facility.services).to eq([])
      @facility.add_service('New Drivers License')
      @facility.add_service('Renew Drivers License')
      @facility.add_service('Vehicle Registration')
      expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#register vehicle' do

    it 'can give vehicles registration dates and plate type' do
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
      cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
      bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
      camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
      facility_1.add_service('Vehicle Registration')
      
      expect(cruz.registration_date).to eq(nil)
      expect(cruz.plate_type).to eq(nil)
      facility_1.register_vehicle(cruz)
      expect(cruz.registration_date).to eq(Date.today)
      expect(cruz.plate_type).to eq(:regular)
      facility_1.register_vehicle(bolt)
      expect(bolt.registration_date).to eq(Date.today)
      expect(bolt.plate_type).to eq(:ev)
      facility_1.register_vehicle(camaro)
      expect(camaro.registration_date).to eq(Date.today)
      expect(camaro.plate_type).to eq(:antique)
    end
    
    it 'can collct payment and store records of registrations' do
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
      cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
      bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
      camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
      facility_1.add_service('Vehicle Registration')
      
      expect(facility_1.collected_fees).to eq(0)
      expect(facility_1.registered_vehicles).to eq([])
      facility_1.register_vehicle(cruz)
      expect(facility_1.collected_fees).to eq(100)
      expect(facility_1.registered_vehicles).to eq([cruz])
      facility_1.register_vehicle(bolt)
      expect(facility_1.collected_fees).to eq(300)
      expect(facility_1.registered_vehicles).to eq([cruz, bolt])
      facility_1.register_vehicle(camaro)
      expect(facility_1.collected_fees).to eq(325)
      expect(facility_1.registered_vehicles).to eq([cruz, bolt, camaro])
      facility_2.register_vehicle(camaro)
      expect(facility_2.collected_fees).to eq(0)
      expect(facility_2.registered_vehicles).to eq([])
    end
  end

  describe '#administer written test' do

    it 'can give written test if facility has service' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      registrant_2 = Registrant.new('Penny', 16 )
      registrant_3 = Registrant.new('Tucker', 15 )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })

      expect(registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      expect(registrant_1.permit?).to be true
      facility_1.administer_written_test(registrant_1)
      expect(registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      facility_1.add_service('Written Test')
      facility_1.administer_written_test(registrant_1)
      expect(registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    end

    it 'can give written test only if permitted' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      registrant_2 = Registrant.new('Penny', 16 )
      registrant_3 = Registrant.new('Tucker', 15 )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
      facility_1.add_service('Written Test')
      
      expect(registrant_2.age).to eq(16)
      expect(registrant_2.permit?).to be false
      facility_1.administer_written_test(registrant_2)
      expect(registrant_2.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      registrant_2.earn_permit
      facility_1.administer_written_test(registrant_2)
      expect(registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    end

    it 'can only give written test if old enough' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      registrant_2 = Registrant.new('Penny', 16 )
      registrant_3 = Registrant.new('Tucker', 15 )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })

      expect(registrant_3.age).to eq(15)
      expect(registrant_3.permit?).to be false
      facility_1.administer_written_test(registrant_3)
      expect(registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      registrant_3.earn_permit
      expect(registrant_3.permit?).to be true
      facility_1.administer_written_test(registrant_3)
      expect(registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    end
  end

  describe '#administer_road_test' do

    it 'requires facility service' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_1.add_service('Written Test')
      facility_1.administer_written_test(registrant_1)
      
      facility_1.administer_road_test(registrant_1)
      expect(registrant_1.license_data[:license]).to eq(false)
      facility_1.add_service('Road Test')
      facility_1.administer_road_test(registrant_1)
      expect(registrant_1.license_data[:license]).to eq(true)
    end
    
    it 'requires permit and written test' do
      registrant_2 = Registrant.new('Penny', 16 )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')

      facility_1.administer_road_test(registrant_2)
      expect(registrant_2.license_data[:license]).to eq(false)
      registrant_2.earn_permit
      facility_1.administer_road_test(registrant_2)
      expect(registrant_2.license_data[:license]).to eq(false)
      facility_1.administer_written_test(registrant_2)
      facility_1.administer_road_test(registrant_2)
      expect(registrant_2.license_data[:license]).to eq(true)
    end
  end

  describe '#renew_drivers_license' do
    it 'can renew drivers license if service available' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      facility_1.add_service('Renew License')
      facility_1.administer_written_test(registrant_1)
      facility_1.administer_road_test(registrant_1)

      expect(registrant_1.license_data[:renewed]).to eq(false)
      facility_1.renew_drivers_license(registrant_1)
      expect(registrant_1.license_data[:renewed]).to eq(true)
    end
  end
end
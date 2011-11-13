require 'spec_helper'
require 'unified2'

describe Event do

  before(:all) do
    @event = Unified2.first('example/seeds/unified2-current.log')
  end

  it "should have an event_id" do
    @event.id.should == 1
  end

  it "should have an event time" do
    @event.timestamp.to_s.should == '2011-11-12 16:04:25 -0500'
  end

  it "should have a sensor id" do
    @event.sensor.id.should == 50000000000
  end
  
  it "should have a sensor name" do
    @event.sensor.name.should == "Example Sensor"
  end
  
  it "should have a sensor interface" do
    @event.sensor.interface.should == "en1"
  end
  
  it "should have a sensor hostname" do
    @event.sensor.hostname.should == "W0ots.local"
  end

  it "should have a source address" do
    @event.source_ip.should == "10.0.1.6"
  end

  it "should have a source port" do
    @event.source_port.should == 52378
  end

  it "should have a destination address" do
    @event.destination_ip.should == "199.47.216.149"
  end

  it "should have a destination port" do
    @event.destination_port.should == 80
  end
  
  it "should have a protocol" do
    @event.protocol.to_s.should == 'TCP'
  end
  
  it "should have a severity" do
    @event.severity.should == 1
  end

  it "should have an event checksum" do
    @event.checksum.should == "01af8a5245fce250989b00990406fa63"
  end

  it "should have a signature id" do
    @event.signature.id.should == 18608
  end

  it "should have a signature generator id" do
    @event.signature.generator.should == 1
  end

  it "should have a signature revision" do
    @event.signature.revision.should == 3
  end

  it "should have a signature thats not blank" do
    @event.signature.blank.should == false
  end

  it "should have a signature name" do
    @event.signature.name.should == "POLICY Dropbox desktop software in use"
  end

  it "should have a classification id" do
    @event.classification.id.should == 33
  end

  it "should have a classification short name" do
    @event.classification.short.should == "policy-violation"
  end

  it "should have a classification severity" do
    @event.classification.severity.should == 1
  end

  it "should have a classification name" do
    @event.classification.name.should == "Potential Corporate Privacy Violation"
  end

  it "should have zero packets associated with this event" do
    @event.packets.count.should == 0
  end

  it "event extras count should equal 2" do
    @event.extras.count.should == 2
  end

  it "should have extra data thats not blank" do
    @event.extras.first.blank?.should == false
  end
  
  it "extra data should have the correct value" do
    @event.extras.first.value.should == "/subscribe?host_int=26273724&ns_map=2895792_52721831662858160,15287777_4310255073,2027874_776915740822270306,2816020_68722292756,564088_4146784271384222584,555213_5414107641578813645&ts=1321131865"
    @event.extras.last.value.should == "notify9.dropbox.com"
  end

  it "extra data should have a value length" do
    @event.extras.first.length.should == 204
  end

  it "extra data should have a header" do
    @event.extras.first.header[:event_type].should == 4
    @event.extras.first.header[:event_length].should == 228
  end

end


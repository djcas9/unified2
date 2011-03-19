require 'spec_helper'
require 'unified2'

describe Event do

  before(:all) do
    @event = Unified2.first('example/seeds/unified2.log')
  end

  it "should have an event_id" do
    @event.to_i.should == 1
  end

  it "should have an event time" do
    @event.timestamp.to_s.should == '2010-10-05 22:50:18 -0400'
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
    @event.source_ip.should == "24.19.7.110"
  end

  it "should have a source port" do
    @event.source_port.should == 0
  end

  it "should have a destination address" do
    @event.destination_ip.should == "10.0.1.6"
  end

  it "should have a destination port" do
    @event.destination_port.should == 0
  end
  
  it "should have a protocol" do
    @event.protocol.to_s.should == 'ICMP'
  end
  
  it "should have a severity" do
    @event.severity.should == 3
  end

  it "should have an event checksum" do
    @event.checksum.should == "6e96db6e8fe649c939711400ea4625eb"
  end

  it "should have a signature id" do
    @event.signature.id.should == 485
  end

  it "should have a signature generator id" do
    @event.signature.generator.should == 1
  end

  it "should have a signature revision" do
    @event.signature.revision.should == 5
  end

  it "should have a signature thats not blank" do
    @event.signature.blank.should == false
  end

  it "should have a signature name" do
    @event.signature.name.should == "DELETED ICMP Destination Unreachable" \
      " Communication Administratively Prohibited"
  end

  it "should have a classification id" do
    @event.classification.id.should == 29
  end

  it "should have a classification short name" do
    @event.classification.short.should == "misc-activity"
  end

  it "should have a classification severity" do
    @event.classification.severity.should == 3
  end

  it "should have a classification name" do
    @event.classification.name.should == "Misc activity"
  end
  
  it "should have a payload thats not blank" do
    @event.payload.blank?.should == false
  end
  
  it "should have a hex payload" do
    p = "000000004520008323bc000032113a080a0001061813076e90c84fac006fe498"
    @event.payload.hex.should == p
  end
  
  it "should have a payload length" do
    @event.payload.length.should == 70
  end

end

require 'spec_helper'
require 'unified2'

describe Event do

  before(:all) do
    @event = Unified2.first('example/seeds/unified2.log')
  end

  it "should have an event_id" do
    @event.to_i.should == 1
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
    @event.checksum.should == "eae6d33ed0ce052e9eb92afd11fd71aa"
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

end

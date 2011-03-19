require 'spec_helper'
require 'unified2'

describe Event do

  before(:all) do
    @event = Unified2.first('example/seeds/unified2.log')
  end

  it "should have an event_id" do
    @event.to_i.should == 1
  end

  it "should have an event checksum" do
    @event.checksum.should == "eae6d33ed0ce052e9eb92afd11fd71aa"
  end

  it "should have a signature name" do
    @event.signature.name.should == "DELETED ICMP Destination Unreachable Communication Administratively Prohibited"
  end

end

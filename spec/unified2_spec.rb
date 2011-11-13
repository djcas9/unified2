require 'spec_helper'
require 'unified2'

describe Unified2 do

  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
  
  it "should have a TYPES constant" do
    subject.const_get('TYPES').should_not be_empty
  end
  
  it "should have the correct signature size" do
    Unified2.signatures.size.should == 19243
  end
  
  it "should have the correct signature name" do
    signature_name = "EXPLOIT Oracle BEA Weblogic server " \
    "console-help.portal cross-site scripting attempt"
    
    Unified2.signatures.data['16710'][:name].should == signature_name
  end
  
  it "should have the correct signature id" do
    Unified2.signatures.data['16710'][:signature_id].should == 16710
  end
  
  it "should have the correct signature generator id" do
    Unified2.signatures.data['16710'][:generator_id].should == 1
  end
  
  it "should have the correct classification size" do
    Unified2.classifications.size.should == 35
  end
  
  it "should have the correct classification id" do
    Unified2.classifications.data['35'][:severity_id].should == 2
  end
  
  it "should have the correct classification name" do
    classification_name = "Sensitive Data was Transmitted Across the Network"
    Unified2.classifications.data['35'][:name].should == classification_name
  end
  
  it "should have the correct classification short name" do
    Unified2.classifications.data['35'][:short].should == "sdf"
  end
  
  it "should have the correct generator size" do
    Unified2.generators.size.should == 461
  end
  
  it "should have the correct generator id" do
    Unified2.generators.data["138.6"][:generator_id].should == 138
  end
  
  it "should have the correct generator name" do
    generator_name = "sensitive_data: sensitive data - U.S. phone numbers"
    Unified2.generators.data["138.6"][:name].should == generator_name
  end
  
  it "should have the correct generator signature id" do
    Unified2.generators.data["138.6"][:signature_id].should == 6
  end
  
  it "should have a sensor name" do
    Unified2.sensor.name.should == "Example Sensor"
  end
  
  it "should have a sensor interface" do
    Unified2.sensor.interface.should == 'en1'
  end
  
  it "should have a sensor hostname" do
    Unified2.sensor.hostname.should == 'W0ots.local'
  end
  
  it "should have a new sensor hostname if set" do
    Unified2.sensor.hostname = 'OMG.stuff.local'
    Unified2.sensor.hostname.should == 'OMG.stuff.local'
  end
  
  it "should have a new sensor interface if set" do
    Unified2.sensor.interface = 'eth1'
    Unified2.sensor.interface.should == 'eth1'
  end
  
  it "should have a new sensor name if set" do
    Unified2.sensor.name = 'Mephux FTW!'
    Unified2.sensor.name.should == "Mephux FTW!"
  end
  
end

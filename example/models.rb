class Event
  include DataMapper::Resource
  storage_names[:default] = "events"
  
  timestamps :created_at, :updated_at

  property :id, Serial, :index => true
  
  property :checksum, String, :index => true
  
  property :event_id, Integer, :index => true
  
  property :sensor_id, Integer, :index => true
  
  property :source_ip, String, :index => true
  
  property :source_port, Integer
  
  property :destination_ip, String, :index => true
  
  property :destination_port, Integer
  
  property :severity_id, Integer, :index => true
  
  property :classification_id, Integer, :index => true
  
  property :category_id, Integer, :index => true
  
  property :user_id, Integer, :index => true
  
  property :protocol, String, :index => true

  property :link_type, Integer
  
  property :packet_length, Integer
  
  property :packet, Text
  
  belongs_to :sensor
  
  belongs_to :classification
  
  belongs_to :signature
  
  validates_uniqueness_of :uid
  
  def update_sensor
    sensor.update(:last_event_id => self.event_id)
    sensor.save
  end
  
end

class Sensor
  include DataMapper::Resource
  timestamps :created_at, :updated_at
  
  property :id, Serial, :index => true
  
  property :hostname, Text, :index => true
  
  property :interface, String
  
  property :name, String, :index => true
  
  property :last_event_id, Integer, :index => true
  
  property :signatures_md5, String, :length => 32, :index => true
  
  property :generators_md5, String, :length => 32, :index => true
  
  property :classifications_md5, String, :length => 32, :index => true
  
  has n, :events
  
  validates_uniqueness_of :hostname, :name
  
  def events_count
    last_event_id
  end
  
  def self.find(object)
    name = object.name ? object.name : object.hostname
    
    sensor = first_or_create({:hostname => object.hostname, :interface => object.interface}, {
      :hostname => object.hostname, 
      :interface => object.interface,
      :name => name,
    })    
    
    sensor
  end
  
end

class Signature
  include DataMapper::Resource
  storage_names[:default] = "signatures"
  
  timestamps :created_at, :updated_at
  
  property :id, Serial, :index => true
  
  property :signature_id, Integer, :index => true
  
  property :generator_id, Integer, :index => true
  
  property :name, Text
  
  has n, :events
  
  validates_uniqueness_of :name
  
  def self.import(options={})
    
    if options.has_key?(:signatures)
      
      options[:signatures].each do |key, value|
        signature = Signature.get(:signature_id => key)
        next if signature && options[:force]
        
        if signature
          signature.update(value)
        else
          value.merge!(:signature_id => key, :generator_id => 1)
          Signature.create(value)
        end
        
      end
      
    end
    
    if options.has_key?(:generators)
      
      options[:generators].each do |key, value|
        genid, sid = key.split('.')
        signature = Signature.get(:signature_id => sid, :generator_id => genid)
        next if signature && options[:force]
        
        if signature
          signature.update(value)
        else
          value.merge!(:signature_id => sid, :generator_id => genid)
          Signature.create(value)
        end
        
      end
      
    end
    
  end
end

class Classification
  include DataMapper::Resource
  
  storage_names[:default] = "classifications"
  
  timestamps :created_at, :updated_at
  
  property :id, Serial, :index => true
  
  property :classification_id, Integer, :index => true
  
  property :name, Text
  
  property :short, String
  
  property :severity_id, Integer, :index => true

  has n, :events

  # belongs_to :severity

  validates_uniqueness_of :name, :classification_id

  def self.import(options={})
    
    if options.has_key?(:classifications)
      
      options[:classifications].each do |key,value|
        classification = Classification.get(:classification_id => key)
        next if classification && options[:force]
        
        if classification
          classification.update(value)
        else
          value.merge!(:classification_id => key)
          Classification.create(value)
        end
      end
      
    end
  end
  
end
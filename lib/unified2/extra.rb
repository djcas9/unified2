#
# Unified2
#
module Unified2

  #
  # Extra
  #
  class Extra

    # Type 1: True-Client-IP/XFF IPv4 address
    # Type 2: True-Client-IP/XFF IPv6 address
    # Type 3: ???
    # Type 4: HTTP Gzip decompressed data
    # Type 5: SMTP filename
    # Type 6: SMTP MAIL FROM addresses
    # Type 7: SMTP RCPT TO addresses
    # Type 8: SMTP Email headers
    # Type 9: HTTP Request URI
    # Type 10: HTTP Request Hostname
    # Type 11: Packet's IPv6 Source IP Address
    # Type 12: Packet's IPv6 Destination IP Address
    EXTRA_TYPES = {
      1 => [
        "EVENT_INFO_XFF_IPV4", 
        "True-Client-IP/XFF IPv4 address"
      ],
      2 => [
        "EVENT_INFO_XFF_IPV6", 
        "True-Client-IP/XFF IPv6 address"
      ],
      3 => [
        "EVENT_INFO_REVIEWED_BY", 
        "EVENT_INFO_REVIEWED_BY"
      ],
      4 => [
        "EVENT_INFO_GZIP_DATA", 
        "HTTP Gzip decompressed data"
      ],
      5 => [
        "EVENT_INFO_SMTP_FILENAME", 
        "SMTP filename"
      ],
      6 => [
        "EVENT_INFO_SMTP_MAILFROM", 
        "SMTP MAIL FROM addresses"
      ],
      7 => [
        "EVENT_INFO_SMTP_RCPTTO", 
        "SMTP RCPT TO addresses"
      ],
      8 => [
        "EVENT_INFO_SMTP_EMAIL_HDRS", 
        "SMTP Email headers"
      ],
      9 => [
        "EVENT_INFO_HTTP_URI", 
        "HTTP Request URI"
      ],
      10 => [
        "EVENT_INFO_HTTP_HOSTNAME", 
        "HTTP Request Hostname"
      ],
      11 => [
        "EVENT_INFO_IPV6_SRC", 
        "Packet's IPv6 Source IP Address"
      ],
      12 => [
        "EVENT_INFO_IPV6_DS", 
        "Packet's IPv6 Destination IP Addres"
      ]
    }

    #
    # Build methods defaults
    #
    attr_reader :extra, :header, :type_id, 
      :data_type, :value, :length, :timestamp, :data

    #
    # Initialize Extra object
    # 
    # @param [Hash] data Extra data hash
    # 
    def initialize(data)
      extra = data[:data]
      @header = extra[:header]
      @data = extra[:data]

      @timestamp = Time.at(@data[:event_second].to_i)
      @value = @data[:blob].to_s
      @length = @data[:blob_length].to_i
      @type_id = @data[:extra_type].to_i
      @data_type = @data[:data_type].to_i
      @type = EXTRA_TYPES[@type_id.to_i]
    end

    #
    # Blank?
    #
    # @return [true, false] Check is extra value is blank
    #
    def blank?
      return true unless @value
      false
    end

    #
    # Description
    #
    # @return [String] Extra data description
    #
    def description
      @type.last
    end

    #
    # Name
    #
    # @return [String] Extra data name
    #
    def name
      @type.first
    end

    def to_h
     to_h = {
      :value => value,
      :header => header,
      :length => length,
      :name => name,
      :description => description,
      :timestamp => timestamp,
      :type_id => type_id,
      :data_type => data_type
     }
    end

  end
end


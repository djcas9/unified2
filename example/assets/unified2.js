function escape(data) {
  return new Handlebars.SafeString(data).string;
}

jQuery(document).ready(function($) {
  
  ws = new WebSocket("ws://localhost:8080/");
  var tcp = 0,
      udp = 0,
      icmp = 0,
      eventCount = 0;
  
  var high = 0,
      medium = 0,
      low = 0;
  
  document.title = 'Event Count: ' + eventCount;
  
  ws.onmessage = function(evt) { 
    
    var data = JSON.parse(evt.data);

    update_counts(data.counts);
    process(data)
  };

  ws.onclose = function() { console.log("socket closed"); };

  function update_counts (data) {
    tcp = data.tcp;
    udp = data.udp;
    icmp = data.icmp;
    eventCount = data.events;
    
    high = data.high;
    medium = data.medium;
    low = data.low;
    
    $('span#icmp-count').html(icmp);
    $('span#tcp-count').html(tcp);
    $('span#udp-count').html(udp);
    $('span#event-count').html(eventCount);
    
    $('span#high-count').html(high);
    $('span#medium-count').html(medium);
    $('span#low-count').html(low);
    
    document.title = 'Event Count: ' + eventCount;
  }
  
  function process (event) {
    update_signatures(event.signatures);
    update_classifications(event.classifications);
    
    update_sources(event.sources, event.source_ports);
    update_destinations(event.destinations, event.destination_ports);
    
    if (event.event) { 
      $('pre#event').html(escape(event.event)); 
    };
    
  };
  
  function update_signatures(signatures) {
    $('span#signatures').html(escape(signatures.join(', ')));
  };
  
  function update_classifications(classifications) {
    $('span#classifications').html(escape(classifications.join(', ')));
  };
  
  function update_sources(sources, ports) {
    $('span#sources').html(escape(sources.join(', ')));
    $('span#source-ports').html(escape(ports.join(', ')));
  };
  
  function update_destinations(destinations, ports) {
    $('span#destinations').html(escape(destinations.join(', ')));
    $('span#destination-ports').html(escape(ports.join(', ')));
  };

});

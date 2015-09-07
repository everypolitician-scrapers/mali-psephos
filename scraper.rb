#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

require 'colorize'
require 'pry'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

@source = 'http://psephos.adam-carr.net/countries/m/mali/mali20131.txt'

text = open(@source).read.force_encoding('iso-8859-1').encode('utf-8')
paras = text.split("\r\n\r\n")

paras.select { |p| p =~ /^Deputies elected/ }.each do |result|
  area = result[/^(.*?) \(\d+ seat/, 1]
  sections = result.split(/-------+/)
  elected = sections[ 1 + sections.find_index { |s| s.include? 'Deputies elected' } ].split("\r\n").reject(&:empty?)

  elected.each do |who|
    if found = who.match(/^(.*)\s+\((.*)\)\s*$/)
      name, party = found.captures
    else
      name, party = who, "Unknown"
    end
    data = { 
      name: name.tidy,
      party: party.tidy,
      area: area.tidy,
      term: '2014',
      source: @source,
    }
    ScraperWiki.save_sqlite([:name, :party, :area], data)
  end
end


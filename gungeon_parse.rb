#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'json'

ITEMS_URI = 'https://enterthegungeon.gamepedia.com/Items'.freeze
GUNS_URI = 'https://enterthegungeon.gamepedia.com/Guns'.freeze

#items_doc = Nokogiri::HTML(URI.parse(ITEMS_URI).open)
guns_doc = Nokogiri::HTML(URI.parse(GUNS_URI).open)

images = []
names = []
types = []
quotes = []
qualities = []
page_links = []

quality_hash = {
  S: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/8/8b/1S_Quality_Item.png?version=40a22e5d15d51edf8172d87fc8288f9f',
  A: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/9/9c/A_Quality_Item.png?version=24c0812d903d9ffb91704eb9ec8c4e5b',
  B: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/f/f3/B_Quality_Item.png?version=99613a5f83c53195e09b42773b351676',
  C: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/b/bd/C_Quality_Item.png?version=3f82a0b3849e9989060cbd03062b8780',
  D: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/6/60/D_Quality_Item.png?version=484e9441ad7b8bba2da4079c5984bf99',
  N: 'https://gamepedia.cursecdn.com/enterthegungeon_gamepedia/b/bf/N_Quality_Item.png?version=d62d33ff747269340a2786d0bc707fb9'
}

guns_doc.search('wikitable searchable', 'tr').each_with_index do |row, ind|
  #puts "#{ind} –> #{row.text.strip}"
  row.search('td').each_with_index do |cell, index|
    case index
    when 0
      images << cell.search('img').first['src']
    when 1
      names << cell.text.strip
      page_links << cell.search('a').first['href']
    when 2
      quotes << cell.text.strip
    when 4
      types << cell.text.strip
    when 3
      alt = cell.search('img').first['alt']
      if alt == 'N/A'
        qualities << :N
      else
        qualities << alt[0].to_sym
      end
    else
      puts cell.text.strip
    end
  end
end

guns_array = []

names.each_with_index do |gun, index|
  guns_array << {
    name: gun.to_sym,
    image: images[index],
    type: types[index],
    quote: quotes[index],
    quality: qualities[index],
    link: page_links[index]
  }
end

File.open('guns-data.json', 'w') do |f|
  f.write(guns_array.to_json)
end

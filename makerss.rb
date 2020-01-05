# frozen_string_literal: true

require 'time'
require 'rss'
require 'yaml'

yaml =
  File.open(ARGV[0], 'r') { |file| YAML.safe_load(file) }

def main(yaml)
  makers = {}
  yaml['channels'].each do |channel|
    maker = RSS::Maker['2.0'].new
    maker.channel.title = channel['title']
    maker.channel.link = ENV['URL']
    maker.channel.description = channel['title']
    maker.items.do_sort = true
    makers[channel['prefix']] = maker
  end

  Dir.entries(yaml['common']['mp3dir']).each do |file|
    next unless file =~ /\.mp3$|\.m4a$/

    next unless file =~ /^(\w+?)-(\d+?)-(\d+?)-(\d+?)-(\d+?)-(\d+?)\./

    prefix = Regexp.last_match(1)
    year = Regexp.last_match(2).to_i
    month = Regexp.last_match(3).to_i
    day = Regexp.last_match(4).to_i
    hour = Regexp.last_match(5).to_i
    min = Regexp.last_match(6).to_i

    fullpath = File.join(yaml['common']['mp3dir'], file)
    maker = makers[prefix]
    next unless maker

    item = maker.items.new_item
    url = File.join(yaml['common']['base_url'], File.basename(file))
    case file
    when /\.mp3$/
      mime = 'audio/mp3'
    when /\.m4a$/
      mime = 'audio/mp4a-latm'
    end
    item.title = File.basename(file, '.*').sub(/^[^_]+_/, '')
    item.enclosure.url = url
    item.enclosure.length = File.size(fullpath)
    item.enclosure.type = mime
    item.guid.isPermaLink = true
    item.guid.content = url
    item.date = Time.mktime(year, month, day, hour, min)
  end

  makers.each do |prefix, maker|
    filename = prefix + '.rss'
    puts 'creating..' + filename
    File.open(File.join(yaml['common']['rssdir'], filename), 'w') do |file|
      file.puts maker.to_feed
    end
  end
end

main(yaml)

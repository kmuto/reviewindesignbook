#!/usr/bin/env ruby
require_relative 'libinstructions/libinstructions-html'

class HTMLFilter
  def convert(io)
    doc = Document.new(io).root
    doc.context[:attribute_quote] = :quote
    doc.each_element('//td|//th') do |e|
      set_cell_attributes(e)
      attrs =
        e.attributes['class'] ? e.attributes['class'].split(' ') : []
      ['align', 'celltype'].each do |attr|
        if e.attributes[attr]
          attrs.push(e.attributes[attr])
          e.attributes.delete(attr)
        end
      end
      e.attributes['class'] = attrs.join(' ') unless attrs.empty?
      e.remove if e.size == 0
    end
    doc
  end
end

Dir.glob("#{ARGV[0]}/*.xhtml") do |d|
  File.open(d, 'r+') do |f|
    body = HTMLFilter.new.convert(f.read)
    f.rewind
    f.puts <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
EOT
    f.print body
    f.truncate(f.tell)
  end
end

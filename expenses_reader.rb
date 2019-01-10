if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'rexml/document'
require 'date'

file_name = File.dirname(__FILE__) + '/my_expenses.xml'

unless File.exist?(file_name)
  abort "File #{file_name} is not found."
end

file = File.new(file_name, 'r')

doc = REXML::Document.new(file)

file.close

amount_by_day = {}

doc.elements.each('expenses/expense') do |item|

  loss_sum = item.attributes['amount'].to_i

  loss_date = Date.parse(item.attributes['date'])

  amount_by_day[loss_date] ||= 0

  amount_by_day[loss_date] += loss_sum
end

sum_by_month = {}

amount_by_day.keys.sort.each do |key|
  sum_by_month[key.strftime('%B %Y')] ||= 0

  sum_by_month[key.strftime('%B %Y')] += amount_by_day[key]
end

current_month = amount_by_day.keys.sort[0].strftime('%B %Y')

puts "------[ #{current_month}, total spent: #{sum_by_month[current_month]} $. ]--------"

amount_by_day.keys.sort.each do |key|
  if key.strftime('%B %Y') != current_month

    current_month = key.strftime('%B %Y')

    puts "------[ #{current_month}, total spent: #{sum_by_month[current_month]} $. ]--------"
  end

  puts "\t#{key.day}: #{amount_by_day[key]} $."
end
p amount_by_day
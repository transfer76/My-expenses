if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'rexml/document'
require 'date'

puts 'What did you spend money on?'
expense_text = STDIN.gets.chomp

puts 'How much spent?'
expense_amount = STDIN.gets.to_i

puts 'Specify the date of spending in the format DD.MM.YYYY, for example 12.05.2003 (empty field - today)'
date_input = STDIN.gets.chomp

if date_input == ''
  expense_date = Date.today
else
  begin
    expense_date = Date.parse(date_input)
  rescue ArgumentError
    expense_date = Date.today
  end
end

puts 'what category to write spending'
expense_category = STDIN.gets.chomp

current_path = File.dirname(__FILE__)
file_name = current_path + '/my_expenses.xml'

file = File.new(file_name, 'r:UTF-8')

doc = nil

begin
  doc = REXML::Document.new(file)
rescue REXML::ParseException => error
  puts 'XML file is not correct :('
  abort error.message
end

file.close

expenses = doc.elements.find('expenses').first

expense = expenses.add_element 'expense', {
  'amount' => expense_amount,
  'category' => expense_category,
  'date' => expense_date.strftime('%Y.%m.%d')
}
expense.text = expense_text

file = File.new(file_name, 'w:UTF-8')
doc.write(file, 2)
file.close

puts 'Information saved successfully'

require 'csv'
require 'google/apis/civicinfo_v2'
require 'pry-byebug'
require 'erb'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin 
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue 
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def clean_phone_number(phone)
  phone_number = phone.gsub(/\D/, '')

  if phone_number.length==10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == "1"
    phone_number[1..10]
  else
    "Wrong Number!!"
  end
end

def get_reg_time(regtime)
  time = regtime.split(' ')[1]
end

def get_reg_date(regdate)
  date = regdate.split(' ')[0]
  time = Date.strptime(date, "%m/%d/%y")
end

def save_thank_you_leter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end



template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees_full.csv',
  headers: true,
  header_converters: :symbol
)

reg_times = []
reg_dates = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  # zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # phone_numbers = clean_phone_number(row[:homephone])

  # save_thank_you_leter(id, form_letter)

  reg_times << get_reg_time(row[:regdate])
  reg_dates << get_reg_date(row[:regdate])
end

y = reg_times.reduce(Hash.new(0)) do |result, time|
  result[time] += 1
  result
end

z = reg_dates.reduce(Hash.new(0)) do |result, date|
  result[Date::DAYNAMES[date.wday]] += 1
  result
end

puts y.sort_by {|_key, value| value}
puts z.sort_by {|_key, value| value}
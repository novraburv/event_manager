# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

puts 'Event Manager Initialized!'

def clean_zipcode(zipcode)
  # coerce to be a string
  # right justified if length < 5
  # slice first 5 chars if length > 5
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)

def generate_letters(attendees_list, template)
  attendees_list.each do |attendee|
    id = attendee[0]
    name = attendee[:first_name]
    zipcode = clean_zipcode(attendee[:zipcode])
    legislators = legislators_by_zipcode(zipcode)

    form_letter = template.result(binding)

    save_thank_you_letter(id, form_letter)
  end
end
# generate_letters(contents, erb_template)

# ASSIGNMENT - Clean phone number
def validate_phone(number)
  if number.length < 10 || number.length > 11 || (number.length == 11 && number[0] != '1')
    'bad'
  elsif number.length == 11 && number[0] == '1'
    number[1..]
  else
    number
  end
end

def clean_phone_list(phone_list)
  phone_list.each do |item|
    phone = item[:homephone].scan(/\d+/).join('')
    puts "#{phone} -- #{validate_phone(phone)} -- first digit: #{phone[0]}, length: #{phone.length}"
  end
end
# clean_phone_list(contents)

# ASSIGNMENT - Time Targetting
def target_time(time_list)
  freq = {}
  time_list.each do |attendee|
    reg_date = attendee[:regdate]
    hour = Time.strptime(reg_date, '%m/%d/%y %H:%M').strftime('%H')
    freq[hour] = 0 if freq[hour].nil?
    freq[hour] += 1
  end
  freq.select { |k, v| v == freq.values.max }.keys[0]
end
puts target_time(contents)

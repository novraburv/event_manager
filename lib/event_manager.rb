# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

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

def validate_phone(number)
  if number.length < 10 || number.length > 11 || (number.length == 11 && number[0] != '1')
    'bad'
  elsif number.length == 11 && number[0] == '1'
    number[1..]
  else
    number
  end
end

contents = CSV.open('event_attendees_full.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)

contents.each do |attendee|
  id = attendee[0]
  name = attendee[:first_name]
  zipcode = clean_zipcode(attendee[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)

  # ASSIGNMENT - Clean phone number
  phone = attendee[:homephone].scan(/\d+/).join('')
  puts "#{phone} -- #{validate_phone(phone)} -- first digit: #{phone[0]}, length: #{phone.length}"
end

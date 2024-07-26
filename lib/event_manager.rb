# frozen_string_literal: true

require 'google/apis/civicinfo_v2'
require 'date'

puts 'Event Manager Initialized!'

def clean_zipcode(zipcode)
  # coerce to be a string
  # right justified if length < 5
  # slice first 5 chars if length > 5
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode) # rubocop:disable Metrics/MethodLength
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

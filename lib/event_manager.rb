# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'

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
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators.officials.map(&:name).join(', ')
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

contents.each do |attendee|
  name = attendee[:first_name]
  zipcode = clean_zipcode(attendee[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  puts "#{name} - #{zipcode} - #{legislators}"
end

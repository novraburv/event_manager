# frozen_string_literal: true

require_relative 'lib/event_manager'
require_relative 'lib/phone_number'
require 'csv'
require 'erb'

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)

generate_letters(contents, erb_template)
clean_phone_list(contents)
target_time(contents)

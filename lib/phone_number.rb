# frozen_string_literal: true

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
  phone_list.map do |item|
    n = item[:homephone].scan(/\d+/).join('')
    validate_phone(n)
  end
end

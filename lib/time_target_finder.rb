# frozen_string_literal: true

# ASSIGNMENT - Time Targetting
def key_selection(input, mode)
  if mode == 'hour'
    input.strftime('%H')
  elsif mode == 'wday'
    input.wday
  end
end

def target_time(time_list, mode)
  freq = {}
  time_list.each do |attendee|
    time = Time.strptime(attendee[:regdate], '%m/%d/%y %H:%M')
    key = key_selection(time, mode)
    freq[key] = 0 if freq[key].nil?
    freq[key] += 1
  end
  freq.select { |_k, v| v == freq.values.max }.keys[0]
end

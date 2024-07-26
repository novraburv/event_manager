# frozen_string_literal: true

# ASSIGNMENT - Time Targetting
def target_time(time_list)
  freq = {}
  time_list.each do |attendee|
    hour = Time.strptime(attendee[:regdate], '%m/%d/%y %H:%M').strftime('%H')
    freq[hour] = 0 if freq[hour].nil?
    freq[hour] += 1
  end
  freq.select { |_k, v| v == freq.values.max }.keys[0]
end

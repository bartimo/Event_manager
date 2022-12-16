require 'csv'
require 'google/apis/civicinfo_v2'
require 'pry-byebug'
require 'erb'
require './lib/civics_api'
require './lib/event_signup'

def cleanup_zipcode(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

def cleanup_phone(phone)
  phone = phone[1..phone.length] if phone[0] == '1'
  phone = phone.delete('^0-9')
  phone.length == 10 ? phone : 'Invalid phone number'
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

attendees = CSV.read(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

erb_template = ERB.new File.read('form_letter.erb')
civics = Civics_API.new('AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw')
event_signup = Event_Signup.new()

attendees.each_with_index do |row, index|
  id = index
  first_name = row[:first_name]
  last_name = row[:last_name]
  zipcode = cleanup_zipcode(row[:zipcode])
  phone = cleanup_phone(row[:homephone])
  event_signup.append_time(DateTime.strptime(row[:regdate], '%m/%d/%Y %H: %M'))
  #legislators = civics.representative_info_by_address(zipcode)
  #legislator_info = civics.build_legislator_array(legislators) unless legislators.nil?
  #form_letter = erb_template.result(binding)
  #save_thank_you_letter(id, form_letter)

end

p event_signup.hours
p event_signup.days_of_week
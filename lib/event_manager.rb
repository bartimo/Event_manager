require 'csv'
require 'google/apis/civicinfo_v2'
require 'pry-byebug'
require 'erb'

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
  legislators = civic_info.representative_info_by_address(
    address: zipcode,
    roles: ['legislatorUpperBody','legislatorLowerBody'],
    levels: 'country')      
  rescue
    nil
  end     
    
end

def check_for_nil(obj,index)
  obj.nil? ? true : obj[index].nil? 
end


def build_legislator_array(legislators)
  unless legislators.nil?
    legislator_array = []
    legislator_hash = {}
    legislators.offices.each do |office|
      office.official_indices.each do |row|
        #p legislators.officials[row].name
        #binding.pry
        legislator_hash = { 'Name' => "#{office.name} #{legislators.officials[row].name}"}
        legislator_hash['Phone 1'] = legislators.officials[row].phones[0] unless check_for_nil(legislators.officials[row].phones, 0)
        legislator_hash['Phone 2'] = legislators.officials[row].phones[1] unless check_for_nil(legislators.officials[row].phones, 1)
        legislator_hash['Website 1'] = legislators.officials[row].urls[0] unless check_for_nil(legislators.officials[row].urls, 0)
        legislator_hash['Website 2'] = legislators.officials[row].urls[1] unless check_for_nil(legislators.officials[row].urls, 1)
      end
      legislator_array.push(legislator_hash)
    end
    legislator_array 
  else
    nil
  end
  
end


def cleanup_zipcode(zip)
  zipcode = zip.to_s.rjust(5, '0')[0..4]
end

def cleanup_phone(phone)
  phone = phone[1..phone.length] if phone[0] == "1"
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


attendees = CSV.read('event_attendees.csv', 
  headers: true,
  header_converters: :symbol)

erb_template = ERB.new File.read('form_letter.erb')

attendees.each_with_index do |row, index|
  id = index
  first_name = row[:first_name]
  last_name = row[:last_name]
  zipcode = cleanup_zipcode(row[:zipcode])
  phone = cleanup_phone(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  legislator_info = build_legislator_array(legislators) unless legislators.nil?
   

  form_letter = erb_template.result(binding)
  #puts form_letter
  save_thank_you_letter(id,form_letter)
end








require 'google/apis/civicinfo_v2'

class Civics_API

  def initialize(key)
    @civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    @civic_info.key = key
  end

  def representative_info_by_address(zipcode)
    begin
      @civic_info.representative_info_by_address(
        address: zipcode,
        roles: ['legislatorUpperBody','legislatorLowerBody'],
        levels: 'country'
      )
    rescue
      nil
    end
  end

  def build_legislator_array(legislators)
    unless legislators.nil?
      legislator_array = []
      legislator_hash = {}
      legislators.offices.each do |office|
        office.official_indices.each do |row|
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

  private

  def check_for_nil(obj,index)
    obj.nil? ? true : obj[index].nil? 
  end

end
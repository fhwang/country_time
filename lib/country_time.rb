# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""
        value_type = :a3
        priority_countries ||= CountryTime.high_priority_countries

        if priority_countries
          priority_country_options = priority_countries.map { |c_value|
            country = CountryTime::Country.send(
              "find_by_#{value_type}", c_value
            )
            [country.name, country.send(value_type)]
          }
          country_options += options_for_select(
            priority_country_options, selected
          )
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        all_countries = CountryTime::Country.all
        sorted_countries = all_countries.sort_by { |country| country.name }
        all_country_options = sorted_countries.map { |country|
          [country.name, country.send(value_type)]
        }
        country_options << options_for_select(
          all_country_options, selected
        )
        country_options
      end
    end
    
    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end
  end
end

module CountryTime
  mattr_accessor :high_priority_countries
  
  class Country
    @@countries_hashes = nil
    
    def self.method_missing(name, *args)
      if match = /find_([^_]*)_by_([^_]*)/.match(name.to_s)
        raise "1 argument expected, #{args.size} provided." unless args.size == 1
        
        required = match[1]
        request  = match[2]
        if valid_attributes.include?(request) && valid_attributes.include?(required)
          countries_hashes[request][args[0].to_s.downcase][required.to_sym] || nil rescue nil
        else
          raise "#{request} is not a valid attribute, valid attributes for find_*_by_* are: #{valid_attributes.join(', ')}."
        end
        
      elsif match = /find_by_(.*)/.match(name.to_s)
        raise "1 argument expected, #{args.size} provided." unless args.size == 1
        
        request = match[1]
        if valid_attributes.include?(request)  
          countries_hashes[request][args[0].to_s.upcase]
        else
          raise "#{request} is not a valid attribute, valid attributes for find_by_* are: #{valid_attributes.join(', ')}."
        end
        
      else
        super
      end
    end
    
    def self.all
      countries_hashes['name'].values
    end
    
    def self.countries_hashes
      load_all unless @@countries_hashes
      @@countries_hashes
    end
    
    def self.valid_attributes
      countries_hashes.keys
    end
    
    def self.load_all
      records = YAML::load(
        File.open("#{File.dirname(__FILE__)}/countries.yml")
      )
      @@countries_hashes ||= Hash.new { |h,k| h[k] = {} }
      records.each do |record|
        country = Country.new(
          record[:name], record[:a2], record[:a3], record[:numeric]
        )
        %w(name a2 a3 numeric).each do |field|
          @@countries_hashes[field][country.send(field)] = country
        end
      end
    end
    
    attr_accessor :name, :a2, :a3, :numeric
    
    def initialize(name, a2, a3, numeric)
      @name, @a2, @a3, @numeric = name, a2, a3, numeric
    end
  end
end
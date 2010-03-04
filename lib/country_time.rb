# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, options = {}, html_options = {})
        InstanceTag.new(
          object, method, self, options.delete(:object)
        ).to_country_select_tag(options, html_options)
      end
      
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(
        selected = nil, priority_countries = nil, skipped_countries = nil
      )
        country_options = ""
        value_type = CountryTime.value_type
        priority_country_options = CountryTime.priority_options_for_select(
          priority_countries, value_type
        )
        if priority_country_options
          country_options += options_for_select(
            priority_country_options, selected
          )
          country_options += "<option value=\"\" disabled=\"disabled\">#{CountryTime.label_text}</option>\n"
        end
        country_options << options_for_select(
          CountryTime.unprioritized_options_for_select(
            value_type, skipped_countries
          ),
          selected
        )
        country_options
      end
    end
    
    class InstanceTag
      def to_country_select_tag(options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        priority_countries = options.delete :priority_countries
        skipped_countries = options.delete :skip
        content_tag("select",
          add_options(
            country_options_for_select(
              value, priority_countries, skipped_countries
            ),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def country_select(method, options = {}, html_options = {})
        @template.country_select(
          @object_name, method, options.merge(:object => @object), html_options
        )
      end
    end
  end
end

module CountryTime
  mattr_accessor :high_priority_countries
  
  mattr_accessor :label_text
  self.label_text = '-------------'
  
  mattr_accessor :value_type
  self.value_type = :a3
  
  @@added = []
  mattr_reader :added
  def self.add(*added)
    @@added.concat added
  end
  
  def self.countries
    @@country_configs ||= Hash.new { |h,k| h[k] = CountryConfig.new(k) }
    @@country_configs
  end
  
  def self.rename_countries(rename_hash)
    rename_hash.each do |code, name|
      self.countries[code].name = name
    end
  end
  
  @@skipped = []
  mattr_reader :skipped
  
  def self.skip(*skipped)
    @@skipped.concat skipped
  end
  
  def self.unprioritized_options_for_select(value_type, skipped_countries = nil)
    all_countries = Country.all
    unskipped = if value_type == :name and !self.added.empty?
      names = all_countries.map &:name
      names.concat self.added
      names.sort.map { |name| [name, name] }
    else
      sorted_countries = all_countries.sort_by { |country| country.name }
      sorted_countries.map { |country|
        [country.name, country.send(value_type)]
      }
    end
    skipped_countries ||= []
    unskipped.reject { |tuple| skipped_countries.include?(tuple.last) }
  end
  
  def self.priority_options_for_select(priority_countries, value_type)
    priority_countries ||= CountryTime.high_priority_countries
    if priority_countries
      priority_countries.map { |c_value|
        country = Country.send("find_by_#{value_type}", c_value)
        [country.name, country.send(value_type)]
      }
    end
  end
  
  class Country
    @@countries_hashes = nil
    
    def self.all
      countries_hashes[:name].values
    end
    
    def self.countries_hashes
      load_all unless @@countries_hashes
      @@countries_hashes
    end
        
    def self.method_missing(name, *args)
      if match = /find_([^_]*)_by_([^_]*)/.match(name.to_s)
        raise "1 argument expected, #{args.size} provided." unless args.size == 1
        required = match[1].to_sym
        request  = match[2].to_sym
        if ATTRIBUTES.include?(request) && ATTRIBUTES.include?(required)
          countries_hashes[request][args[0]].send(required) rescue nil
        else
          raise "#{request} is not a valid attribute, valid attributes for find_*_by_* are: #{ATTRIBUTES.join(', ')}."
        end
        
      elsif match = /find_by_(.*)/.match(name.to_s)
        raise "1 argument expected, #{args.size} provided." unless args.size == 1
        
        request = match[1].to_sym
        if ATTRIBUTES.include?(request)  
          countries_hashes[request][args[0].to_s.upcase]
        else
          raise "#{request} is not a valid attribute, valid attributes for find_by_* are: #{ATTRIBUTES.join(', ')}."
        end
        
      else
        super
      end
    end
    
    def self.load_all
      records = YAML::load(
        File.open("#{File.dirname(__FILE__)}/countries.yml")
      )
      @@countries_hashes ||= Hash.new { |h,k| h[k] = {} }
      records.each do |record|
        name = record[:name]
        a2 = record[:a2]
        a3 = record[:a3]
        unless CountryTime.skipped.include?(a2) or 
               CountryTime.skipped.include?(a3)
          names = [a2, a3, name].map { |lookup|
            CountryTime.countries[lookup].name
          }.compact
          name = names.first unless names.empty?
          country = Country.new name, a2, a3, record[:numeric]
          ATTRIBUTES.each do |field|
            @@countries_hashes[field][country.send(field)] = country
          end
        end
      end
    end
    
    ATTRIBUTES = [:name, :a2, :a3, :numeric]
    
    attr_accessor *ATTRIBUTES
    
    def initialize(name, a2, a3, numeric)
      @name, @a2, @a3, @numeric = name, a2, a3, numeric
    end
  end
  
  class CountryConfig
    attr_accessor :name
    
    def initialize(code)
      @code = code
    end
  end
end
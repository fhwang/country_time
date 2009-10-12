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
        CountryCodes.load_countries_from_yaml
        priority_countries ||= CountryTime.high_priority_countries

        if priority_countries
          priority_country_options = priority_countries.map { |c_value|
            cc = CountryCodes.send("find_by_#{value_type}", c_value)
            [cc[:name], cc[value_type]]
          }
          country_options += options_for_select(
            priority_country_options, selected
          )
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        all_countries =
            CountryCodes.instance_variable_get(:@countries)['name'].values
        sorted_countries = all_countries.sort_by { |country| country[:name] }
        all_country_options = sorted_countries.map { |country|
          [country[:name], country[value_type]]
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
end
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using state_options_for_select to generate the list of option tags.
      def state_select(object, method, country = Carmen.default_country, options={}, html_options={})
        InstanceTag.new(object, method, self, options.delete(:object)).to_state_select_tag(country, options, html_options)
      end

      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end

      # Returns a string of option tags containing the state names and codes for the specified country code, or nil
      # if the states are not know for that country. Supply a state code as +selected+ to have it marked as the selected option tag.
      def state_options_for_select(selected = nil, country = Carmen.default_country)
        options_for_select(Carmen.states(country), selected)
      end

      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply a list of country codes as additional parameters, so
      # that they will be listed above the rest of the (long) list.
      def country_options_for_select(selected = nil, *priority_country_codes)
        country_options = ""
        priority_countries = []
        non_priority_countries = []

        unless priority_country_codes.empty?
          unless Carmen.country_name(priority_country_codes[0])
            priority_country_codes = Carmen.priority_countries
          end
          priority_countries, non_priority_countries = split_coutries_into_priorities_and_non_priorities(priority_country_codes)

          unless priority_countries.empty?
            country_options += options_for_select(priority_countries, selected)
            country_options += "\n<option value=\"\" disabled=\"disabled\">-------------</option>\n"
          end
        end

        return country_options + options_for_select(non_priority_countries, priority_country_codes.include?(selected) ? nil : selected)
      end

      def split_coutries_into_priorities_and_non_priorities(priority_country_codes)
        priority_countries = {}
        non_priority_countries = {}
        Carmen::countries.each do |pair| 
          name, code = pair
          if priority_country_codes.include?(code)
            priority_countries[name] = code 
          else
            non_priority_countries[name] = code 
          end
        end
        [priority_countries.entries, non_priority_countries.entries]
      end
    end

    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        opts = add_options(country_options_for_select(value, *priority_countries), options, value)
        content_tag("select", opts, html_options)
      end

      def to_state_select_tag(country, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        opts = add_options(state_options_for_select(value, country), options, value)
        content_tag("select", opts, html_options)
      end
    end

    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
      def state_select(method, country_code = Carmen.default_country, options = {}, html_options = {})
        @template.state_select(@object_name, method, country_code, options.merge(:object => @object), html_options)
      end
    end
  end
end

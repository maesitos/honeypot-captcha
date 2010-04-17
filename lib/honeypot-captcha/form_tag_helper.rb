# Override the form_tag helper to add honeypot spam protection to forms.
module ActionView
  module Helpers
    module FormTagHelper
      def form_tag_with_honeypot(url_for_options = {}, options = {}, *parameters_for_url, &block)
        honeypot = options.delete(:honeypot)
        html = form_tag_without_honeypot(url_for_options, options, *parameters_for_url, &block)
        if honeypot
          captcha = (Rails.version > "3") ? honey_pot_captcha.html_safe : honey_pot_captcha
          if block_given?
            html.insert(html.index('</form>'), captcha)
          else
            html += captcha
          end
        end
        html
      end
      alias_method_chain :form_tag, :honeypot

    private

      def honey_pot_captcha
        html_ids = []
        honeypot_fields.collect do |f|
          html_ids << (html_id = "#{f}_hp_#{Time.now.to_i}")
          content_tag(:div, send([:text_field_tag, :text_area_tag][rand(2)], f), :id => html_id)
        end.join +
        content_tag(:style, :type => 'text/css', :media => 'screen') do
          "#{html_ids.map { |i| "##{i}" }.join(', ')} { display:none; }"
        end
      end
    end
  end
end
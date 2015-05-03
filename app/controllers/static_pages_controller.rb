class StaticPagesController < ApplicationController
  def about
    @template = case I18n.locale.to_s
  		when 'en' then '/static_pages/about_en.html.erb'
  		when 'fr' then '/static_pages/about_fr.html.erb'
  		else '/static_pages/about_en.html.erb'
  		end
  	render :template => @template
    end

  def help
  end

  def contact
  end
end

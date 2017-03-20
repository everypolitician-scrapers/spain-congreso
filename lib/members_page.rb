# frozen_string_literal: true
require 'scraped'
require_relative 'remove_session_from_url_decorator'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls
  decorator RemoveSessionFromUrlDecorator

  field :member_urls do
    noko.css('div#RESULTADOS_DIPUTADOS div.listado_1 ul li a/@href').map(&:text).uniq
  end

  field :next_page_url do
    next_page_link and next_page_link.text
  end

  private

  def next_page_link
    noko.at_css('//div[@class = "paginacion"]//a[contains("Página Siguiente")]/@href')
  end
end

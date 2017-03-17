# frozen_string_literal: true
require 'scraped'

class MembershipRow < Scraped::HTML
  TERM_IDS = %w(Legislatura I II III IV V VI VII VIII IX X XI XII).freeze

  field :url do
    noko.at_css('.contenedor a/@href').text
  end

  field :legislatura do
    TERM_IDS.index(noko.at_css('.principal').text.split.first)
  end

  field :diputado do
    noko.at_xpath('//div[contains(@class,"TITULO_CONTENIDO_FICHAS")]').text
  end
end

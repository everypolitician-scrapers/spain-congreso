# frozen_string_literal: true

require 'scraped'

class MembershipPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :term do
    query_string['idLegislatura']
  end

  field :name do
    noko.css('div#curriculum div.nombre_dip').text.tidy
  end

  field :family_names do
    name.split(/,/).first.to_s.tidy
  end

  field :given_names do
    name.split(/,/).last.to_s.tidy
  end

  field :gender do
    return 'female' if seat.include? 'Diputada'
    return 'male' if seat.include? 'Diputado'
  end

  field :party do
    noko.at_css('#datos_diputado .nombre_grupo').text.tidy
  end

  field :source do
    url.to_s
  end

  field :faction do
    faction_information[:faction].to_s.tidy
  end

  field :faction_id do
    faction_information[:faction_id].to_s.tidy
  end

  field :start_date do
    start_date = noko.xpath('.//div[@class="dip_rojo"][contains(.,"Fecha alta")]')
                     .text.match(%r{(\d+)/(\d+)/(\d+)\.})
    return if start_date.nil?
    start_date.captures.reverse.join('-')
  end

  field :end_date do
    end_date = noko.xpath('.//div[@class="dip_rojo"][contains(.,"Causó baja")]')
                   .text.match(%r{(\d+)/(\d+)/(\d+)\.})
    return if end_date.nil?
    end_date.captures.reverse.join('-')
  end

  field :email do
    noko.css('.webperso_dip a[href*="mailto"]').text.tidy
  end

  field :twitter do
    noko.css('.webperso_dip a[href*="twitter.com"]/@href').text.tidy
  end

  field :facebook do
    noko.css('.webperso_dip a[href*="facebook.com"]/@href').text.tidy
  end

  field :constituency do
    seat[/Diputad. por (.*)\./, 1]
  end

  field :photo do
    noko.at_css('#datos_diputado img[name="foto"]/@src').text
  end

  private

  def query_string
    URI.decode_www_form(URI.parse(url).query).to_h
  end

  def seat
    seat_and_group.first.text.tidy
  end

  def group
    seat_and_group.last.text.tidy
  end

  def seat_and_group
    noko.xpath('.//div[@id="curriculum"]/div[@class="texto_dip"][1]//div[@class="dip_rojo"]')
  end

  def faction_information
    group.match(/(?<faction>.*?) \((?<faction_id>.*?)\)/) || {}
  end
end

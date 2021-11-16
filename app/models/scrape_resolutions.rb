require 'dry/monads'
require 'dry/monads/do'

class ScrapeResolutions
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def call(url)
    data = yield load(url)
    resolutions = yield save(data)
    Success([url, resolutions])
  end

  def load(url)
    html = HTTP.get(url).to_s
    response = Nokogiri.HTML(html)

    data = []

    response
      .css('.field-items table thead tr')
      .each_with_index do |row, index|
        cols = row.css('td')

        next if cols.none?
        next if index == 0
        next unless cols.last.text == 'EN FIRME'

        pdf_url = cols[3].css('a').first[:href]
        pdf_url = "https://www.sic.gov.co#{pdf_url}" unless pdf_url
          .starts_with?('http')

        data << {
          company: cols[0].text,
          date: Date.parse(cols[1].text),
          overview: cols[2].text,
          pdf_url: pdf_url
        }
      end

    Success(data)
  end

  def save(data)
    resolutions =
      data.map do |row|
        begin
          Resolution.create!(row)
        rescue ActiveRecord::RecordNotUnique
          nil
        end
      end.compact
    Success(resolutions)
  end
end

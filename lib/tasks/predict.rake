namespace :predict do
  desc 'scrape resolutions'
  task scrape: :environment do
    url = 'https://www.sic.gov.co/sanciones-proteccion-datos-personales-2021'
    ScrapeResolutions.new.call(url)
  end

  desc 'extract data'
  task extract: :environment do
    Resolution
      .where(extracted_at: nil)
      .find_each do |resolution|
        ExtractResolution.new.call(resolution)
        puts "Extracted #{resolution.id}"
      end
  end
end

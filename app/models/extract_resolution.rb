require 'dry/monads'
require 'dry/monads/do'
require 'open-uri'

class ExtractResolution
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def call(resolution)
    context, decision = yield load_text(resolution.pdf_url)
    yield save(resolution, context, decision)

    Success([resolution])
  end

  def load_text(pdf_url)
    io = open(pdf_url)

    begin
      reader = PDF::Reader.new(io)
    rescue PDF::Reader::MalformedPDFError
      return Success(['', ''])
    end

    text = ''
    reader.pages.each { |page| text += "\n\n" + page.text }
    paras = text.split("\n\n")

    context = get_context(paras)
    decision = get_decision(paras)

    Success([context, decision])
  end

  def save(resolution, context, decision)
    resolution.context = context
    resolution.decision = decision
    resolution.extracted_at = Time.zone.now
    resolution.save!
    Success(resolution)
  end

  private

  def get_context(paras)
    start = paras.find_index { |para| para.strip.downcase == 'considerando' }
    stop =
      paras.find_index do |para|
        para.strip.downcase.include? 'competencia de la superintendencia'
      end

    return '' if start.nil? || stop.nil?
    return paras[(start + 1)..(stop - 1)].join("\n\n")
  end

  def get_decision(paras)
    start =
      paras.find_index { |para| para.strip.downcase == 'RESUELVE'.downcase }
    stop =
      paras.find_index do |para|
        para.strip.downcase.include? 'NOTIFÍQUESE'.downcase
      end

    return '' if start.nil? || stop.nil?
    return paras[(start + 1)..(stop - 1)].join("\n\n")
  end
end

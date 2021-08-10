require 'csv'

class Parser
  PARSERS = {
    dollar_format: { col_sep: '$', date_format: '%d-%m-%Y' },
    percent_format: { col_sep: '%', date_format: '%Y-%m-%d' }
  }

  def self.parse_people(sources)
    sources.map do |format, content|
      if format =~ /_format/
        parser_settings = PARSERS[format]
        rows = Parser.new(parser_settings).parse(content)
        rows.map { |r| Person.new(r) }
      end
    end.compact.flatten
  end

  def initialize(col_sep:, date_format:)
    @col_sep = col_sep
    @date_format = date_format
  end

  def parse(str)
    # strip: true gives CSV::MalformedCSVError
    # stripping inside the converter
    CSV.parse(str,
      col_sep: col_sep,
      headers: :first_row, header_converters: :symbol,
      converters: [->(v) { s = v.strip; Date.strptime(s, date_format) rescue s }]).map(&:to_h)
  end

  private

  attr_reader :col_sep, :date_format  

end

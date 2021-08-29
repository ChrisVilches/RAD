class TextInput < Input
  self.table_name = 'text_inputs'

  validate :range_valid?
  validate :regex_correct?

  before_validation :set_ranges_to_integer

  def self.configurable_params
    %i[multiline regex min placeholder max required]
  end

  def input_value_errors(value)
    super

    nil_or_empty_string = value.nil? || (value.is_a?(String) && value.strip.blank?)

    errors = []

    return [] if !required && nil_or_empty_string
    errors << 'Required input' if required && nil_or_empty_string

    errors << 'Value should be a string' unless value.is_a?(String)

    value = value.to_s
    value.strip!

    if @regex.is_a?(Regexp)
      errors << "Input format doesn't match the desired format" if @regex.match(value).nil?
    end

    errors << 'Incorrect amount of characters' unless number_between_range(value)

    errors << 'Multiline value is not allowed' if !multiline && TextInput.multiline?(value)

    errors
  end

  def self.multiline?(str)
    !str.match("\n").nil?
  end

  private

  def number_between_range(str)
    raise ArgumentError unless str.is_a?(String)
    n = str.length
    min_valid = min.nil? || (min.is_a?(Integer) && n >= min)
    max_valid = max.nil? || (max.is_a?(Integer) && n <= max)
    min_valid && max_valid
  end

  def set_ranges_to_integer
    self.min = min.to_i unless min.nil?
    self.max = max.to_i unless max.nil?
  end

  def regex_correct?
    @regex = nil
    return if regex.nil?
    return if regex.blank?
    begin
      @regex = Regexp.new(regex)
    rescue
      errors.add(:regex)
    end
  end

  def range_valid?
    min = self.min
    max = self.max

    min_valid = min.nil? || (min.is_a?(Integer) && min >= 0)
    max_valid = max.nil? || (max.is_a?(Integer) && max.positive?)

    errors.add(:min) unless min_valid
    errors.add(:max) unless max_valid

    return unless min_valid && max_valid && !min.nil? && !max.nil?
    return if min <= max
    errors.add(:min)
    errors.add(:max)
  end
end

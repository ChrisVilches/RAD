class TextInput < Input

  self.table_name = "text_inputs"

  validate :range_valid?
  validate :regex_correct?

  before_validation :set_ranges_to_integer

  def self.configurable_params
    [:multiline, :regex, :min, :placeholder, :max, :required]
  end

  def input_value_errors(value)

    super

    nil_or_empty_string = value == nil || (value.is_a?(String) && value.strip.blank?)

    errors = []

    return [] if !self.required && nil_or_empty_string
    errors << "Required input" if self.required && nil_or_empty_string

    errors << "Value should be a string" unless value.is_a?(String)

    value = value.to_s
    value.strip!

    if @regex.is_a?(Regexp)
      errors << "Input format doesn't match the desired format" if @regex.match(value).nil?
    end

    errors << "Incorrect amount of characters" unless number_between_range(value)

    errors << "Multiline value is not allowed" if !self.multiline && TextInput.is_multiline?(value)

    return errors
  end

  def self.is_multiline?(str)
    return !str.match("\n").nil?
  end

  private

  def number_between_range(str)
    raise ArgumentError unless str.is_a?(String)
    n = str.length
    min_valid = self.min.nil? || (self.min.is_a?(Integer) && n >= self.min)
    max_valid = self.max.nil? || (self.max.is_a?(Integer) && n <= self.max)
    return min_valid && max_valid
  end

  def set_ranges_to_integer
    self.min = self.min.to_i unless self.min.nil?
    self.max = self.max.to_i unless self.max.nil?
  end

  def regex_correct?
    @regex = nil
    return if self.regex.nil?
    return if self.regex.blank?
    begin
      @regex = Regexp.new(self.regex)
    rescue => e
      errors.add(:regex)
    end
  end

  def range_valid?
    min = self.min
    max = self.max

    min_valid = min.nil? || (min.is_a?(Integer) && min >= 0)
    max_valid = max.nil? || (max.is_a?(Integer) && max > 0)

    if !min_valid
      errors.add(:min)
    end

    if !max_valid
      errors.add(:max)
    end

    if min_valid && max_valid && !min.nil? && !max.nil?
      unless min <= max
        errors.add(:min)
        errors.add(:max)
      end
    end
  end
end

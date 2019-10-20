class NumericInput < Input

  self.table_name = "numeric_inputs" # If this is not set manually, table name becomes "inputs"

  validate :range_valid?
  validates :number_set, presence: true

  before_validation :preprocess_integer
  before_validation :preprocess_binary
  before_validation :arrange_excluded_values

  enum number_set: { decimal: 0, integer: 1, binary: 2 }

  def validate_input_value(value)

    super

    return true if !self.required && value.nil?
    return false if self.required && value.nil?
    return false unless value.is_a?(Numeric)

    value = value.to_f
    case self.number_set
    when :decimal.to_s
      return false unless number_between_range(value)
      return false if self.excluded_values.include?(value)
    when :integer.to_s
      return false unless number_is_integer(value)
      return false unless number_between_range(value)
      return false if self.excluded_values.include?(value)
    when :binary.to_s
      return false unless [0, 1].include?(value)
    else
      raise "Incorrect type"
    end

    return true
  end

  private

  def number_is_integer(n)
    n.to_i.to_f == n
  end

  def number_between_range(n)
    raise ArgumentError unless n.is_a?(Numeric)
    min_valid = self.min.nil? || (self.min.is_a?(Numeric) && n >= self.min)
    max_valid = self.max.nil? || (self.max.is_a?(Numeric) && n <= self.max)
    return min_valid && max_valid
  end

  def preprocess_integer
    return if self.number_set != :integer.to_s
    self.min = self.min.to_i unless self.min.nil?
    self.max = self.max.to_i unless self.max.nil?
    self.excluded_values.map! { |v| v.to_i }
  end

  def preprocess_binary
    return if self.number_set != :binary.to_s
    self.min = nil
    self.max = nil
    self.excluded_values = []
  end

  def arrange_excluded_values
    # It's necessary first to convert every number to float,
    # so that for example 5.0 and 5 aren't considered different (so that uniq
    # works properly)
    self.excluded_values.map! {|v| v.to_f}
    self.excluded_values.uniq!
    self.excluded_values.sort!
    self.excluded_values.delete nil
  end


  def range_valid?

    min = self.min
    max = self.max

    min_valid = min.nil? || min.is_a?(Numeric)
    max_valid = max.nil? || max.is_a?(Numeric)

    if !min_valid
      errors.add(:min)
    end

    if !max_valid
      errors.add(:max)
    end

    if !min.nil? && !max.nil?
      unless min <= max
        errors.add(:min)
        errors.add(:max)
      end
    end
  end

end

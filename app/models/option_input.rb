class OptionInput < Input

  self.table_name = "option_inputs" # If this is not set manually, table name becomes "inputs"

  validate :options_jsonb_has_correct_structure?
  after_validation :strip_options!

  enum component_type: { pulldown: 0, radio: 1, checkbox: 2 }

  def validate_input_value(value)

    super
    return false unless value.is_a?(Array)

    value.uniq!
    opt_indexes = value.select {|n| n.is_a?(Integer) && n >= 0}
    return false if opt_indexes.length != value.length # The initial input had values other than positive integers

    if opt_indexes.empty?
      return !self.required
    end

    if [OptionInput::component_types[:pulldown], OptionInput::component_types[:radio]].include?(self.component_type)
      return false if opt_indexes.length != 1
    else
      return false if opt_indexes.length > self.options.length
    end

    # If there's an option selected that surpasses the amount of options (wrong index)
    return false unless opt_indexes.select {|n| n >= self.options.length }.empty?

    return true
  end

  private

  def strip_options!
    return unless self.errors.empty?
    array = self.options
    array.each do |elem|
      elem["label"].strip!
      elem["value"].strip! if elem["value"].is_a?(String)
    end
  end

  def options_jsonb_has_correct_structure?
    array = self.options

    all_labels = Set.new
    all_values = Set.new
    correct_count = 0

    if !array.is_a?(Array) || array.empty?
      errors.add(:options)
      return
    end

    array.each do |elem|

      break unless elem.is_a?(Hash)
      break unless elem.keys.length == 2
      break unless elem.keys.include?("value")
      break unless elem.keys.include?("label")

      label_txt = elem["label"]
      label_txt.strip! if label_txt.is_a?(String) # Could be null or not string
      break unless label_txt.is_a?(String) && !label_txt.empty?

      val = elem["value"]
      val.strip! if val.is_a?(String)
      break unless (val.is_a?(String) && !val.empty?) || val.is_a?(Numeric)

      break if all_labels.include?(label_txt)
      break if all_values.include?(val)

      correct_count += 1
      all_labels << label_txt
      all_values << val
    end

    if correct_count != array.length
      errors.add(:options)
    end

  end

end

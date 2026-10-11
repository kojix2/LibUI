module LibUI
  Font = Struct.new(:family, :size, :weight, :italic, :stretch, keyword_init: true) do
    def initialize(family:, size:, weight: 400, italic: 0, stretch: 4)
      family = String(family)
      raise ArgumentError, 'font family contains a NUL byte' if family.include?("\0")

      super(family: family.dup.freeze, size: Float(size),
            weight: Integer(weight), italic: Integer(italic),
            stretch: Integer(stretch))
      freeze
    end
  end
end

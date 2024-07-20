module LibUI
  # base error class
  class Error < StandardError; end

  # LibUI shared library not found error
  class LibraryNotFoundError < Error; end

  # LibUI shared library load error
  class LibraryLoadError < Error; end
end

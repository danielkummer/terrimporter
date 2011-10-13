module Filer

  CSS_PATTERN = /^[a-zA-Z]+/ #only check if a line starts with characters, not comments

  def replace_line!(line, what, with)
    what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)
    LOG.info "Replacing #{what.to_s} with #{with}"
    line.gsub! what, with
  end

  def file_contains_valid_css?(file_path)
    css_valid = false
    File.open(file_path) do |f|
      f.each_line do |line|
        if line =~ CSS_PATTERN
          css_valid = true
          break
        end
      end
    end
    css_valid
  end
end


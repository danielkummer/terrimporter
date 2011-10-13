module Filer

  CSS_PATTERN = /^[a-zA-Z]+/ #only check if a line starts with characters, not comments

  def replace_line!(line, what, with)
    what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)
    LOG.info "Replacing #{what.to_s} with #{with}"
    line.gsub! what, with
  end

  def file_contents_valid?(file_path, content_type)
    case content_type
      when :js
        pattern = CSS_PATTERN
      when :css
        pattern = JS_PATTERN
      else
        return true
    end

    valid = false
    File.open(file_path) do |f|
      f.each_line do |line|
        if line =~ pattern
          valid = true
          break
        end
      end
    end
    valid
  end
end


module ImporterHelper

  def replace_line!(line, what, with)
    what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)
    LOG.info "Replacing #{what.to_s} with #{with}"
    line.gsub! what, with
  end

  def file_contains_valid_css?(file_path)
    File.open(file_path) do |f|
      valid = false
      f.each_line do |line|
        if line.include?(pattern)

        end
      end
    return true
    end
  end

end
module ImporterHelper

  def replace_line!(line, what, with)
    what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)
    LOG.info "Replacing #{what.to_s} with #{with}"
    line.gsub! what, with
  end

end
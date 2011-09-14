module ImporterHelper
  #todo move utility functions here

  def extract_module_and_skin_name(module_name)
    names = []
    if module_name =~ /^(.*)_(.*)/
      names << 'mod_' + $2
      names << module_name if $1 == 'skn'
    end
    names
  end

  def replace_line!(line, what, with)
    what = Regexp.new "#{$1}" if what.match(/^r\/(.*)\//)
    LOG.info "Replacing #{what.to_s} with #{with}"
    line.gsub! what, with
  end

end
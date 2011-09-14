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


end
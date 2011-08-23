require 'kwalify'

class ConfigValidator < Kwalify::Validator
  ## hook method called by Validator#validate()
  def validate_hook(value, rule, path, errors)
    case rule.name
      when 'css'
        #todo split space separated values and check for .css
        if value =~ /\.css/
          msg = "no .css extension allowed, use filename only."
          errors << Kwalify::ValidationError.new(msg, path)
        end
      when 'js'
        if value =~ /\.js/
          msg = "no .js extension allowed, use filename only."
          errors << Kwalify::ValidationError.new(msg, path)
        end
    end
  end

end
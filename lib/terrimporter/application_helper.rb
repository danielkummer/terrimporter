module ApplicationHelper

  def class_name
    banned = ["TERRIMPORTER", "APPLICATION", "INFO"]
    self.name.split('::').remove(banned).join(' ')
  end

end
class String
  
  #
  # Blank?
  # 
  # @return [true, false] If the string
  # is blank or empty return true.
  # 
  def blank?
    return true if (self.nil? || self == '')
    false
  end
  
end # class String
class Integer

  def to_ip
    IPLibrary::IP2integer.int2ip(self)
  end
end

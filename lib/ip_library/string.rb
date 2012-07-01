class String

  def to_int_ip
    IPLibrary::IP2integer.ip2int(self)
  end
end

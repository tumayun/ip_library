module IPLibrary

  module IP2integer

    IP_REGEXP = /^(?:(?:2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(?:2[0-4]\d|25[0-5]|[01]?\d\d?)$/
    IP_PERFIX_REGEXP = /^(?:(?:2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}$/

    class << self

      # Converts an IP string to integer
      def ip2int(ip)
        return 0 unless ip =~ IP_REGEXP
        ip_segments = []
        ip.split('.').each_with_index { |ip_seg, i| ip_segments << (ip_seg.to_i << 8*(3 - i)) }
        ip_segments.inject(0) { |sum, ip_segment|  sum = sum|ip_segment }
      end

      #Converts an INTEGER to IP string
      def int2ip(intip)
        ip_segments = [3, 2, 1, 0].map { |i| (intip & (255 << i*8)) >> i*8 }
        (ip_str= ip_segments.join('.')) =~ IP_REGEXP ? ip_str : ''
      end
    end
  end
end

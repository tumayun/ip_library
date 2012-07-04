#encoding: utf-8
module IPLibrary

  class Configuration
    cattr_accessor :file_path, :optional_columns, :separator, :except_regexp, :instance_writer => false
    cattr_reader   :non_optional_columns, :columns

    @@file_path            = File.join(File.dirname(__FILE__), '..', '..', 'doc', 'ip_libraries.txt') #"#{File.dirname(__FILE__)}/../../doc/ip_libraries.txt"
    @@optional_columns     = [:province, :city, :district]
    @@non_optional_columns = [:start_ip, :end_ip]
    @@columns              = @@non_optional_columns + @@optional_columns
    @@except_regexp        = /[a-zA-Z0-9]?(全国|中国|全省各市|\(.*\))?/
    @@separator            = "========================\n"

    def self.optional_columns=(other)
      Base.undef_class_methods(@@optional_columns)
      @@optional_columns = other
      @@columns          = @@non_optional_columns + @@optional_columns
      Base.defined_class_methods
      @@optional_columns
    end
  end

  class Base

    class << self
      def ip_cities(force_reload = false)
        return @@ip_cities if !force_reload && defined?(@@ip_cities) && @@ip_cities.present?

        @@ip_cities = {}
        File.open(Configuration.file_path, 'r') do |file|
          datas = file.to_a.split(Configuration.separator)
          datas.each do |data|
            header = data.delete_at(0).chomp
            data.each do |row|
              ip_city = row.chomp.split(',')
              @@ip_cities[header] ||= []
              @@ip_cities[header] << ip_city
            end
          end
        end
        @@ip_cities
      end

      def find_by_ip(ip)
        header, ip = get_header_and_ip(ip)
        ip_cities  = Base.ip_cities[header]
        return nil if ip_cities.blank?

        ip_cities  = ip_cities.select { |ip_city| ip_city[0].to_i <= ip && ip_city[1].to_i >= ip }
        ip_cities.sort_by { |ip_city| ip_city[1].to_i - ip_city[0].to_i }.first if ip_cities.present?
      end

      def defined_class_methods
        Configuration.columns.each_with_index do |col, index|
          next if Configuration.non_optional_columns.include?(col)
          instance_eval(<<-METHOD, __FILE__, __LINE__ + 1)
          def ip2#{col.to_s}(ip)
            find_by_ip(ip).try(:[], #{index})
          end
          METHOD
        end
      end

      def undef_class_methods(symbols)
        symbols.each do |symbol|
          singleton.send :undef_method, "ip2#{symbol.to_s}".to_sym
        end
      end

      def singleton
        class << Base; self; end
      end

      protected
      def get_header_and_ip(ip)
        case ip
        when Integer
          [ip.to_ip.split('.').first, ip]
        when String
          [ip.split('.').first, ip.to_s.to_int_ip]
        else
          raise ArgumentError, 'Parameters can only be Integer and String'
        end
      end
    end
  end
end

IPLibrary::Base.defined_class_methods

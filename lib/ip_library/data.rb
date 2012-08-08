#encoding: utf-8
require 'csv'
module IPLibrary

  class Data
    TITLES          = %w(start_ip end_ip province city district area_name_py start_ip1 end_ip1)
    MUNICIPALITIES  = %w(北京 上海 天津 重庆)
    DISTRICT_REGEXP = /(自治县|自治旗|特区|林区|县|区|旗)$/
    CITY_REGEXP     = /(自治州|地区|市|州|盟)$/
    PROVINCE_REGEXP = /(省|自治区|特别行政区)$/

    class << self

      def generate_txt(infile_path, outfile_path = nil)
        outfile_path ||= "#{Rails.root}/doc/#{Time.now.strftime('%y%m%d%H%M%S')}_ip_libraries.txt"
        raise ArgumentError, '请出入正确的文件路径！' unless File.file?(infile_path) || File.extname(infile_path) != '.txt'

        puts '正在生成txt文件'
        File.open(outfile_path, 'w') do |file|
          ip_cities = load_csv(infile_path).sort_by { |row| row[TITLES.index('start_ip')].to_i }
          ip_cities = ip_cities.group_by { |row| row[TITLES.index('start_ip1')].split('.').first }
          length    = ip_cities.keys.size
          index     = 0
          ip_cities.each do |key, value|
            index += 1
            file.write("#{key}\n")
            value.each do |v|
              file.write("#{v[0..4].join(',')}\n")
            end
            file.write("#{Configuration.separator}") if length != index
          end
        end
        puts "已经生成txt文件：#{outfile_path}"
      end

      def generate_custom_ip_library(areas, outfile_path = nil, infile_path = nil)
        infile_path  ||= Configuration.file_path
        outfile_path ||= File.join(Rails.root, 'doc', 'custom_ip_libraries.txt')
        ip_city_ids = get_ip_city_ids(areas)

        writer = []
        File.open(infile_path, 'r') do |file|
          file.each_line do |line|
            if (cols = line.split(',')).size == 5 && ip_city_ids[cols[2]].present? && (city_id = (ip_city_ids[cols[2]][cols[3]] || ip_city_ids[cols[2]][cols[4]])).present?
              writer << "#{cols[0]},#{cols[1]},#{city_id}\n"
            elsif cols.size != 5
              writer << cols.join(',')
            end
          end
        end

        puts "正在生成#{outfile_path}"
        File.open(outfile_path, 'w') do |file|
          writer.each do |line|
            file.write line
          end
        end
        puts '生成完毕'
      end

      private
      def get_ip_city_ids(areas)
        ip_city_ids = {}
        ip_datas    = Base.ip_cities.values.flatten(1).select { |t| t[2].present? && (t[3].present? || t[4].present?) }

        size = ip_datas.size
        ip_datas.each_with_index do |ip_city, index|
          pp "------------------#{index + 1}/#{size}--------------------"
          if ip_city[2].present?
            ip_city_ids[ip_city[2]] ||= {}

            if ip_city_ids[ip_city[2]][ip_city[3]].blank? && ip_city[3].present?
              areas.each do |t|
                if t['province'] =~ %r{#{ip_city[2]}} && t['city'] =~ %r{#{ip_city[3]}}
                  ip_city_ids[ip_city[2]][ip_city[3]] = t['city_id'] and break
                end
              end
              unless ip_city_ids[ip_city[2]][ip_city[3]].present?
                areas.each do |t|
                  if t['province'] =~ %r{#{ip_city[2]}} && t['district'] =~ %r{#{ip_city[3]}}
                    ip_city_ids[ip_city[2]][ip_city[3]] = t['city_id'] and break
                  end
                end
              end
            elsif ip_city_ids[ip_city[2]][ip_city[4]].blank? && ip_city[3].blank? && ip_city[4].present?
              areas.each do |t|
                if t['province'] =~ %r{#{ip_city[2]}} && t['district'] =~ %r{#{ip_city[4]}}
                  ip_city_ids[ip_city[2]][ip_city[4]] = t['city_id'] and break
                end
              end
            end
          end
        end

        ip_city_ids
      end

      def get_areas(province, city)
        if province =~ /北京|上海|天津|重庆/
          province.sub!(CITY_REGEXP, '')
          if city.blank?
            [province, province, nil]
          else
            [province, province, city]
          end
        elsif city.blank?
          province.sub!(PROVINCE_REGEXP, '')
          [province, nil, nil]
        elsif city =~ CITY_REGEXP
          province.sub!(PROVINCE_REGEXP, '')
          city.sub!(CITY_REGEXP, '')
          [province, city, nil]
        elsif city =~ DISTRICT_REGEXP
          province.sub!(PROVINCE_REGEXP, '')
          [province, nil, city]
        else
          province.sub!(PROVINCE_REGEXP, '')
          [province, city, nil]
        end
      end

      def get_areas_array(province, city)
        if province =~ /\//
          province.split('/').inject([]) do |result, p|
            result << get_areas(p, city)
          end
        elsif city =~ /\//
          city.split('/').inject([]) do |result, c|
            result << get_areas(province, c)
          end
        else
          [get_areas(province, city)]
        end
      end

      def load_csv(path)
        raise ArgumentError, '请出入正确的文件路径！' unless File.file?(path) || File.extname(path) != '.csv'

        index     = -1
        col_index = {}
        writer    = []

        CSV.foreach(path) do |row|
          index += 1
          GC.start if index % 100 == 0
          if index == 0
            (TITLES - ['district', 'area_name_py']).each do |col|
              col_index[col.to_sym] = row.index(col)
            end
            raise "csv文件内容格式不正确，必须有#{(TITLES - ['district', 'area_name_py']).join(', ')}等字段" if col_index.values.include?(nil)
            next
          end

          province = row[col_index[:province]].to_s.gsub(Configuration.except_regexp, '')
          city     = row[col_index[:city]].to_s.gsub(Configuration.except_regexp, '')
          get_areas_array(province, city).each do |area|
            puts [row[col_index[:start_ip]], row[col_index[:end_ip]], area].flatten and next if area.blank?
            writer << [row[col_index[:start_ip]], row[col_index[:end_ip]], area, row[col_index[:start_ip1]], row[col_index[:end_ip1]]].flatten
          end
        end
        writer
      end
    end
  end
end

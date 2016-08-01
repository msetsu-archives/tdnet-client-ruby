require 'time'

module TDnet
  module Response
    class Feed
      attr_reader :meta

      def initialize(raw_body, url)
        @url = url
        parse(Nokogiri.HTML(raw_body))
      end

      def inspect
        '#<%s:0x%x%s>' % [self.class, object_id, meta.inspect] # Simplify output
      end

      def count
        @entries.count
      end
      alias_method :size, :count

      def each
        return enum_for(:each) unless block_given?
        @entries.each do |entry|
          yield entry
        end
      end

      private

      def parse(doc)
        line_sel = '//*[@id="main-list-table"]//tr'

        meta_selectors = {
          date: ['//*[@id="kaiji-date-1"]', :as_text, :conv_date],
          page: ['//*[@class="pager-O"]', :as_text, :conv_page],
          max_page: ['(//*[@class="kaijiSum"]/text())[last()]', :as_text, :conv_max_page],
        }

        selectors = {
           time: ['./*[contains(@class, "kjTime")]', :as_text, :conv_time],
           code: ['./*[contains(@class, "kjCode")]', :as_text],
           name: ['./*[contains(@class, "kjName")]', :as_text],
          title: ['./*[contains(@class, "kjTitle")]/a', :as_text, :conv_classify],
            pdf: ['./*[contains(@class, "kjTitle")]//a/@href', :as_text, :conv_absolute_url],
           xbrl: ['./*[contains(@class, "kjXbrl")]//a/@href', :as_text, :conv_absolute_url],
           changed: ['boolean(descendant-or-self::*[contains(@class, "hyodaiUpd")])', :as_value],
           deleted: ['boolean(descendant-or-self::*[contains(@class, "hyodaiDel")])', :as_value],
        }

        @meta = meta_selectors.reduce({}) do |r, (key, sel)|
          xpath, getter, converter = sel
          r[key] = doc.xpath(xpath)
          r = self.send(getter, r, key)
          r = self.send(converter, r, key) if converter
          r
        end

        @entries = doc.xpath(line_sel).map do |line|
          selectors.reduce({}) do |r, (key, sel)|
            xpath, getter, converter = sel
            r[key] = line.xpath(xpath)
            r = self.send(getter, r, key)
            r = self.send(converter, r, key) if converter
            r
          end
        end
      end

      def as_text(entry, key)
        entry[key] = entry[key]&.first&.text
        entry
      end

      def as_value(entry, _key)
        entry # noop
      end

      def conv_classify(entry, key)
        entry[:kind] = case entry[key]
                         when /決算短信/ then :result
                         else
                           :other
                       end
        entry
      end

      def conv_max_page(entry, key)
        if (m = entry[key].match(/(?<from>\d+)[^\d]+(?<to>\d+)件[^\d]+全(?<all>\d+)件/))
          from = m['from'].to_i
          to = m['to'].to_i
          all = m['all'].to_i
          page = (1.0 * all / ((to + 1) - from)).ceil
          entry[key] = page
        else
          entry[key] = 0
        end
        entry
      end

      def conv_page(entry, key)
        entry[key] = entry[key].to_i - 1
        entry
      end

      def conv_date(entry, key)
        entry[key] = Date.strptime(entry[key], '%Y年%m月%d日')
        entry
      end

      def conv_time(entry, key)
        date = @meta[:date]
        time = strptime_as_tokyo(entry[key], '%H:%M')
        entry[key] = Time.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.utc_offset)
        entry
      end

      def conv_absolute_url(entry, key)
        path = entry[key]
        return entry if path.nil? || path.empty?

        entry[key] = URI.join(@url, path).to_s
        entry
      end

      def strptime_as_tokyo(date, format)
        time = Time.strptime(date, format)
        utc_offset = time.utc_offset
        zone_offset = 32400
        time.localtime(zone_offset) + utc_offset - zone_offset
      end
    end
  end
end

$:.unshift(File.dirname(__FILE__))

module Chapters
  module InitHandler
    extend ActiveSupport::Concern

    def init_parse_content
      chapters = Chapter.where(:scraper_status => :open).limit(10)
      chapters.each do |chapter|
        begin
          chapter = parse_content(chapter)
          chapter.scraper_status = :close
          chapter.save
        rescue Exception => e
          logger_error_write e.inspect
        end
      end
    end

    def parse_content chapter
      doc = h chapter.url,ENCODING
      html  = (doc/"#content").inner_html
      begin
        html = html.sub """\r\n\r\n<div align=\"center\"><script src=\"/ssi/style-gg.js\" type=\"text/javascript\"></script></div> \r\n\t\t\t""",""
        html = html.sub "\r\n\t\t\t",''
      rescue => e
        log e
      end
          
      Content.create content: html,book_id: chapter.book_id,chapter_id: chapter.id,word_count: content_count(html)
      
      return chapter if chapter.name.present?

      title = t doc/"h1.bname_content"
      title = $1 if title =~ /《.*》\s*(.*?)/
      
      chapter.name = title
      chapter
    end
  end
end
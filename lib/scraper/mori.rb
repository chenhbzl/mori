#encoding: utf-8
require 'open-uri'
require 'uri'
require "yaml"

module Mori 
  ENABLE_PROXY = false

  #BOOK_LOGGER = Logger.new(STDOUT)
  BOOK_LOGGER = Logger.new('log/scraper.log')
  ERROR_LOGGER = Logger.new('log/scraper_err.log')
  def logger_write message
    BOOK_LOGGER.info message
    puts message
  end

  def logger_error message
    #BOOK_LOGGER.fatal '-'*60
    ERROR_LOGGER.fatal message
    #BOOK_LOGGER.fatal '-'*60
  end

  def get_base_url
    "http://www.ranwen.net"
  end

  def pre_page
    25
  end

  def get_encoding
    "gbk"
  end

  def content_count html
    trim(html).length rescue 0
  end

  def get url,use_proxy=false,method='get',encoding=nil
    str = ''
    begin
      uri = URI url
      @proxy_server = ProxyServer.where(active: true).order('RAND()').take if use_proxy || ENABLE_PROXY
    
      if @proxy_server.nil?
        http = Net::HTTP.new(uri.host, uri.port)
      else
        proxy_ip   = @proxy_server.ip
        proxy_port = @proxy_server.port
        logger_write "proxy:#{proxy_ip},#{proxy_port}"
        proxy = Net::HTTP::Proxy(proxy_ip,proxy_port)
        http = proxy.new(uri.host, uri.port)
      end

      http.open_timeout = 10
      http.read_timeout = 10
      
      if method == 'post'
        response = http.post(uri.path, nil, 
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36",
          # "Accept-Encoding" => "identity",
          # "Referer" => url,
          # "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          # "Accept-Encoding" =>"gzip,deflate,sdch",
          # "Accept-Language" =>"zh-CN,zh;q=0.8",
          # "Cookie"=>"_hc.v=\"\"2f3d330d-e029-4aa7-9d31-7e48e3614ec4.1369380290\"\";...",
          "Host" => uri.host
        )
      else
        response = http.get("#{uri.path}?#{uri.query}")
      end
      
      case response
        when Net::HTTPSuccess then
          str = response.body
          str.encode! 'utf-8', encoding, {:invalid => :replace, :undef => :replace} unless encoding.blank?
          @proxy_server.update_attributes succ_count: @proxy_server.succ_count+1  unless @proxy_server.nil?
          str
        else
          save_error url,response.code
          get(url,true)
      end
    rescue => e
      logger_write "error:#{e.inspect}"
      save_error url,e.inspect    
      return get(url,true)
    end
  end

  def a node, key
    node.attributes[key]
  end

  def h url,encoding=nil
    Hpricot(get(url,false,'get',encoding))
  end

  def t node, first=true
    _text = ""
    if first
      unless node.nil?
        if node.instance_of?(Hpricot::Elements)
          _text = node.first.nil? ? "" : node.first.inner_text
        elsif  node.instance_of?(Hpricot::Elem)
          _text = node.inner_text
        else
          _text = node
        end
      end
    else
      _text = node.inner_text
    end
    
    trim _text
  end

  def l node, inner_text=true
    return nil, nil if node.nil?
    node = node.first if node.instance_of?(Hpricot::Elements)
    begin
      return node.attributes["href"],  inner_text ? node.inner_text : node.inner_html
    rescue => e
      return node.attributes["href"],nil
    end
  end


  def lt node
    l node, true
  end

  def lh node
    l node, false
  end

  def trim obj
    return "" if obj.nil?

    if obj.respond_to?(:inner_html)
      str = obj.inner_html
    else
      str = obj.to_s
    end

    [" ", "\t", "\r", "\n", "$", "was","&nbsp;","<br />","<br >","\r\n\t\t\t"].each do |c|
      str.gsub!(c, "")
    end

    str
  rescue => e
    logger_write "[error]trim:#{e.inspect}"
    obj
  end


  def time_to_str time=Time.now, format="%Y-%m-%d %H:%M:%S"
    time.strftime(format) unless time.nil?
  rescue => e
    logger_write "[error]trim:#{e.inspect}"
    logger_write "       #{time},#{format}"
    time
  end
  
  def trim_quote_and_numer v
    if v =~ /(.*)\(\d+\)/
      $1
    else
      logger_write "unknow tag:#{v}"
      v
    end
  end
  
  def save_error url,content
    logger_write "http error:#{url},#{content}"
    error = ErrorUrl.find_by url:url
    ErrorUrl.create url: url, status: content if error.nil?
    @proxy_server.update_attributes active: false,status: 'Error' if ENABLE_PROXY
  end
  

  alias text t
  alias g get
  alias la l
end

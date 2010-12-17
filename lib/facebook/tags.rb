class TagError < StandardError; end

module Facebook
  module Tags
    include Radiant::Taggable

    desc %{
      Retrieve OpenGraph data.
      <pre><code><r:facebook get="/google" /></code></pre>

      * *get* the path to the OpenGraph object
    }
    tag 'facebook' do |tag|
      path = require_attr!('get', tag.attr)
      client = RestGraph.new
      begin
        response = client.get(path)
      rescue => e
        raise TagError, "Request for OpenGraph object '#{path}' returned '#{e.class.to_s}'"
      end
      tag.locals.fb = response
      tag.expand
    end

    desc %{
      Render the data from the given key.
      <pre><code><r:facebook get="/google"><r:data key="name" /><r/:facebook></code></pre>

      * *key*     the key of the attribute you want to retrieve from the object
      * *type*    the type of data being retrieve (i.e. "time")
      * *format*  a regex of the time format the data will be rendered in
    }
    tag 'facebook:data' do |tag|
      key = require_attr!('key', tag.attr)
      type = tag.attr['type']
      format = tag.attr['format']
      data = tag.locals.fb_data ? tag.locals.fb_data[key] : tag.locals.fb[key]

      # Handle data of type 'time'
      if type && type == 'time'
        format = format || '%m/%d/%Y'
        begin
          date = DateTime.parse(data)
        rescue
          raise TagError, "Data of '#{key}' is not a valid date"
        end
        data = date.strftime(format)
      end

      data
    end

    desc %{
      Expand tag if the key exists.
      <pre><code><r:facebook get="/google"><r:if_data key="id">...</r:if_data></r:facebook></code></pre>

      * *key* the key of the attribute you want to retrieve from the object
    }
    tag 'facebook:if_data' do |tag|
      key = require_attr!('key', tag.attr)
      exists = tag.locals.fb_data ? tag.locals.fb_data[key] : tag.locals.fb[key]
      tag.expand if exists
    end

    desc %{
      Expand tag unless the key exists.
      <pre><code><r:facebook get="/google"><r:unless_data key="id">...</r:unless_data></r:facebook></code></pre>

      * *key* the key of the attribute you want to retrieve from the object
    }
    tag 'facebook:unless_data' do |tag|
      key = require_attr!('key', tag.attr)
      exists = tag.locals.fb_data ? tag.locals.fb_data[key] : tag.locals.fb[key]
      tag.expand unless exists
    end

    desc %{
      Iterate through a collection of response data.
      <pre><code><r:facebook get="/google/feed"><r:each key="data"><r:data key="message" /></r:each></r:facebook></code></pre>

      * *key*   the key of the attribute you want to retrieve from the object
      * *limit* limit the amount of results to return
    }
    tag 'facebook:each' do |tag|
      key = require_attr!('key', tag.attr)
      limit = tag.attr['limit']
      data = tag.locals.fb_data ? tag.locals.fb_data[key] : tag.locals.fb[key]
      results = []
      data.each do |d|
        break if limit && (data.index(d) > (limit.to_i - 1))
        tag.locals.fb_data = d
        results << tag.expand
      end
      results
    end

    private

    # Raise a TagError if the key doesn't exists
    def require_attr!(key, attrs)
      raise TagError, "'#{key}' attribute is required." unless attrs[key]
      attrs[key]
    end

  end
end

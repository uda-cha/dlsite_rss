module DlsiteRss
  class Item < Struct.new(
    :url, :title, :maker, :author, :description, :updated_at,
    :enclosure_url, :enclosure_type, :enclosure_length,
    keyword_init: true
  )

    def to_h
      {
        url: url,
        title: title,
        maker: maker,
        author: author,
        description: description,
        updated_at: updated_at.to_s,
        enclosure_url: enclosure_url,
        enclosure_type: enclosure_type,
        enclosure_length: enclosure_length,
      }
    end

    def self.from_h(hash)
      new(
        url: hash['url'],
        title: hash['title'],
        maker: hash['maker'],
        author: hash['author'],
        description: hash['description'],
        updated_at: Time.parse(hash['updated_at']),
        enclosure_url: hash['enclosure_url'],
        enclosure_type: hash['enclosure_type'],
        enclosure_length: hash['enclosure_length'],
      )
    end
  end
end

require "./book"

class SheetsApiClient
  property sheet_id : String
  property range : String

  def initialize(@sheet_id, @range)
  end

  def fetch_all
    sheet_url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(range)}"

    sheet_data = HTTP::Client.get(sheet_url,
      headers: HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
      }
    )

    parse_books(sheet_data.body)
  end

  def update(row_index : Int32, values : Array(Bool | Int32 | String | Nil))
    range = "#{@range.split("!")[0]}!A#{row_index}:D#{row_index}"
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{@sheet_id}/values/#{URI.encode_path(range)}?valueInputOption=USER_ENTERED"

    body = {
      "range"          => range,
      "majorDimension" => "ROWS",
      "values"         => [values],
    }.to_json

    HTTP::Client.put(url,
      headers: HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Content-Type"  => "application/json",
      },
      body: body
    )
  end

  private def access_token
    cred_path = File.expand_path("../creds.json", __DIR__)
    cred = GoogleAuth::FileCredential.new(
      file_path: cred_path,
      scopes: "https://www.googleapis.com/auth/spreadsheets", # String | Array(String)
      user_agent: "crystal/client",
    )

    token = cred.get_token
    token.access_token
  end

  private def parse_books(payload)
    data = JSON.parse(payload)
    values = data["values"].as_a
    header = values[0].as_a.map(&.as_s)
    books = [] of Book

    values[1..].each_with_index do |row, index|
      row_a = row.as_a
      row_index = index + 2 # Adjusting index to match row number in sheet (the row index starts at 1)
      title = row_a[0]?.try(&.as_s)
      unless title
        puts "Skipping row #{row_index} due to missing title"
        next
      end
      author = row_a[1]?.try(&.as_s)
      publication_year = row_a[2]?.try { |v| v.to_s.to_i? }
      read = row_a[3]?.try { |v| v.to_s.downcase == "true" }
      book = Book.new(row_index, title, author, publication_year, read)
      books << book
    end

    books
  end
end

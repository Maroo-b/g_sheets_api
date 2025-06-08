require "google-auth"
require "./book"

module GSheetsApi
  VERSION = "0.1.0"

  cred_path = File.expand_path("../creds.json", __DIR__)
  cred = GoogleAuth::FileCredential.new(
    file_path: cred_path,
    scopes: "https://www.googleapis.com/auth/spreadsheets", # String | Array(String)
    user_agent: "crystal/client",
  )

  token = cred.get_token
  access_token = token.access_token

  sheet_id = "13DLw6dqN6Hab258k8FdjUnOpuwX0FazTPz0OTKX-YT8"
  sheet_name = "books"
  range = "#{sheet_name}!A1:D7"
  sheet_url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(range)}"

  sheet_data = HTTP::Client.get(sheet_url,
    headers: HTTP::Headers{
      "Authorization" => "Bearer #{access_token}",
    }
  )
  p sheet_data.body

  parsed_books = parse_books(sheet_data.body)
  parsed_books.each do |book|
    p book
  end

  def self.parse_books(payload : String) : Array(Book)
    data = JSON.parse(payload)
    values = data["values"].as_a
    header = values[0].as_a.map(&.as_s)
    books = [] of Book

    values[1..].each_with_index do |row, index|
      row_a = row.as_a
      row_index = index + 2 # Adjusting index to match row number in sheet
      title = row_a[0]?.try(&.as_s)
      author = row_a[1]?.try(&.as_s)
      publication_year = row_a[2]?.try { |v| v.to_s.to_i? }
      read = row_a[3]?.try { |v| v.to_s.downcase == "true" }
      book = Book.new(row_index, title, author, publication_year, read)
      books << book
    end

    books
  end

  # TODO: Put your code here
end

require "./book"

class SheetsApiClient
  getter sheet_id : String
  getter start_col : String
  getter end_col : String
  getter sheet_name : String

  def initialize(@sheet_id : String, @start_col : String, @end_col : String, @sheet_name : String)
  end

  def all_rows : Array(Book)
    sheet_url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(default_range)}"
    response = HTTP::Client.get(sheet_url, headers: auth_headers)
    unless response.status_code == 200
      puts "Failed to fetch data: #{response.status_code} - #{response.body}"
      return [] of Book
    end
    parse_books(response.body)
  end

  def update_row(row_index : Int32, values : Array(Bool | Int32 | String | Nil)) : HTTP::Client::Response?
    update_range = range(row_index)
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(update_range)}?valueInputOption=USER_ENTERED"
    body = {
      "range"          => update_range,
      "majorDimension" => "ROWS",
      "values"         => [values],
    }.to_json

    response = HTTP::Client.put(url, headers: auth_headers_with_json, body: body)
    unless response.status_code == 200
      puts "Failed to update row: #{response.status_code} - #{response.body}"
      return nil
    end
    response
  end

  def add_row(values : Array(Bool | Int32 | String | Nil)) : HTTP::Client::Response?
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(default_range)}:append?valueInputOption=USER_ENTERED"
    body = {
      "range"          => default_range,
      "majorDimension" => "ROWS",
      "values"         => [values],
    }.to_json

    response = HTTP::Client.post(url, headers: auth_headers_with_json, body: body)
    unless response.status_code == 200
      puts "Failed adding row: #{response.status_code} - #{response.body}"
      return nil
    end
    response
  end

  def delete_row(row_index : Int32) : HTTP::Client::Response?
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}:batchUpdate"
    start_index = row_index - 1
    s_gid = sheet_gid
    unless s_gid
      puts "Sheet ID not found for sheet name: #{sheet_name}"
      return nil
    end

    body = {
      "requests" => [
        {
          "deleteDimension" => {
            "range" => {
              "sheetId"    => sheet_gid,
              "dimension"  => "ROWS",
              "startIndex" => start_index,
              "endIndex"   => start_index + 1,
            },
          },
        },
      ],
    }.to_json

    response = HTTP::Client.post(url, headers: auth_headers_with_json, body: body)
    unless response.status_code == 200
      puts "Failed to delete row: #{response.status_code} - #{response.body}"
      return nil
    end
    response
  end

  private def default_range : String
    "#{sheet_name}!#{start_col}1:#{end_col}1000"
  end

  private def range(row_index : Int32) : String
    "#{sheet_name}!#{start_col}#{row_index}:#{end_col}#{row_index}"
  end

  private def access_token : String
    cred_path = File.expand_path("../creds.json", __DIR__)
    cred = GoogleAuth::FileCredential.new(
      file_path: cred_path,
      scopes: "https://www.googleapis.com/auth/spreadsheets",
      user_agent: "crystal/client",
    )
    cred.get_token.access_token
  end

  private def auth_headers : HTTP::Headers
    HTTP::Headers{
      "Authorization" => "Bearer #{access_token}",
    }
  end

  private def auth_headers_with_json : HTTP::Headers
    HTTP::Headers{
      "Authorization" => "Bearer #{access_token}",
      "Content-Type"  => "application/json",
    }
  end

  private def parse_books(payload : String) : Array(Book)
    data = JSON.parse(payload)
    values = data["values"].as_a
    header = values[0].as_a.map(&.as_s)
    books = [] of Book

    values[1..].each_with_index do |row, index|
      row_a = row.as_a
      row_index = index + 2
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

  private def sheet_gid : Int32?
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}"
    response = HTTP::Client.get(url, headers: auth_headers)
    return nil unless response.status_code == 200

    data = JSON.parse(response.body)
    sheets = data["sheets"]?.try(&.as_a)
    return nil unless sheets

    sheet = sheets.find { |s| s["properties"]?.try(&.["title"]?.try(&.as_s)) == sheet_name }
    return nil unless sheet

    properties = sheet["properties"]?.try(&.as_h)
    sheet_id = properties.try(&.["sheetId"]?.try(&.as_i))
    sheet_id
  end
end

require "google-auth"
require "./book"
require "./sheets_api_client"

module GSheetsApi
  VERSION = "0.1.0"

  # cred_path = File.expand_path("../creds.json", __DIR__)
  # cred = GoogleAuth::FileCredential.new(
  #   file_path: cred_path,
  #   scopes: "https://www.googleapis.com/auth/spreadsheets", # String | Array(String)
  #   user_agent: "crystal/client",
  # )

  # token = cred.get_token
  # access_token = token.access_token

  sheet_id = "13DLw6dqN6Hab258k8FdjUnOpuwX0FazTPz0OTKX-YT8"
  sheet_name = "books"
  range = "#{sheet_name}!A1:D7"
  # sheet_url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}/values/#{URI.encode_path(range)}"

  client = SheetsApiClient.new(sheet_id, range)
  res = client.fetch_all
  book = res[2]
  book.title = "updated"
  client.update(book.row_index, book.to_payload)

  # book = Book.new(row_index: 22, title: "test book", read: false, author: "tt", publication_year: 111)
end

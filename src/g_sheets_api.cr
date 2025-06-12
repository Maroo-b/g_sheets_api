require "google-auth"
require "./book"
require "./sheets_api_client"

module GSheetsApi
  VERSION = "0.1.0"

  sheet_id = "13DLw6dqN6Hab258k8FdjUnOpuwX0FazTPz0OTKX-YT8"
  sheet_name = "books"

  client = SheetsApiClient.new(
    sheet_id: sheet_id,
    sheet_name: sheet_name,
    start_col: "A",
    end_col: "D",
  )

  new_book = Book.new(
    row_index: 6, # it doesn't matter, it will be appended after the last row
    title: "Into Programming",
    author: "Jane Doe",
    publication_year: 2024,
    read: false,
  )

  response = client.add_row(new_book.to_payload)
  if response
    puts "Book added successfully!"
  else
    puts "Failed to add book."
  end

  # Fetch all books
  books = client.all_rows
  if books.empty?
    puts "No books found or error occurred."
  else
    puts "Books in sheet:"
    books.each { |book| puts "#{book.title} by #{book.author} (#{book.publication_year}) - Read: #{book.read}" }
  end

  # Update the first book if exists
  if books.size > 0
    first_book = books.first
    first_book.read = true
    update_response = client.update_row(first_book.row_index, first_book.to_payload)
    if update_response
      puts "First book marked as read."
    else
      puts "Failed to update the first book."
    end
  end

  # Delete the last book if exists
  if books.size > 0
    second_book = books[1]
    delete_response = client.delete_row(second_book.row_index)
    if delete_response
      puts "Last book deleted."
    else
      puts "Failed to delete the last book."
    end
  end
end

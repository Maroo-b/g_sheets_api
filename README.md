# g_sheets_api

This repository demonstrates how to interact with the Google Sheets API using the Crystal programming language. It provides a simple, practical example for reading, writing, updating, and deleting rows in a Google Sheet, all from Crystal code.

The code is designed to be clear and easy to follow, making it a great reference for anyone looking to automate Google Sheets tasks or integrate spreadsheet data into their Crystal applications.

For instructions on setting up your Google Cloud project, enabling the Sheets API, and obtaining credentials, please refer to the accompanying [blog post](https://marouenbousnina.com/crystal/2025-06-03-google-sheet-integration/).

## Installation

Follow the setup for the Goolge sheets API from the blog post here.
Then install depdendencies from the project root:

```
shards install
```

## Usage

1. Add a `cred.json` file from the setup phase to project folder.
2. Run the example with `crystal run src/g_sheets_api.cr`

## Contributing

1. Fork it (<https://github.com/your-github-user/g_sheets_api/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Marouen Bousnina](https://github.com/your-github-user) - creator and maintainer

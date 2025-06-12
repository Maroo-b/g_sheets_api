class Book
  property row_index : Int32
  property title : String
  property author : String?
  property publication_year : Int32?
  property read : Bool?

  def initialize(@row_index, @title, @author, @publication_year, @read = false)
  end

  def to_payload
    [title, author, publication_year, read]
  end
end

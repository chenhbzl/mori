class Api::ChaptersController < Api::BaseController
  def index
    chapters = Chapter.limit(1)
    c = JSON.parse(chapters.to_json)
    c[0]["content"] = chapters[0].content.content[0..225]
    render :json => c
  end
end
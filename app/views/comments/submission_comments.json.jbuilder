json.array!(@comments) do |comment|
  json.extract! comment, :id, :content, :user_id, :submission_id, :created_at, :updated_at
  json.set! "_links" do
    json.set! "self" do
      json.set! "href", comment_url(comment, format: :json)
    end
    json.set! "user" do
      json.set! "href", user_url(comment.user, format: :json)
    end
    json.set! "submission" do
      json.set! "href", submission_url(comment.submission, format: :json)
    end
  end
end

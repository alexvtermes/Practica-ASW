json.array!(@replies) do |reply|
  json.extract! reply, :id, :content, :user_id, :created_at, :updated_at
  json.set! "_links" do
    json.set! "self" do
      json.set! "href", reply_url(reply, format: :json)
    end
    json.set! "user" do
      json.set! "href", user_url(reply.user, format: :json)
    end
    json.set! "comment" do
      json.set! "href", comment_url(reply.comment, format: :json)
    end
  end
end

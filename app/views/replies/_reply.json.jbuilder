json.extract! reply, :id, :content, :user_id, :comment_id, :created_at, :updated_at
json.url reply_url(reply, format: :json)


json.array!(@submissions) do |submission|
  if submission.url != ""
    json.extract! submission, :id, :title, :url, :text, :created_at, :updated_at
    json.set! "_links" do
      json.set! "self" do
        json.set! "href", submission_url(submission, format: :json)
      end
    end
  end
end
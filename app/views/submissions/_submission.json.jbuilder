json.array!(@submissions) do |submission|
    json.extract! submission, :id, :title, :url, :text
    json.set! "_links" do
      json.set! "self" do
        json.set! "href", submission_url(submission, format: :json)
      end
    end
end
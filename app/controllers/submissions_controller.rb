class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  # GET /submissions
  # GET /submissions.json
  def index
    @submissions = Submission.all.where.not(url:"").order(:cached_votes_total=> :desc)
  end

  # GET /submissions/1
  # GET /submissions.json
  def show
    @comments = Comment.where("submission_id=" + (params[:id])).order("created_at DESC")
  end

  # GET /submissions/newest
  # GET /submissions.json
  def newest
    @submissions = Submission.all.order("created_at DESC")
    @from_newest = true;
    render :index
  end

  # GET /submissions/ask
  # GET /submissions.json
  def ask
    @submissions = Submission.all.where(url:"").order("created_at DESC")
    @from_ask = true;
    render :index
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
  end

  # GET /submissions/1/edit
  def edit
  end

  def xor(a, b)
    (a and (not b)) or ((not a) and b)
  end

  # POST /submissions
  # POST /submissions.json
  def create
    if current_user
      if xor(submission_params[:url].blank?, submission_params[:text].blank?) && !submission_params[:title].blank?
        parameters = submission_params
        if submission_params[:text].blank?
          parameters[:url] = parameters[:url].sub(/^https?\:\/\//, '').sub(/^www./,'')
          parameters[:url] = 'http://' + parameters[:url]
        end
        if (parameters[:url] != "" && !Submission.where(url: parameters[:url]).present?) ||
          (parameters[:url] == "")
          @submission = Submission.new(parameters)
          @submission.user = current_user
          @user = @submission.user
          @user.karma = @user.karma + 1
          respond_to do |format|
            if @submission.save && @user.save
              @submission.vote_by :voter => current_user
              format.html { redirect_to :newest}
              format.json { render :newest, status: :created, location: @submission }
            else
              format.html { render :new }
              format.json { render json: @submission.errors, status: :unprocessable_entity }
            end
          end
        else
          redirect_to "/submissions/new", :notice => "Url exists"
        end
      else
        redirect_to "/submissions/new", :notice => "Write a title and an url or a text"
      end
    else
      redirect_to "/auth/google_oauth2"
    end
  end

  # PATCH/PUT /submissions/1
  # PATCH/PUT /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission}
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url }
      format.json { head :no_content }
    end
  end

  def vote
    if current_user
      @submission = Submission.find(params[:id])
      @submission.liked_by current_user
      redirect_to "/submissions/" + params[:id]
    else 
      redirect_to "/auth/google_oauth2"
    end
  end

  def unvote
    if current_user
      @submission = Submission.find(params[:id])
      @submission.unliked_by current_user
      redirect_to "/submissions/" + params[:id]
    else
      redirect_to "/auth/google_oauth2"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:title, :url, :text, :user_id)
    end
end

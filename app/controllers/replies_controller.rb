class RepliesController < ApplicationController
  before_action :set_reply, only: [:show, :edit, :update, :destroy]

  def new_reply
    if current_user
      @reply = Reply.find(params[:id])
      @replies = Reply.where("replay_parent_id=?",@reply.id).order("created_at DESC")
    else
      redirect_to "/auth/google_oauth2"
    end
  end

  def vote
    if current_user
      @reply = Reply.find(params[:id])
      @reply.liked_by current_user
      @comment = Comment.find(@reply.comment_id)
      redirect_to "/submissions/" + @comment.submission_id.to_s
    else
      redirect_to "/auth/google_oauth2"
    end
  end

  def unvote
    if current_user
      @reply = Reply.find(params[:id])
      @reply.unliked_by current_user
      @comment = Comment.find(@reply.comment_id)
      redirect_to "/submissions/" + @comment.submission_id.to_s
    else
      redirect_to "/auth/google_oauth2"
    end
  end  

  # GET /replies
  # GET /replies.json
  def index
    @replies = Reply.all
  end

  # GET /replies/1
  # GET /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies
  # POST /replies.json
  def create
    if current_user
      @reply = Reply.new(reply_params)
      if !reply_params[:content].blank?
        respond_to do |format|
          if @reply.save
            @reply.vote_by :voter => current_user
            if !@reply.comment.nil?
              format.html { redirect_to @reply.comment.submission }
              format.json { render :show, status: :created, location: @reply }
            else
              format.html { redirect_to @reply.parent.submission }
              format.json { render :show, status: :created, location: @reply }
            end
          else
            format.html { redirect_to '/comments/' + (@reply.comment.id).to_s + '/new_reply' }
            format.json { render json: @reply.errors, status: :unprocessable_entity }
          end
        end
      else
         redirect_to "/comments/" + (@reply.comment.id).to_s + "/new_reply", :notice => "Write a reply"
      end
    else
      redirect_to "auth/google_oauth2"
    end
  end

  # POST /repliesR
  def create_reply
    if current_user
      @reply = Reply.new(reply_params)
      if !reply_params[:content].blank?
        respond_to do |format|
          if @reply.save
            @reply.vote_by :voter => current_user
            format.html { redirect_to @reply.parent.submission }
            format.json { render :show, status: :created, location: @reply }
          else
            logger.debug "instancia reply not saved... unlucky"
            format.html { redirect_to '/replies/' + (@reply.reply_parent_id).to_s + '/new_reply' }
            format.json { render json: @reply.errors, status: :unprocessable_entity }
          end
        end
      else
         redirect_to "/replies/" + (@reply.parent.id).to_s + "/new_reply", :notice => "Write a reply"
      end
    else
      redirect_to "auth/google_oauth2"
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        if !@reply.comment.nil?
          format.html { redirect_to @reply.comment.submission }
          format.json { render :show, status: :ok, location: @reply }
        else
          format.html { redirect_to @reply.parent.submission }
          format.json { render :show, status: :ok, location: @reply }
        end
      else
        format.html { render :edit }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @reply.destroy
    respond_to do |format|
      format.html { redirect_to replies_url }
      format.json { head :no_content }
    end
  end

  private
    def set_reply
      @reply = Reply.find(params[:id])
    end

    def reply_params
      params.require(:reply).permit(:content, :user_id, :comment_id, :reply_parent_id, :submission_id)
    end
end
